local Foundation = script.Parent.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local BaseInput = require(Components.BaseInput)
local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)

local useRadioGroup = require(script.Parent.useRadioGroup)
local useRadioGroupItemVariants = require(script.useRadioGroupItemVariants)

local InputSize = require(Enums.InputSize)
local InputPlacement = require(Enums.InputPlacement)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local Constants = require(Foundation.Constants)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type InputSize = InputSize.InputSize
type InputPlacement = InputPlacement.InputPlacement

export type RadioGroupItemProps = {
	-- A unique value for the radio item.
	value: UsedAs<string>,
	-- Whether the radio item is disabled. When `true`, the group's onValueChanged will
	-- not be invoked, even if the user interacts with the radio item.
	isDisabled: UsedAs<boolean>?,
	-- A label for the radio item. When nil, defaults to `value`.
	label: UsedAs<string>?,
	size: UsedAs<InputSize>?,
	placement: UsedAs<InputPlacement>?
} & Types.CommonProps

local defaultProps = {
	size = InputSize.Medium,
	isDisabled = false,
	placement = InputPlacement.Start
}

return function(radioGroupItemProps: RadioGroupItemProps)
	local scope = radioGroupItemProps.scope
	assert(scope, "A scope has not been provided for the RadioGroupItem component.")

	local theme = ThemeProvider()
	local props = withDefaults(radioGroupItemProps, defaultProps)
	local radioGroupContext = useRadioGroup()

	local function onActivated()
		radioGroupContext.onValueChanged(unwrap(props.value))
	end

	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local size = unwrap(props.size, use)
		local placement = unwrap(props.placement, use)
		local value = unwrap(props.value, use)
		local label = unwrap(props.label, use) or value
		local isChecked = unwrap(radioGroupContext.value, use) == value

		local variantProps = useRadioGroupItemVariants(unwrap(theme.Theme, use), tokens, size)

		return BaseInput(withCommonProps(props, {
			scope = innerScope,
			isChecked = isChecked,
			isDisabled = props.isDisabled,
			onActivated = onActivated,
			label = {
				text = label,
				position = Constants.INPUT_PLACEMENT_TO_LABEL_ALIGNMENT[placement]
			},
			customVariantProps = variantProps.input,
			size = size,
			Selectable = radioGroupContext.Selectable,
			children = if isChecked
				then function(childScope: Scope)
					return View {
						scope = childScope,
						tag = variantProps.checkmark.tag,
						backgroundStyle = variantProps.checkmark.style
					}
				end
				else nil
		}))
	end)
end
