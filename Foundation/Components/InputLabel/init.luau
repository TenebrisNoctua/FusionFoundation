--!nonstrict

local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Text = require(Foundation.Components.Text)
local Translator = require(Foundation.Utility.Localization.Translator)

local withCommonProps = require(Foundation.Utility.withCommonProps)
local withDefaults = require(Foundation.Utility.withDefaults)
local unwrap = require(Foundation.Utility.unwrap)
local stripProps = require(Foundation.Utility.stripProps)
local Types = require(Foundation.Utility.Types.Types)

local StateLayerAffordance = require(Foundation.Enums.StateLayerAffordance)
local ControlState = require(Foundation.Enums.ControlState)
local InputLabelSize = require(Foundation.Enums.InputLabelSize)

local COMPONENT_ONLY_PROPERTIES = {
	"stateLayer",
	"selection",
	"type",
	"size",
	"isRequired",
	"isDisabled",
	"textStyle",
	"onHover",
	"onActivated",
	"Text" -- We don't want this to be hydrated and mess up the states.
}

local REQUIRED_INDICATOR = "*"
local defaultProps = {
	size = InputLabelSize.Medium :: InputLabelSize
}

local function labelText(text: string, isRequired: boolean?): string
	if not isRequired then
		return text
	end

	return if isRequired
		then text .. REQUIRED_INDICATOR
		else Translator:FormatByKey("CommonUI.Controls.Input.Optional", { inputLabel = text })
end

type UsedAs<T> = Types.UsedAs<T>
type CanBeComputed<T> = (Types.Computed<T> | T)

type Scope = Types.Scope
type Use = Types.Use

type ControlState = ControlState.ControlState
type InputLabelSize = InputLabelSize.InputLabelSize

export type InputLabelProps = {
	-- The scope the component will be created in
	scope: Scope,
	-- Optional text style override
	textStyle: Types.ColorStyle?,
	-- Whether the input is required or not. Leave nil for the majority case
	isRequired: boolean?,
	-- Whether the input is disabled
	isDisabled: boolean?,
	-- Size of the input label
	size: InputLabelSize?,
	-- Callback for when the input label is activated.
	-- This should trigger the activation of the associated input button.
	onActivated: () -> ()?,
	-- Callback for when the input label is hovered over.
	-- This should trigger the hover state of the associated input button.
	onHover: (boolean) -> ()?,
	-- Whether the input label should be rich text or not
	RichText: boolean?,
	-- Determines the string rendered by the UI element
	Text: string,
} & Types.CommonProps

return function(inputLabelProps: InputLabelProps)
	local Scope = inputLabelProps.scope
	assert(Scope, "A scope has not been provided for the InputLabel component.")
	
	local props = withDefaults(inputLabelProps, defaultProps)
	
	return Scope:Computed(function(use: Use, innerScope: Scope)
		local function onStateChanged(newState: ControlState)
			local hoverCallback = unwrap(props.onHover, use)
			if not hoverCallback then return end
			return props.onHover(newState == ControlState.Hover)
		end
		
		local componentProperties = withCommonProps(props, {
			scope = innerScope,
			Text = innerScope:Computed(function(use: Use) 
				local newText = labelText(unwrap(props.Text, use), unwrap(props.isRequired, use))
				return newText
			end),
			RichText = props.RichText,

			-- InputLabel is not selectable because the associated
			-- input button is what we want to focus with directional input
			selection = {
				Selectable = false,
			},
			onActivated = if not props.isDisabled then props.onActivated else nil,
			onStateChanged = if not props.isDisabled then onStateChanged else nil,
			stateLayer = { affordance = StateLayerAffordance.None },
			textStyle = props.textStyle,
			tag = {
				["size-0 auto-xy text-align-x-left text-align-y-top"] = true,
				["content-muted"] = props.isDisabled,
				["content-default"] = not props.isDisabled,
				["text-title-small"] = props.size == InputLabelSize.Small,
				["text-title-medium"] = props.size == InputLabelSize.Medium,
				["text-title-large"] = props.size == InputLabelSize.Large,
			}
		})
		
		return innerScope:Hydrate(unwrap(Text(componentProperties)))(stripProps(props, COMPONENT_ONLY_PROPERTIES))
	end)
end