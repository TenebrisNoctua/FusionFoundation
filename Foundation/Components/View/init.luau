local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Utility = Foundation.Utility
local TypesSource = Utility.Types

local Interactable = require(Foundation.Components.Interactable)
local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local useStyleTags = require(Foundation.Providers.ThemeProvider.useStyleTags)

local stripProps = require(Utility.stripProps)
local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local withGuiObjectProps = require(Utility.withGuiObjectProps)
local useDefaultTags = require(Utility.useDefaultTags)
local GuiObjectChildren = require(Utility.GuiObjectChildren)
local Types = require(TypesSource.Types)

local ControlState = require(Foundation.Enums.ControlState)

local COMPONENT_ONLY_PROPERTIES = {
	"GroupTransparency",
	"isDisabled",
	"onActivated",
	"onSecondaryActivated",
	"onStateChanged",
	"selection",
	"testId",
	"stateLayer",
	"cursor",
	"cornerRadius",
	"scale"
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

return function(viewProps: ViewProps): UsedAs<(Frame | CanvasGroup)>
	local Scope = viewProps.scope
	local Theme = ThemeProvider()
	assert(Scope, "A scope has not been provided for the View component.")
	
	local props = withDefaults(viewProps, defaultProps)
	local isInteractable = props.onStateChanged ~= nil or props.onActivated ~= nil or props.onSecondaryActivated ~= nil
	
	local defaultTags = if props.backgroundStyle ~= nil then DEFAULT_TAGS_WITH_BG else DEFAULT_TAGS
	local tagsWithDefaults = useDefaultTags(Scope, props.tag, defaultTags)
	local tag = useStyleTags(Scope, tagsWithDefaults, Theme.AddTags)
	props.tag = unwrap(tag)
	
	local usesCanvasGroup = Scope:Computed(function(use: Use) 
		local value = unwrap(props.GroupTransparency, use)
		return if value then value > 0 else false
	end)
	
	local engineComponentState = Scope:Computed(function(use: Use) 
		if unwrap(usesCanvasGroup, use) then
			if isInteractable and not props.isDisabled then
				-- warn("Some state changes are not supported with GroupTransparency")
			end
			return "CanvasGroup"
		elseif isInteractable then
			return "ImageButton" -- Required for some state changes to work, e.g. enter triggering SelectedPressed
		else
			return "Frame"
		end
	end)
	
	return Scope:Computed(function(use: Use, innerScope: Scope) 
		local engineComponent = unwrap(engineComponentState, use)
		local engineComponentProps = withGuiObjectProps(props, {
			-- When CanvasGroup and Frame support all states, we can remove this.
			AutoButtonColor = if engineComponent == "ImageButton" then false else nil,
			GroupTransparency = if unwrap(usesCanvasGroup, use) then props.GroupTransparency else nil,
			BackgroundTransparency = if props.backgroundStyle then 0 else 1
		})
		
		if isInteractable then
			local viewComponentProps = {
				scope = Scope,
				component = engineComponent,
				onActivated = props.onActivated,
				onSecondaryActivated = props.onSecondaryActivated,
				onStateChanged = props.onStateChanged,
				stateLayer = props.stateLayer,
				isDisabled = props.isDisabled,
				cursor = props.cursor,
				
				[Children] = GuiObjectChildren(props)
			}
			
			local combinedProps = Dash.union(engineComponentProps, viewComponentProps)
			return Scope:Hydrate(Interactable(combinedProps))(stripProps(props, COMPONENT_ONLY_PROPERTIES))
		else
			return Scope:Hydrate(Scope:New(engineComponent)(Dash.join(engineComponentProps, {[Children] = GuiObjectChildren(props)})))(stripProps(props, COMPONENT_ONLY_PROPERTIES))
		end
	end)
end

