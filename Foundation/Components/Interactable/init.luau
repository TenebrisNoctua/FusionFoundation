local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Utility = Foundation.Utility
local TypesSource = Utility.Types

local useGuiControlState = require(Utility.Control.useGuiControlState)
local withDefaults = require(Utility.withDefaults)
local stripProps = require(Utility.stripProps)
local unwrap = require(Utility.unwrap)
local Types = require(TypesSource.Types)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local getOriginalBackgroundStyle = require(script.getOriginalBackgroundStyle)
local getBackgroundStyleWithStateLayer = require(script.getBackgroundStyleWithStateLayer)
local getStateLayerStyle = require(script.getStateLayerStyle)

local StateLayerAffordance = require(Foundation.Enums.StateLayerAffordance)
local StateLayerMode = require(Foundation.Enums.StateLayerMode)
local ControlState = require(Foundation.Enums.ControlState)

--selene: allow(roblox_internal_custom_color)
local DEFAULT_GRAY = Color3.fromRGB(163, 162, 165)

local COMPONENT_ONLY_PROPERTIES = {
	"component",
	"isDisabled",
	"onActivated",
	"onSecondaryActivated",
	"onStateChanged",
	"stateLayer",
	"cursor",
	"cornerRadius"
}

local defaultProps = {
	component = "ImageButton",
	isDisabled = false,
}

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Tag = Fusion.Tag

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type StateLayerMode = StateLayerMode.StateLayerMode
type ControlState = ControlState.ControlState
type StateChangedCallback = Types.StateChangedCallback
type ColorStyle = Types.ColorStyle
type ColorStyleValue = Types.ColorStyleValue

export type InteractableProps = {
	-- The component to render. After deprecation, many `BaseInteractableProps` could support states.
	component: (Instance | string)?,
	
	-- The scope to render the component in.
	scope: Scope,

	-- Interactable passes on any other props to the component
	[any]: any,
} & Types.BaseInteractableProps

return function(interactableProps: InteractableProps)
	local Scope = interactableProps.scope
	local Theme = ThemeProvider()
	
	assert(Scope, "A scope has not been provided for the Interactable component.")
	
	local props = withDefaults(interactableProps, defaultProps)
	local guiObjectRef = Scope:Value(nil)
	
	local controlState = Scope:Value(ControlState.Initialize)
	local realBackgroundStyle = Scope:Value(nil)
	
	local function onStateChanged(newState: ControlState)
		if unwrap(controlState) == ControlState.Default and unwrap(guiObjectRef) ~= nil then
			local guiObjectColor3 = unwrap(guiObjectRef).BackgroundColor3
			local guiObjectTransparency = unwrap(guiObjectRef).BackgroundTransparency
			
			if guiObjectColor3 ~= DEFAULT_GRAY or guiObjectTransparency ~= 0 then
				realBackgroundStyle:set({
					Color3 = guiObjectColor3,
					Transparency = guiObjectTransparency,
				})
			end
		end
		
		controlState:set(newState)
		
		if props.onStateChanged ~= nil then
			props.onStateChanged(newState)
		end
	end
	
	local function getBackgroundStyle(guiState, backgroundStyle: ColorStyleValue): ColorStyleValue
		if
			guiState == ControlState.Initialize
			or guiState == ControlState.Default
			or guiState == ControlState.Disabled
			or (props.stateLayer and props.stateLayer.affordance == StateLayerAffordance.None)
		then
			return backgroundStyle
		end

		local finalBackgroundStyle = {
			Color3 = backgroundStyle.Color3,
			Transparency = backgroundStyle.Transparency,
		}
		
		local realBgStyle = unwrap(realBackgroundStyle)

		if backgroundStyle.Color3 == nil then
			finalBackgroundStyle.Color3 = if realBgStyle
				then realBgStyle.Color3
				else nil
		end
		if backgroundStyle.Transparency == nil then
			finalBackgroundStyle.Transparency = if realBgStyle
				then realBgStyle.Transparency
				else nil
		end
		
		local stateLayerStyle = getStateLayerStyle(props.stateLayer, guiState)
		return getBackgroundStyleWithStateLayer(finalBackgroundStyle, unwrap(stateLayerStyle))
	end
	
	local originalBackgroundStyle = getOriginalBackgroundStyle(props.BackgroundColor3, props.BackgroundTransparency)
	useGuiControlState(Scope, guiObjectRef, onStateChanged)
	
	local interactableComponentProps = {
		BackgroundColor3 = Scope:Computed(function(use: Use, innerScope: Scope)
			local backgroundStyle = getBackgroundStyle(use(controlState), originalBackgroundStyle)
			return backgroundStyle.Color3
		end),
		
		BackgroundTransparency = Scope:Computed(function(use: Use, innerScope: Scope)
			local backgroundStyle = getBackgroundStyle(use(controlState), originalBackgroundStyle)
			return backgroundStyle.Transparency
		end),
		
		Active = not props.isDisabled,
		Interactable = not props.isDisabled,
		SelectionImageObject = props.SelectionImageObject,
		
		[OnEvent "Activated"] = if props.component == "ImageButton" then function(...) 
			local isDisabled = unwrap(props.isDisabled)
			if isDisabled then return end
			if not props.onActivated then return end
			
			props.onActivated(...)
		end else nil,
		
		[OnEvent "SecondaryActivated"] = if props.component == "ImageButton" then function(...) 
			local isDisabled = unwrap(props.isDisabled)
			if isDisabled then return end
			if not props.onSecondaryActivated then return end

			props.onSecondaryActivated(...)
		end else nil
	}
	
	local mergedProps = stripProps(Dash.union(props, interactableComponentProps), COMPONENT_ONLY_PROPERTIES)
	return guiObjectRef:set(Scope:New(props.component)(mergedProps))
end
