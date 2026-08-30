local Foundation = script.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local View = require(Components.View)
local InputLabel = require(Components.InputLabel)
local HintText = require(Components.HintText)

local unwrap = require(Utility.unwrap)
local isState = require(Utility.isState)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local useScaledValue = require(Utility.useScaledValue)
local Types = require(Utility.Types)

local InputLabelSize = require(Enums.InputLabelSize)

local Constants = require(Foundation.Constants)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type InputLabelSize = InputLabelSize.InputLabelSize
type InternalTextInputRef = Types.InternalTextInputRef
type TextInputRef = Types.TextInputRef

local defaultProps = {
	size = InputLabelSize.Small
}

type InputFieldProps = {
	scope: Scope,
	size: UsedAs<InputLabelSize>?,
	hasError: UsedAs<boolean>?,
	-- Whether the input is disabled
	isDisabled: UsedAs<boolean>?,
	-- Whether the input is required, true for "*", false for " (optional)", nil for nothing
	isRequired: boolean?,
	-- Input label text. To omit, set to an empty string
	label: UsedAs<string>,
	-- Constructs the actual input (TextInput/SearchInput/TextArea) that
	-- goes in the wrapper slot between the label and the hint
	input: (scope: Scope, textBoxRef: UsedAs<InternalTextInputRef?>) -> Instance,
	-- If given a state, InputField mirrors the wrapped
	-- input's ref into it once available
	textBoxRef: UsedAs<TextInputRef?>?,
	-- Hint text below the input, is red on error
	hint: UsedAs<string>?,
	width: UsedAs<UDim>?
} & Types.CommonProps

return function(inputFieldProps: InputFieldProps)
	local scope = inputFieldProps.scope
	assert(scope, "A scope has not been provided for the InputField component.")

	local props = withDefaults(inputFieldProps, defaultProps)
	local textBoxRef = scope:Value(nil :: InternalTextInputRef?)

	local function focusTextBox()
		local ref = unwrap(textBoxRef)
		if ref and not ref.getIsFocused() then
			ref.focus()
		end
	end

	if isState(props.textBoxRef) then
		scope:Observer(textBoxRef):onChange(function()
			local ref = unwrap(textBoxRef)
			if not ref then return end
			props.textBoxRef:set({
				focus = ref.focus,
				releaseFocus = ref.releaseFocus,
				getIsFocused = ref.getIsFocused,
				getCursorPosition = ref.getCursorPosition,
				getSelectionStart = ref.getSelectionStart,
				setCursorPosition = ref.setCursorPosition,
				setSelectionStart = ref.setSelectionStart,
			})
		end)
	end

	return scope:Computed(function(use: Use, innerScope: Scope)
		local width = unwrap(props.width, use)
		local defaultWidth = useScaledValue(Constants.DEFAULT_INPUT_FIELD_WIDTH_PIXELS, use)
		local label = unwrap(props.label, use)
		local hasLabel = #label > 0
		local hint = unwrap(props.hint, use)

		local children: { [string]: any } = {
			InputWrapper = View {
				scope = innerScope,
				tag = "size-full-0 auto-y",
				LayoutOrder = 2,
				children = function(childScope: Scope)
					return { props.input(childScope, textBoxRef) }
				end
			},
		}

		if hasLabel then
			children.Label = InputLabel {
				scope = innerScope,
				Text = label,
				size = props.size,
				isRequired = props.isRequired,
				isDisabled = props.isDisabled,
				onActivated = focusTextBox,
				LayoutOrder = 1,
			}
		end

		if hint then
			children.Hint = HintText {
				scope = innerScope,
				text = hint,
				hasError = props.hasError,
				isDisabled = props.isDisabled,
				LayoutOrder = 3,
			}
		end

		return View(withCommonProps(props, {
			Name = "InputField",
			scope = innerScope,
			Size = if width then UDim2.new(width, UDim.new(0, 0)) else UDim2.fromOffset(defaultWidth, 0),
			tag = "col gap-small auto-y",
			children = children
		}))
	end)
end
