local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local getStateLayerStyle = require(script.getStateLayerStyle)
local getOriginalBackgroundStyle = require(script.getOriginalBackgroundStyle)

local unwrap = require(Utility.unwrap)
local isState = require(Utility.isState)
local stripProps = require(Utility.stripProps)
local blendColors = require(Utility.blendColors)
local withDefaults = require(Utility.withDefaults)
local useGuiControlState = require(Utility.Control.useGuiControlState)
local Types = require(Utility.Types)

local StateLayerAffordance = require(Enums.StateLayerAffordance)
local StateLayerMode = require(Enums.StateLayerMode)
local ControlState = require(Enums.ControlState)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

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
	isDisabled = false
}

local OnEvent = Fusion.OnEvent

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type StateLayerMode = StateLayerMode.StateLayerMode
type StateLayerAffordance = StateLayerAffordance.StateLayerAffordance
type ControlState = ControlState.ControlState
type StateChangedCallback = Types.StateChangedCallback
type ColorStyle = Types.ColorStyle
type ColorStyleValue = Types.ColorStyleValue

export type InteractableProps = {
	-- The scope to render the component in.
	scope: Scope,
	-- The component to render. After deprecation, many `BaseInteractableProps` could support states.
	component: (Instance | string)?,
	-- Interactable passes on any other props to the component
	[any]: any
} & Types.BaseInteractableProps

return function(interactableProps: InteractableProps)
	local scope = interactableProps.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the Interactable component.")

	local props = withDefaults(interactableProps, defaultProps)
	local guiObjectRef = scope:Value(nil :: GuiObject)
	local realBackgroundStyle = scope:Value(nil :: ColorStyle)
	local controlState = scope:Value(ControlState.Initialize)
	
	local onActivatedProp = props.onActivated
	local onStateChangedProp = props.onStateChanged
	local onSecondaryActivatedProp = props.onSecondaryActivated
	
	local isDisabled = props.isDisabled
	local isDisabledAState = isState(isDisabled)
	
	local function onStateChanged(newState: ControlState)
		if unwrap(controlState) == ControlState.Default and unwrap(guiObjectRef) ~= nil then
			local guiObjectColor3 = unwrap(guiObjectRef):GetStyled("BackgroundColor3")
			local guiObjectTransparency = unwrap(guiObjectRef):GetStyled("BackgroundTransparency")

			if guiObjectColor3 ~= DEFAULT_GRAY or guiObjectTransparency ~= 0 then
				realBackgroundStyle:set({
					Color3 = guiObjectColor3,
					Transparency = guiObjectTransparency,
				})
			end
		end

		controlState:set(newState)

		if onStateChangedProp ~= nil then
			onStateChangedProp(newState)
		end
	end
	
	local function getBackgroundStyle(guiState: ControlState, backgroundStyle: ColorStyleValue, mode: StateLayerMode?, affordance: StateLayerAffordance?): ColorStyleValue
		if
			guiState == ControlState.Initialize
			or guiState == ControlState.Default
			or guiState == ControlState.Disabled
			or affordance == StateLayerAffordance.None
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
		
		local stateLayerStyle = getStateLayerStyle(unwrap(theme.Tokens), mode, guiState)
		return blendColors(finalBackgroundStyle, stateLayerStyle)
	end
	
	local originalBackgroundStyle = scope:Computed(function(use: Use) 
		return getOriginalBackgroundStyle(unwrap(props.BackgroundColor3, use), unwrap(props.BackgroundTransparency, use))
	end)
	
	local isDisabledProp = scope:Computed(function(use: Use) 
		return not unwrap(isDisabled, use)
	end)
	
	useGuiControlState(scope, guiObjectRef, onStateChanged)
	
	local interactableComponentProps = {}
	local hasExplicitBackground = unwrap(props.BackgroundColor3) ~= nil and unwrap(props.BackgroundTransparency) ~= nil
	
	--[[
		We replicate the React behavior of skipping nil values here.
		If the component has been provided the necessary style values, we just use computeds.
		Otherwise, we must use an observer to manually set the properties by using the guiObjectRef.
		
		We do this because computeds can return nil if there are no style values provided.
		We could get around this issue by providing default values through getOriginalBackgroundStyle,
		but that may override the style tokens set by tags.
	]]

	if hasExplicitBackground then
		interactableComponentProps.BackgroundColor3 = scope:Computed(function(use: Use, innerScope: Scope)
			local mode = if props.stateLayer then props.stateLayer.mode else nil
			local affordance = if props.stateLayer then props.stateLayer.affordance else nil
			local backgroundStyle = getBackgroundStyle(unwrap(controlState, use), unwrap(originalBackgroundStyle, use), mode, affordance)
			return backgroundStyle.Color3
		end)

		interactableComponentProps.BackgroundTransparency = scope:Computed(function(use: Use, innerScope: Scope)
			local mode = if props.stateLayer then props.stateLayer.mode else nil
			local affordance = if props.stateLayer then props.stateLayer.affordance else nil
			local backgroundStyle = getBackgroundStyle(unwrap(controlState, use), unwrap(originalBackgroundStyle, use), mode, affordance)
			return backgroundStyle.Transparency
		end)
	else
		local bgStyleComputed = scope:Computed(function(use: Use)
			local mode = if props.stateLayer then props.stateLayer.mode else nil
			local affordance = if props.stateLayer then props.stateLayer.affordance else nil
			return getBackgroundStyle(unwrap(controlState, use), unwrap(originalBackgroundStyle, use), mode, affordance)
		end)

		scope:Observer(bgStyleComputed):onChange(function()
			local guiObject = unwrap(guiObjectRef)
			if not guiObject then return end

			local resultStyle = unwrap(bgStyleComputed)
			local realBgStyle = unwrap(realBackgroundStyle)

			local color3 = resultStyle.Color3 or (if realBgStyle then realBgStyle.Color3 else nil)
			if color3 then
				guiObject.BackgroundColor3 = color3
			end

			local transparency = resultStyle.Transparency or (if realBgStyle then realBgStyle.Transparency else nil)
			if transparency then
				guiObject.BackgroundTransparency = transparency
			end
		end)
	end

	interactableComponentProps.Active = if isDisabledAState then isDisabledProp else not isDisabled
	interactableComponentProps.Interactable = if isDisabledAState then isDisabledProp else not isDisabled
	interactableComponentProps.SelectionImageObject = props.SelectionImageObject

	interactableComponentProps[OnEvent "Activated"] = if props.component == "ImageButton" then function(...)
		if unwrap(isDisabled) then return end
		if not onActivatedProp then return end
		onActivatedProp(...)
	end else nil

	interactableComponentProps[OnEvent "SecondaryActivated"] = if props.component == "ImageButton" then function(...)
		if unwrap(isDisabled) then return end
		if not onSecondaryActivatedProp then return end
		onSecondaryActivatedProp(...)
	end else nil
	
	local mergedProps = stripProps(Dash.union(props, interactableComponentProps), COMPONENT_ONLY_PROPERTIES)
	return guiObjectRef:set(scope:New(props.component)(mergedProps))
end