local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Utility = Foundation.Utility

local getOriginalBackgroundStyle = require(script.getOriginalBackgroundStyle)
local getStateLayerStyle = require(script.getStateLayerStyle)

local useGuiControlState = require(Utility.Control.useGuiControlState)
local withDefaults = require(Utility.withDefaults)
local blendColors = require(Utility.blendColors)
local stripProps = require(Utility.stripProps)
local isState = require(Utility.isState)
local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StateLayerAffordance = require(Foundation.Enums.StateLayerAffordance)
local StateLayerMode = require(Foundation.Enums.StateLayerMode)
local ControlState = require(Foundation.Enums.ControlState)

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

--[[
	The behavior for isDisabled can depend if whether or not it's a state object.
	If it's a plain boolean, then isDisabled is used as one would expect, boolean true disables the component.
	However, if it's a state object, then we must assume the opposite: boolean false disables the component.
	This is due to us assigning the state object given through isDisabled to Active and Interactable properties.
]]
local function getIsDisabled(isDisabled: UsedAs<boolean>, isDisabledAState: boolean)
	local isDisabledValue = unwrap(isDisabled)
	if not isDisabledAState then return isDisabledValue end
	return not isDisabledValue
end

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
	-- The component to render. After deprecation, many `BaseInteractableProps` could support states.
	component: (Instance | string)?,
	
	-- The scope to render the component in.
	scope: Scope,

	-- Interactable passes on any other props to the component
	[any]: any,
} & Types.BaseInteractableProps

return function(interactableProps: InteractableProps)
	local Scope = interactableProps.scope
	assert(Scope, "A scope has not been provided for the Interactable component.")

	local props = withDefaults(interactableProps, defaultProps)
	
	local guiObjectRef = Scope:Value(nil :: GuiObject)
	local realBackgroundStyle = Scope:Value(nil :: ColorStyle)
	local controlState = Scope:Value(ControlState.Initialize)
	
	local isDisabledAState = isState(props.isDisabled)
	
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

		if props.onStateChanged ~= nil then
			props.onStateChanged(newState)
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

		local stateLayerStyle = getStateLayerStyle(mode, guiState)
		return blendColors(finalBackgroundStyle, stateLayerStyle)
	end
	
	local originalBackgroundStyle = Scope:Computed(function(use: Use) 
		return getOriginalBackgroundStyle(unwrap(props.BackgroundColor3, use), unwrap(props.BackgroundTransparency, use))
	end)
	
	useGuiControlState(Scope, guiObjectRef, onStateChanged)
	
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
		interactableComponentProps.BackgroundColor3 = Scope:Computed(function(use: Use, innerScope: Scope)
			local mode = if props.stateLayer then props.stateLayer.mode else nil
			local affordance = if props.stateLayer then props.stateLayer.affordance else nil
			local backgroundStyle = getBackgroundStyle(unwrap(controlState, use), unwrap(originalBackgroundStyle, use), mode, affordance)
			return backgroundStyle.Color3
		end)

		interactableComponentProps.BackgroundTransparency = Scope:Computed(function(use: Use, innerScope: Scope)
			local mode = if props.stateLayer then props.stateLayer.mode else nil
			local affordance = if props.stateLayer then props.stateLayer.affordance else nil
			local backgroundStyle = getBackgroundStyle(unwrap(controlState, use), unwrap(originalBackgroundStyle, use), mode, affordance)
			return backgroundStyle.Transparency
		end)
	else
		local bgStyleComputed = Scope:Computed(function(use: Use)
			local mode = if props.stateLayer then props.stateLayer.mode else nil
			local affordance = if props.stateLayer then props.stateLayer.affordance else nil
			return getBackgroundStyle(unwrap(controlState, use), unwrap(originalBackgroundStyle, use), mode, affordance)
		end)

		Scope:Observer(bgStyleComputed):onChange(function()
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

	interactableComponentProps.Active = if isDisabledAState then props.isDisabled else not props.isDisabled
	interactableComponentProps.Interactable = if isDisabledAState then props.isDisabled else not props.isDisabled
	interactableComponentProps.SelectionImageObject = props.SelectionImageObject

	interactableComponentProps[OnEvent "Activated"] = if props.component == "ImageButton" then function(...)
		if getIsDisabled(props.isDisabled, isDisabledAState) then return end
		if not props.onActivated then return end
		props.onActivated(...)
	end else nil

	interactableComponentProps[OnEvent "SecondaryActivated"] = if props.component == "ImageButton" then function(...)
		if getIsDisabled(props.isDisabled, isDisabledAState) then return end
		if not props.onSecondaryActivated then return end
		props.onSecondaryActivated(...)
	end else nil
	
	local mergedProps = stripProps(Dash.union(props, interactableComponentProps), COMPONENT_ONLY_PROPERTIES)
	return guiObjectRef:set(Scope:New(props.component)(mergedProps))
end