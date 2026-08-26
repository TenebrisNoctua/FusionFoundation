local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local isState = require(Utility.isState)
local withDefaults = require(Utility.withDefaults)
local useDefaultTags = require(Utility.useDefaultTags)
local withGuiObjectProps = require(Utility.withGuiObjectProps)
local Types = require(Utility.Types)

local Visibility = require(Enums.Visibility)
local ControlState = require(Enums.ControlState)

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
	layout = {
		SortOrder = Enum.SortOrder.LayoutOrder,
	} :: ListLayout,
	scroll = {
		scrollBarVisibility = Visibility.Auto,
	} :: Scroll,
	AutoLocalize = false,
	BorderSizePixel = 0,
	ClipsDescendants = false,
	isDisabled = false
}

local defaultTags = "gui-object-defaults"

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

type Visibility = Visibility.Visibility
type ControlState = ControlState.ControlState

type ListLayout = Types.ListLayout
type GuiObjectProps = Types.GuiObjectProps
type CommonProps = Types.CommonProps
type StateChangedCallback = Types.StateChangedCallback

export type Scroll = {
	AutomaticSize: UsedAs<Enum.AutomaticSize>?,
	AutomaticCanvasSize: UsedAs<Enum.AutomaticSize>?,
	CanvasSize: UsedAs<UDim2>?,
	ScrollingDirection: UsedAs<Enum.ScrollingDirection>?,
	ScrollingEnabled: UsedAs<boolean>?,
	VerticalScrollBarInset: UsedAs<Enum.ScrollBarInset>?,
	HorizontalScrollBarInset: UsedAs<Enum.ScrollBarInset>?,
	scrollBarVisibility: UsedAs<Visibility>?
}

export type ScrollViewProps = {
	scroll: Scroll?,
	onCanvasPositionChanged: ((instance: ScrollingFrame) -> ())?,
	onAbsoluteCanvasSizeChanged: ((instance: ScrollingFrame) -> ())?,
	onAbsoluteWindowSizeChanged: ((instance: ScrollingFrame) -> ())?,
} & GuiObjectProps & CommonProps

--// Merged ScrollingFrame helper functions

local function setIsScrollBarVisible(
	isVisible: boolean,
	delay: number?,
	delayRef: UsedAs<thread?>,
	scrollBarTransparency: UsedAs<number>,
	scrollBarTransparencyStyle: number
)
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

local function updateVisibility(
	scrollBarVisibility: Visibility,
	controlState: ControlState,
	delayRef: UsedAs<thread?>,
	scrollBarTransparency: UsedAs<number>,
	scrollBarTransparencyStyle: number
)
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

return function(scrollViewProps: ScrollViewProps)
	local scope = scrollViewProps.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the ScrollView component.")

	local props = withDefaults(scrollViewProps, defaultProps)
	return scope:Computed(function(use: Use, innerScope: Scope)
		local controlState = innerScope:Value(ControlState.Initialize)
		local tagsWithDefaults = useDefaultTags(innerScope, props.tag, defaultTags)
		local tag = useStyleTags(innerScope, tagsWithDefaults, theme.AddTags)

		local scrollBarColorStyle = innerScope:Computed(function(use: Use)
			local tokens = unwrap(theme.Tokens, use)
			return tokens.Color.Shift.Shift_400
		end)

		local currentColorStyle = unwrap(scrollBarColorStyle)
		local scrollBarTransparency = innerScope:Value(currentColorStyle.Transparency)

		local scrollBarThickness = innerScope:Computed(function(use: Use)
			local scrollBarVisibility = unwrap(props.scroll.scrollBarVisibility, use)
			if scrollBarVisibility == Visibility.None then
				return 0
			else
				local tokens = unwrap(theme.Tokens, use)
				return tokens.Size.Size_150
			end
		end)

		local delayRef = innerScope:Value(nil)
		local scrollBarTransparencySpring = innerScope:Spring(scrollBarTransparency, ANIMATION_CONFIG.speed)

		-- Function to update visibility using current theme values
		local function doUpdateVisibility()
			local colorStyle = unwrap(scrollBarColorStyle)
			updateVisibility(
				unwrap(props.scroll.scrollBarVisibility),
				unwrap(controlState),
				delayRef,
				scrollBarTransparency,
				colorStyle.Transparency
			)
		end

		innerScope:Observer(scrollBarColorStyle):onChange(doUpdateVisibility)
		innerScope:Observer(controlState):onChange(doUpdateVisibility)

		if isState(props.scroll.scrollBarVisibility) then
			innerScope:Observer(props.scroll.scrollBarVisibility):onChange(doUpdateVisibility)
		end

		doUpdateVisibility()

		local children = props.children
		local isChildrenAState = isState(children)

		if not isChildrenAState and typeof(children) == "function" then
			children = children(innerScope)
		end

		local layout = props.layout
		local hasFillDirection = false
		if layout then
			local fillDirection = unwrap(layout.FillDirection)
			hasFillDirection = fillDirection ~= nil
		end

		local scrollingFrameChildren
		if isChildrenAState then
			scrollingFrameChildren = children
		elseif children and typeof(children) == "table" and hasFillDirection then
			local listChildren = {
				innerScope:New "UIListLayout" {
					FillDirection = layout.FillDirection,
					ItemLineAlignment = layout.ItemLineAlignment,
					HorizontalAlignment = layout.HorizontalAlignment,
					HorizontalFlex = layout.HorizontalFlex,
					VerticalAlignment = layout.VerticalAlignment,
					VerticalFlex = layout.VerticalFlex,
					Padding = layout.Padding,
					SortOrder = layout.SortOrder,
					Wraps = layout.Wraps,
				}
			}
			scrollingFrameChildren = Dash.union(listChildren, children)
		else
			scrollingFrameChildren = children
		end

		local selectionProps = withGuiObjectProps({selection = props.selection}, {})
		local fulltag = unwrap(tag)
		local scrollingFrameTags = {}
		
		for str in string.gmatch(fulltag or "", "%S+") do
			scrollingFrameTags[Tag(str)] = true
		end

		local scrollingFrame = innerScope:New "ScrollingFrame" (Dash.union({
			AutomaticCanvasSize = props.scroll.AutomaticCanvasSize,
			CanvasSize = props.scroll.CanvasSize,
			ClipsDescendants = true,
			ScrollingDirection = props.scroll.ScrollingDirection,
			ScrollingEnabled = props.scroll.ScrollingEnabled,
			ScrollBarImageColor3 = innerScope:Computed(function(use: Use)
				local colorStyle = unwrap(scrollBarColorStyle, use)
				return colorStyle.Color3
			end),
			ScrollBarImageTransparency = scrollBarTransparencySpring,
			ScrollBarThickness = scrollBarThickness,
			VerticalScrollBarInset = props.scroll.VerticalScrollBarInset,
			HorizontalScrollBarInset = props.scroll.HorizontalScrollBarInset,

			-- Invisible frame props
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutomaticSize = props.scroll.AutomaticSize,
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
				local scrollBarVisibility = unwrap(props.scroll.scrollBarVisibility)
				if scrollBarVisibility == "Auto" then
					local colorStyle = unwrap(scrollBarColorStyle)
					setIsScrollBarVisible(true, HIDE_SCROLLBAR_DELAY, delayRef, scrollBarTransparency, colorStyle.Transparency)
				end
				if props.onCanvasPositionChanged then
					props.onCanvasPositionChanged(instance)
				end
			end,

			[OnChange "AbsoluteCanvasSize"] = props.onAbsoluteCanvasSizeChanged,
			[OnChange "AbsoluteWindowSize"] = props.onAbsoluteWindowSizeChanged,

			[Children] = scrollingFrameChildren,
		}, scrollingFrameTags))

		-- View props
		local function onStateChanged(state: ControlState)
			controlState:set(state)
			if props.onStateChanged ~= nil then
				props.onStateChanged(state)
			end
		end

		local viewComponentProps = {
			onStateChanged = onStateChanged,
			-- Special check on props.onStateChanged since we don't want state layer on all scrolling frames
			stateLayer = if props.onStateChanged or props.onActivated then props.stateLayer else { affordance = "None" },
			selection = {
				-- We don't want to show selection cursor on ScrollView because ScrollingFrame already has it
				Selectable = false,
			},
			tag = tag  -- Pass the tag computed directly for reactive handling
		}

		local viewProps = Dash.union(props, viewComponentProps)
		viewProps.scroll = nil
		viewProps.layout = nil

		return View(Dash.join(viewProps, {children = {scrollingFrame}}))
	end)
end