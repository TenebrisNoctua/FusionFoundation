local Foundation = script.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local InputField = require(Components.InputField)
local BaseTextInput = require(Components.BaseTextInput)

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local getInputTextSize = require(Utility.getInputTextSize)
local useTextInputVariants = require(Components.TextInput.useTextInputVariants)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)
local InputVariant = require(Enums.InputVariant)
local InputFocusBehavior = require(Enums.InputFocusBehavior)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

type InputSize = InputSize.InputSize
type InputVariant = InputVariant.InputVariant
type InputFocusBehavior = InputFocusBehavior.InputFocusBehavior
type TextInputRef = Types.TextInputRef
type InternalTextInputRef = Types.InternalTextInputRef

export type TextAreaProps = {
	scope: Scope,
	text: UsedAs<string>,
	-- Number of lines shown at once
	numLines: UsedAs<number>?,
	-- Width of the input
	width: UsedAs<UDim>?,
	-- Label text
	label: UsedAs<string>?,
	-- Size of the input
	size: UsedAs<InputSize>?,
	-- Style variant
	variant: UsedAs<InputVariant>?,
	-- Whether the input has an error
	hasError: UsedAs<boolean>?,
	-- Whether the input is disabled
	isDisabled: UsedAs<boolean>?,
	-- Whether the input is required
	isRequired: boolean?,
	-- Whether to show the clear button
	hasClearButton: UsedAs<boolean>?,
	-- Focus behavior
	focusBehavior: UsedAs<InputFocusBehavior>?,
	-- Placeholder text
	placeholder: UsedAs<string>?,
	-- Hint text
	hint: UsedAs<string>?,
	-- Called when text changes
	onChanged: (text: string) -> (),
	-- Called when focus is gained
	onFocus: (() -> ())?,
	-- Called when focus is lost
	onFocusLost: ((inputObject: InputObject?) -> ())?,
	-- Text box ref
	textBoxRef: UsedAs<TextInputRef?>?,
} & Types.SelectionProps & Types.CommonProps

local defaultProps = {
	size = InputSize.Medium,
	numLines = 3,
}

return function(textAreaProps: TextAreaProps)
	local scope = textAreaProps.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the TextArea component.")

	local props = withDefaults(textAreaProps, defaultProps)

	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local inputSize = unwrap(props.size, use)
		local inputVariant = unwrap(props.variant, use)

		local variantProps = useTextInputVariants(
			unwrap(theme.Theme), tokens, inputSize, inputVariant,
			nil, false, false
		)

		local horizontalPadding = variantProps.container.horizontalPadding

		return InputField {
			scope = innerScope,
			width = props.width,
			label = props.label,
			size = getInputTextSize(inputSize),
			isRequired = props.isRequired,
			isDisabled = props.isDisabled,
			hasError = props.hasError,
			hint = props.hint,
			textBoxRef = props.textBoxRef,
			input = function(childScope: Scope, textBoxRef: UsedAs<InternalTextInputRef?>)
				return BaseTextInput {
					scope = childScope,
					textBoxRef = textBoxRef,
					text = props.text,
					hasError = props.hasError,
					isDisabled = props.isDisabled,
					hasClearButton = props.hasClearButton,
					size = props.size,
					variant = props.variant,
					numLines = props.numLines,
					focusBehavior = props.focusBehavior,
					horizontalPadding = {
						left = horizontalPadding,
						-- UIBLOX-2919: Share token used for scrollbar thickness with ScrollView
						right = horizontalPadding - UDim.new(0, tokens.Size.Size_150),
					},
					onChanged = props.onChanged,
					onFocus = props.onFocus,
					onFocusLost = props.onFocusLost,
					placeholder = props.placeholder,
				}
			end
		}
	end)
end