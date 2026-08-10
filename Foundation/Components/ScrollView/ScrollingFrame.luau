local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Utility = Foundation.Utility

local withDefaults = require(Utility.withDefaults)
local withGuiObjectProps = require(Utility.withGuiObjectProps)
local unwrap = require(Utility.unwrap)
local isState = require(Utility.isState)
local Types = require(Utility.Types)

local Visibility = require(Foundation.Enums.Visibility)
local ControlState = require(Foundation.Enums.ControlState)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local useStyleTags = require(Foundation.Providers.ThemeProvider.useStyleTags)

local Children = Fusion.Children
local OnChange = Fusion.OnChange
local Tag = Fusion.Tag

local HIDE_SCROLLBAR_DELAY = 2

local ANIMATION_CONFIG = {
	speed = 10
}

local defaultProps = {
	scrollBarVisibility = "Auto",
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

type Visibility = Visibility.Visibility
type ControlState = ControlState.ControlState

export type ScrollingFrameProps = {
	scope: Scope,
	
	controlState: ControlState,
	selection: Selection?,
	scrollBarVisibility: UsedAs<Visibility>?,
	onCanvasPositionChanged: ((instance: ScrollingFrame) -> ())?,
	onAbsoluteCanvasSizeChanged: ((instance: ScrollingFrame) -> ())?,
	onAbsoluteWindowSizeChanged: ((instance: ScrollingFrame) -> ())?,
	children: Child?,
	tag: UsedAs<string>?,

	AutomaticSize: UsedAs<Enum.AutomaticSize>?,
	AutomaticCanvasSize: UsedAs<Enum.AutomaticSize>?,
	CanvasSize: UsedAs<UDim2>?,
	ClipsDescendants: UsedAs<boolean>?,
	ScrollingDirection: UsedAs<Enum.ScrollingDirection>?,
	ScrollingEnabled: UsedAs<boolean>?,
	VerticalScrollBarInset: UsedAs<Enum.ScrollBarInset>?,
	HorizontalScrollBarInset: UsedAs<Enum.ScrollBarInset>?,
}

local function setIsScrollBarVisible(isVisible: boolean, delay: number?, delayRef: UsedAs<thread?>, scrollBarTransparency: UsedAs<number>, scrollBarTransparencyStyle: number)
	local delayThread = unwrap(delayRef)
	if delayThread then task.cancel(delayThread) end

	if isVisible then
		scrollBarTransparency:set(scrollBarTransparencyStyle)
	end
	
	if not delay then return end
	
	delayRef:set(task.delay(delay, function() 
		scrollBarTransparency:set(1)
	end))
end

local function updateVisibility(scrollBarVisibility: Visibility, controlState: ControlState, delayRef: UsedAs<thread?>, scrollBarTransparency: UsedAs<number>, scrollBarTransparencyStyle: number)
	if scrollBarVisibility == "None" then
		setIsScrollBarVisible(false, 0, delayRef, scrollBarTransparency, scrollBarTransparencyStyle)
	elseif scrollBarVisibility == "Always" then
		setIsScrollBarVisible(true, nil, delayRef, scrollBarTransparency, scrollBarTransparencyStyle)
	else
		setIsScrollBarVisible(
			controlState == ControlState.Hover
				or controlState == ControlState.Selected
				or controlState == ControlState.Pressed,
			if controlState == ControlState.Default then 0 else nil,
			delayRef, scrollBarTransparency, scrollBarTransparencyStyle
		)
	end
end

return function(scrollingFrameProps: ScrollingFrameProps)
	local Scope = scrollingFrameProps.scope
	local Theme = ThemeProvider()
	
	assert(Scope, "A scope has not been provided for the ScrollingFrame component.")
	
	local props = withDefaults(scrollingFrameProps, defaultProps)
	local selectionProps = withGuiObjectProps({selection = props.selection}, {})
	
	local isVisiblityAState = isState(props.scrollBarVisibility)
	local isControlAState = isState(props.controlState)
	
	return Scope:Computed(function(use: Use, innerScope: Scope) 
		local tokens = unwrap(Theme.Tokens, use)
		local scrollBarColorStyle = tokens.Color.Shift.Shift_400
		local scrollBarTransparency = innerScope:Value(scrollBarColorStyle.Transparency)
		
		local fulltag = unwrap(useStyleTags(innerScope, scrollingFrameProps.tag, Theme.AddTags))
		local tags = {}
		for str in string.gmatch(fulltag or "", "%S+") do
			tags[Tag(str)] = true
		end
		
		local scrollBarThickness = innerScope:Computed(function(use: Use) 
			local scrollBarVisibility = unwrap(props.scrollBarVisibility, use)
			if scrollBarVisibility == Visibility.None then
				return 0
			else
				return tokens.Size.Size_150
			end
		end)
		
		local delayRef = innerScope:Value(nil)
		local scrollBarTransparencySpring = innerScope:Spring(scrollBarTransparency, ANIMATION_CONFIG.speed)
		
		if isVisiblityAState then
			innerScope:Observer(props.scrollBarVisibility):onChange(function() 
				updateVisibility(unwrap(props.scrollBarVisibility), unwrap(props.controlState), delayRef, scrollBarTransparency, scrollBarColorStyle.Transparency)	
			end)
		end

		if isControlAState then
			innerScope:Observer(props.controlState):onChange(function() 
				updateVisibility(unwrap(props.scrollBarVisibility), unwrap(props.controlState), delayRef, scrollBarTransparency, scrollBarColorStyle.Transparency)	
			end)
		end
		updateVisibility(unwrap(props.scrollBarVisibility), unwrap(props.controlState), delayRef, scrollBarTransparency, scrollBarColorStyle.Transparency)	
		
		return innerScope:New "ScrollingFrame" (Dash.union({
			-- Scrolling props
			AutomaticCanvasSize = props.AutomaticCanvasSize,
			CanvasSize = props.CanvasSize,
			ClipsDescendants = props.ClipsDescendants,
			ScrollingDirection = props.ScrollingDirection,
			ScrollingEnabled = props.ScrollingEnabled,
			ScrollBarImageColor3 = scrollBarColorStyle.Color3,
			ScrollBarImageTransparency = scrollBarTransparencySpring,
			ScrollBarThickness = scrollBarThickness,
			VerticalScrollBarInset = props.VerticalScrollBarInset,
			HorizontalScrollBarInset = props.HorizontalScrollBarInset,

			-- Support insets when they are fixed at the engine level
			-- https://roblox.atlassian.net/browse/UISYS-3298

			-- Invisible frame props
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutomaticSize = props.AutomaticSize,
			Size = UDim2.fromScale(1, 1),

			-- Selection props
			Selectable = selectionProps.Selectable,
			NextSelectionUp = selectionProps.NextSelectionUp,
			NextSelectionDown = selectionProps.NextSelectionDown,
			NextSelectionLeft = selectionProps.NextSelectionLeft,
			NextSelectionRight = selectionProps.NextSelectionRight,
			SelectionImageObject = selectionProps.SelectionImageObject,
			SelectionOrder = selectionProps.SelectionOrder,

			[OnChange "CanvasPosition"] = function(instance: ScrollingFrame)
				local scrollBarVisibility = unwrap(props.scrollBarVisibility)
				if scrollBarVisibility == "Auto" then
					setIsScrollBarVisible(true, HIDE_SCROLLBAR_DELAY, delayRef, scrollBarTransparency, scrollBarColorStyle.Transparency)
				end
				if props.onCanvasPositionChanged then
					props.onCanvasPositionChanged(instance)
				end
			end,

			[OnChange "AbsoluteCanvasSize"] = props.onAbsoluteCanvasSizeChanged,
			[OnChange "AbsoluteWindowSize"] = props.onAbsoluteWindowSizeChanged,

			[Children] = props.children
		}, tags))
	end)
end