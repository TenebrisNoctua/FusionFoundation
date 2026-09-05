local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useCheckboxVariants = require(script.useCheckboxVariants)

local Text = require(Components.Text)
local BaseInput = require(Components.BaseInput)

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)
local InputPlacement = require(Enums.InputPlacement)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local Constants = require(Foundation.Constants)

local defaultProps = {
	size = InputSize.Medium,
	placement = InputPlacement.Start,
	Selectable = true
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type InputSize = InputSize.InputSize
type InputPlacement = InputPlacement.InputPlacement

export type CheckboxProps = {
	-- The scope the component will be created in.
	scope: Scope,
	-- Whether the checkbox is currently checked. If left `nil`, the checkbox is
	-- uncontrolled and manages its own state.
	isChecked: UsedAs<boolean>?,
	-- Whether the checkbox is disabled. When `true`, `onActivated` will not be
	-- invoked, even if the user interacts with the checkbox.
	isDisabled: UsedAs<boolean>?,
	-- A visual property that, if true, will show an indeterminate state over the
	-- checkbox.
	isIndeterminate: UsedAs<boolean>?,
	-- A function that will be called whenever the checkbox is activated. Receives
	-- the new value of the checkbox.
	onActivated: ((boolean) -> ())?,
	-- A label for the checkbox. To omit, set it to an empty string.
	label: UsedAs<string>,
	size: UsedAs<InputSize>?,
	placement: UsedAs<InputPlacement>?,
} & Types.SelectionProps & Types.CommonProps

return function(checkboxProps: CheckboxProps)
	local scope = checkboxProps.scope
	assert(scope, "A scope has not been provided for the Checkbox component.")

	local theme = ThemeProvider()
	local props = withDefaults(checkboxProps, defaultProps)
	
	local isCheckedInternal = scope:Value(unwrap(props.isChecked) or false)
	local externalIsChecked = scope:Computed(function(use: Use)
		return unwrap(props.isChecked, use)
	end)
	
	scope:Observer(externalIsChecked):onChange(function()
		local newValue = unwrap(externalIsChecked)
		if newValue ~= nil then
			isCheckedInternal:set(newValue)
		end
	end)

	local function onActivated(newValue: boolean)
		if unwrap(props.isChecked) == nil then
			isCheckedInternal:set(newValue)
		end
		if props.onActivated then
			props.onActivated(newValue)
		end
	end

	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local size = unwrap(props.size, use)
		local placement = unwrap(props.placement, use)
		local isChecked = unwrap(isCheckedInternal, use)
		local isIndeterminate = unwrap(props.isIndeterminate, use) or false

		local variantProps = useCheckboxVariants(unwrap(theme.Theme, use), tokens, size)

		return BaseInput(withCommonProps(props, {
			scope = innerScope,
			isChecked = isChecked,
			isIndeterminate = isIndeterminate,
			isDisabled = props.isDisabled,
			onActivated = onActivated,
			label = {
				text = props.label,
				position = Constants.INPUT_PLACEMENT_TO_LABEL_ALIGNMENT[placement],
			},
			customVariantProps = variantProps.input,
			size = size,
			Selectable = props.Selectable,
			NextSelectionUp = props.NextSelectionUp,
			NextSelectionDown = props.NextSelectionDown,
			NextSelectionLeft = props.NextSelectionLeft,
			NextSelectionRight = props.NextSelectionRight,
			children = if isChecked or isIndeterminate
				then function(childScope: Scope)
					return Text {
						scope = childScope,
						Text = if isIndeterminate then BuilderIcons.Icon.Minus else BuilderIcons.Icon.Check,
						fontStyle = {
							Font = BuilderIcons.Font[BuilderIcons.IconVariant.Filled],
						},
						TextScaled = true,
						tag = variantProps.checkmark.tag,
					}
				end
				else nil
		}))
	end)
end
