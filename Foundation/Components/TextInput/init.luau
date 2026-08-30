local Foundation = script.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local View = require(Components.View)
local Icon = require(Components.Icon)
local IconButton = require(Components.IconButton)
local InputField = require(Components.InputField)
local BaseTextInput = require(Components.BaseTextInput)

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local getInputTextSize = require(Utility.getInputTextSize)
local useTextInputVariants = require(script.useTextInputVariants)
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
type ComputedChild = (scope: Scope) -> Child

type IconTrailing = string | {
	name: string,
	onActivated: () -> (),
}

export type TextInputProps = {
	scope: Scope,
	text: UsedAs<string>,
	-- Image before the input
	leadingIcon: UsedAs<string>?,
	-- Image after the input, can be pressed
	iconTrailing: UsedAs<IconTrailing>?,
	-- Type of text input. Only available for use in descendants of CoreGui.
	textInputType: Enum.TextInputType?,
	-- Ran when return is pressed within the TextInput
	onReturnPressed: (() -> ())?,
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
	size = InputSize.Large,
}

return function(textInputProps: TextInputProps)
	local scope = textInputProps.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the TextInput component.")

	local props = withDefaults(textInputProps, defaultProps)

	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local inputSize = unwrap(props.size, use)
		local inputVariant = unwrap(props.variant, use)

		local variantProps = useTextInputVariants(
			unwrap(theme.Theme), tokens, inputSize, inputVariant,
			nil, false, false
		)

		local horizontalPadding = variantProps.container.horizontalPadding

		local leadingElement: ComputedChild? = nil
		local leadingIcon = unwrap(props.leadingIcon, use)
		if leadingIcon then
			leadingElement = function(leadingScope: Scope): Child
				return View {
					scope = leadingScope,
					tag = "row align-y-center size-0-full auto-x",
					children = {
						Icon {
							scope = leadingScope,
							name = leadingIcon,
							style = variantProps.icon.style,
							size = variantProps.icon.size
						}
					}
				}
			end
		end

		local trailingElement: ComputedChild? = nil
		local iconTrailing = unwrap(props.iconTrailing, use)
		if iconTrailing then
			trailingElement = function(trailingScope: Scope): Child
				local isTable = type(iconTrailing) == "table"
				local trailingChildren = {}
				if isTable and iconTrailing.onActivated then
					table.insert(trailingChildren, IconButton {
						scope = trailingScope,
						onActivated = iconTrailing.onActivated,
						isDisabled = props.isDisabled,
						size = variantProps.icon.size,
						icon = iconTrailing.name,
					})
				else
					table.insert(trailingChildren, Icon {
						scope = trailingScope,
						name = if isTable then iconTrailing.name else iconTrailing,
						style = variantProps.icon.style,
						size = variantProps.icon.size,
					})
				end
				return View {
					scope = trailingScope,
					tag = "row align-y-center size-0-full auto-x",
					children = trailingChildren,
				}
			end
		end

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
			input = function(childScope: Scope, textBoxRef: Types.Value<InternalTextInputRef?>)
				return BaseTextInput {
					scope = childScope,
					textBoxRef = textBoxRef,
					text = props.text,
					hasError = props.hasError,
					isDisabled = props.isDisabled,
					hasClearButton = props.hasClearButton,
					size = props.size,
					variant = props.variant,
					textInputType = props.textInputType,
					focusBehavior = props.focusBehavior,
					horizontalPadding = {
						left = horizontalPadding,
						right = horizontalPadding,
					},
					onChanged = props.onChanged,
					onFocus = props.onFocus,
					onFocusLost = props.onFocusLost,
					onReturnPressed = props.onReturnPressed,
					placeholder = props.placeholder,
					leadingElement = leadingElement,
					trailingElement = trailingElement,
				}
			end
		}
	end)
end