local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Utility = Foundation.Utility
local TypesSource = Utility.Types

local withDefaults = require(Utility.withDefaults)
local withGuiObjectProps = require(Utility.withGuiObjectProps)
local themeProvider = require(Utility.themeProvider)
local unwrap = require(Utility.unwrap)
local Types = require(TypesSource.Types)

local Visibility = require(Foundation.Enums.Visibility)
local ControlState = require(Foundation.Enums.ControlState)

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
	children: {Child}?,
	tag: string?,

	AutomaticSize: UsedAs<Enum.AutomaticSize>?,
	AutomaticCanvasSize: UsedAs<Enum.AutomaticSize>?,
	CanvasSize: UsedAs<UDim2>?,
	ClipsDescendants: UsedAs<boolean>?,
	ScrollingDirection: UsedAs<Enum.ScrollingDirection>?,
	ScrollingEnabled: UsedAs<boolean>?,
	VerticalScrollBarInset: UsedAs<Enum.ScrollBarInset>?,
	HorizontalScrollBarInset: UsedAs<Enum.ScrollBarInset>?,
}

return function(scrollingFrameProps: ScrollingFrameProps)
	local Scope = scrollingFrameProps.scope
	local Theme = themeProvider()
	
	assert(Scope, "A scope has not been provided for the ScrollingFrame component.")
	
	local props = withDefaults(scrollingFrameProps, defaultProps)
	local selectionProps = withGuiObjectProps({selection = props.selection}, {})
	local scrollBarTransparencyStyle = unwrap(Theme:GetTransparency("Shift", "Shift_400"))
	local scrollBarTransparency = Scope:Value(scrollBarTransparencyStyle)
	local scrollBarColorStyle = Theme:GetColor("Shift", "Shift_400")
	
	local scrollBarThickness = Scope:Computed(function(use: Use) 
		local scrollBarVisibility = unwrap(props.scrollBarVisibility, use)
		if scrollBarVisibility == Visibility.None then
			return 0
		else
			return unwrap(Theme:GetTokenData("Size", "Size_150"), use)
		end
	end)
	
	local delayRef = Scope:Value(nil)
	local scrollBarTransparencySpring = Scope:Spring(scrollBarTransparency, ANIMATION_CONFIG.speed)
	
	local function setIsScrollBarVisible(isVisible: boolean, delay: number?)
		local delayThread = unwrap(delayRef)
		if delayThread then task.cancel(delayThread) end
		
		if isVisible then
			scrollBarTransparency:set(scrollBarTransparencyStyle)
		end
		
		if delay ~= nil then
			delayRef:set(task.delay(delay, function() 
				scrollBarTransparency:set(1)
			end))
		end
	end
	
	local function updateVisibility(scrollBarVisibility: Visibility, controlState: ControlState)
		if scrollBarVisibility == "None" then
			setIsScrollBarVisible(false, 0)
		elseif scrollBarVisibility == "Always" then
			setIsScrollBarVisible(true)
		else
			setIsScrollBarVisible(
				controlState == ControlState.Hover
					or controlState == ControlState.Selected
					or controlState == ControlState.Pressed,
				if controlState == ControlState.Default then 0 else nil
			)
		end
	end
	
	local isVisibilityState = props.scrollBarVisibility ~= unwrap(props.scrollBarVisibility)
	local isControlState = props.controlState ~= unwrap(props.controlState)
	
	if isVisibilityState then
		Scope:Observer(props.scrollBarVisibility):onChange(function() 
			updateVisibility(unwrap(props.scrollBarVisibility), unwrap(props.controlState))	
		end)
	end
	
	if isControlState then
		Scope:Observer(props.controlState):onChange(function() 
			updateVisibility(unwrap(props.scrollBarVisibility), unwrap(props.controlState))	
		end)
	end

	updateVisibility(unwrap(props.scrollBarVisibility), unwrap(props.controlState))	
	
	return Scope:New "ScrollingFrame" {
		-- Scrolling props
		AutomaticCanvasSize = props.AutomaticCanvasSize,
		CanvasSize = props.CanvasSize,
		ClipsDescendants = props.ClipsDescendants,
		ScrollingDirection = props.ScrollingDirection,
		ScrollingEnabled = props.ScrollingEnabled,
		ScrollBarImageColor3 = scrollBarColorStyle,
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
		
		[OnChange "CanvasPosition"] = function(rbx)
			local scrollBarVisibility = unwrap(props.scrollBarVisibility)
			if scrollBarVisibility == "Auto" then
				setIsScrollBarVisible(true, HIDE_SCROLLBAR_DELAY)
			end
			if props.onCanvasPositionChanged then
				props.onCanvasPositionChanged(rbx)
			end
		end,
		
		[OnChange "AbsoluteCanvasSize"] = props.onAbsoluteCanvasSizeChanged,
		[OnChange "AbsoluteWindowSize"] = props.onAbsoluteWindowSizeChanged,
		
		[Children] = props.children
	}
end