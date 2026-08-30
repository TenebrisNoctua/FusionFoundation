local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Interactable = require(Components.Interactable)

local unwrap = require(Utility.unwrap)
local stripProps = require(Utility.stripProps)
local withDefaults = require(Utility.withDefaults)
local useDefaultTags = require(Utility.useDefaultTags)
local withGuiObjectProps = require(Utility.withGuiObjectProps)
local Types = require(Utility.Types)
local GuiObjectChildren = require(Utility.GuiObjectChildren)

local ControlState = require(Enums.ControlState)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local useStyleTags = require(Foundation.Providers.ThemeProvider.useStyleTags)

local COMPONENT_ONLY_PROPERTIES = {
	"GroupTransparency",
	"isDisabled",
	"onActivated",
	"onSecondaryActivated",
	"onStateChanged",
	"selection",
	"stateLayer",
	"cursor",
	"cornerRadius",
	"scale",
	"flexItem"
}

local defaultProps = {
	layout = {
		SortOrder = Enum.SortOrder.LayoutOrder,
	} :: ListLayout,
	AutoLocalize = false,
	BorderSizePixel = 0,
	isDisabled = false
}

local DEFAULT_TAGS = "gui-object-defaults"
local DEFAULT_TAGS_WITH_BG = `{DEFAULT_TAGS} x-default-transparency`

local Children = Fusion.Children

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type ControlState = ControlState.ControlState
type StateChangedCallback = Types.StateChangedCallback
type ListLayout = Types.ListLayout
type GuiObjectProps = Types.GuiObjectProps
type CommonProps = Types.CommonProps
export type ViewProps = Types.ViewProps

return function(viewProps: ViewProps): UsedAs<Frame | CanvasGroup>
	local scope = viewProps.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the View component.")
	
	local props = withDefaults(viewProps, defaultProps)
	local defaultTags = if props.backgroundStyle ~= nil then DEFAULT_TAGS_WITH_BG else DEFAULT_TAGS
	
	return scope:Computed(function(use: Use, innerScope: Scope)
		local tagsWithDefaults = useDefaultTags(innerScope, props.tag, defaultTags)
		local tag = useStyleTags(innerScope, tagsWithDefaults, theme.AddTags)
		props.tag = tag
		
		local isInteractable = props.onStateChanged ~= nil or props.onActivated ~= nil or props.onSecondaryActivated ~= nil
		
		local usesCanvasGroup = innerScope:Computed(function(use: Use) 
			local value = unwrap(props.GroupTransparency, use)
			return if value then value > 0 else false
		end)

		local engineComponentState = innerScope:Computed(function(use: Use) 
			if unwrap(usesCanvasGroup, use) then
				if isInteractable and not props.isDisabled then
					warn("[FusionFoundation]: Some state changes are not supported with GroupTransparency")
				end
				return "CanvasGroup"
			elseif isInteractable then
				return "ImageButton" -- Required for some state changes to work, e.g. enter triggering SelectedPressed
			else
				return "Frame"
			end
		end)
		
		if type(props.children) == "function" then
			props.children = props.children(innerScope)
		end
		
		local engineComponent = unwrap(engineComponentState, use)
		local engineComponentProps = withGuiObjectProps(props, {
			-- When CanvasGroup and Frame support all states, we can remove this.
			AutoButtonColor = if engineComponent == "ImageButton" then false else nil,
			GroupTransparency = if unwrap(usesCanvasGroup, use) then props.GroupTransparency else nil
		})
		
		engineComponentProps.Name = props.Name
		engineComponentProps[Children] = GuiObjectChildren(props)
		
		if isInteractable then
			engineComponentProps.scope = scope
			engineComponentProps.component = engineComponent
			engineComponentProps.onActivated = props.onActivated
			engineComponentProps.onSecondaryActivated = props.onSecondaryActivated
			engineComponentProps.onStateChanged = props.onStateChanged
			engineComponentProps.stateLayer = props.stateLayer
			engineComponentProps.isDisabled = props.isDisabled
			engineComponentProps.cursor = props.cursor
			return scope:Hydrate(Interactable(engineComponentProps))(stripProps(props, COMPONENT_ONLY_PROPERTIES))
		end
		
		return scope:Hydrate(scope:New(engineComponent)(engineComponentProps))(stripProps(props, COMPONENT_ONLY_PROPERTIES))
	end)
end