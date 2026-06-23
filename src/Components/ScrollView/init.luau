local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Utility = Foundation.Utility
local TypesSource = Utility.Types

local ScrollingFrame = require(script.ScrollingFrame)
local View = require(script.Parent.View)

local withDefaults = require(Utility.withDefaults)
local themeProvider = require(Utility.themeProvider)
local unwrap = require(Utility.unwrap)
local Types = require(TypesSource.Types)

local Visibility = require(Foundation.Enums.Visibility)
local ControlState = require(Foundation.Enums.ControlState)

local Children = Fusion.Children
local OnChange = Fusion.OnChange
local Tag = Fusion.Tag

local defaultProps = {
	layout = {
		SortOrder = Enum.SortOrder.LayoutOrder,
	} :: ListLayout,
	scroll = {
		scrollBarVisibility = Visibility.Auto,
	} :: Scroll,
	AutoLocalize = false,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	isDisabled = false,
	testId = "--foundation-scroll-view",
}

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


return function(scrollViewProps: ScrollViewProps)
	local Scope = scrollViewProps.scope
	local Theme = themeProvider()
	
	assert(Scope, "A scope has not been provided for the ScrollView component.")
	
	local props = withDefaults(scrollViewProps, defaultProps)
	local controlState = Scope:Value(ControlState.Initialize)
	
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

		tag = props.tag,
	}
	
	local viewProps = Dash.union(props, viewComponentProps)
	viewProps.scroll = nil
	viewProps.layout = nil
	
	local listChildren = {
		ListLayout = Scope:New "UIListLayout" {
			FillDirection = props.layout.FillDirection,
			ItemLineAlignment = props.layout.ItemLineAlignment,
			HorizontalAlignment = props.layout.HorizontalAlignment,
			HorizontalFlex = props.layout.HorizontalFlex,
			VerticalAlignment = props.layout.VerticalAlignment,
			VerticalFlex = props.layout.VerticalFlex,
			Padding = props.layout.Padding,
			SortOrder = props.layout.SortOrder,
			Wraps = props.layout.Wraps,
		}
	}
	
	return View(Dash.join(viewProps, {children = {ScrollingFrame {
		scope = Scope,
		controlState = controlState,
		selection = props.selection,
		scrollBarVisibility = props.scroll.scrollBarVisibility,
		onCanvasPositionChanged = props.onCanvasPositionChanged,
		onAbsoluteCanvasSizeChanged = props.onAbsoluteCanvasSizeChanged,
		onAbsoluteWindowSizeChanged = props.onAbsoluteWindowSizeChanged,

		-- Scrolling props
		AutomaticSize = props.scroll.AutomaticSize,
		AutomaticCanvasSize = props.scroll.AutomaticCanvasSize,
		CanvasSize = props.scroll.CanvasSize,
		ClipsDescendants = false,
		ScrollingDirection = props.scroll.ScrollingDirection,
		ScrollingEnabled = props.scroll.ScrollingEnabled,
		VerticalScrollBarInset = props.scroll.VerticalScrollBarInset,
		HorizontalScrollBarInset = props.scroll.HorizontalScrollBarInset,
		
		children = if props.children
			and typeof(props.children) == "table"
			and props.layout ~= nil
			and props.layout.FillDirection ~= nil
		then
			Dash.union(listChildren, props.children)
		else
			props.children
	}}}))
end