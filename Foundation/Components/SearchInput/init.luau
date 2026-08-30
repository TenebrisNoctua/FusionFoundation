local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local View = require(Components.View)
local Icon = require(Components.Icon)
local BaseTextInput = require(Components.BaseTextInput)

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local useScaledValue = require(Utility.useScaledValue)
local useTextInputVariants = require(Components.TextInput.useTextInputVariants)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)
local InputVariant = require(Enums.InputVariant)
local Radius = require(Enums.Radius)
local SearchInputShape = require(Enums.SearchInputShape)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local Constants = require(Foundation.Constants)

local BuilderIcons = PackageManager.getPackage("BuilderIcons")
local Translator = require(Utility.Localization.Translator)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child
type InputSize = InputSize.InputSize
type InputVariant = InputVariant.InputVariant
type Radius = Radius.Radius
type SearchInputShape = SearchInputShape.SearchInputShape
type TextInputRef = Types.TextInputRef
type InternalTextInputRef = Types.InternalTextInputRef
type ComputedChild = (scope: Scope) -> Child

local SHAPE_TO_RADIUS: { [SearchInputShape]: Radius } = {
	[SearchInputShape.Pill] = Radius.Circle,
	[SearchInputShape.Box] = Radius.None,
}

export type SearchInputProps = {
	scope: Scope,
	text: UsedAs<string>,
	-- Placeholder text for input (defaults to "Search")
	placeholder: UsedAs<string>?,
	-- Called when the text is changed in the SearchInput
	onChanged: (text: string) -> (),
	-- Size of the SearchInput
	size: UsedAs<InputSize>?,
	-- Whether the SearchInput is disabled
	isDisabled: UsedAs<boolean>?,
	-- Whether to show the clear button (defaults to true)
	hasClearButton: UsedAs<boolean>?,
	-- Whether the SearchInput is in an error state
	hasError: UsedAs<boolean>?,
	-- Width of the SearchInput
	width: UsedAs<UDim>?,
	-- Style variant of the SearchInput
	variant: UsedAs<InputVariant>?,
	-- Shape of the SearchInput
	shape: UsedAs<SearchInputShape>?,
	-- Called when the SearchInput gains focus
	onFocus: (() -> ())?,
	-- Called when the SearchInput loses focus
	onFocusLost: ((inputObject: InputObject?) -> ())?,
} & Types.CommonProps

local defaultProps = {
	size = InputSize.Medium,
	variant = InputVariant.Standard,
	shape = SearchInputShape.Pill,
	hasClearButton = true,
}

return function(searchInputProps: SearchInputProps)
	local scope = searchInputProps.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the SearchInput component.")

	local props = withDefaults(searchInputProps, defaultProps)

	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local inputSize = unwrap(props.size, use)
		local inputVariant = unwrap(props.variant, use)
		local inputShape = unwrap(props.shape, use)

		local variantProps = useTextInputVariants(
			unwrap(theme.Theme), tokens, inputSize, inputVariant,
			nil, false, false
		)

		local horizontalPadding = variantProps.container.horizontalPadding
		local defaultWidth = useScaledValue(Constants.DEFAULT_INPUT_FIELD_WIDTH_PIXELS, use)

		-- Search icon position: centered vertically based on single-line input height
		local searchIconPosition = UDim2.fromOffset(0, (variantProps.container.minHeight - tokens.Stroke.Standard) / 2)

		local leadingElement = function(leadingScope: Scope): Child
			return View {
				scope = leadingScope,
				Position = searchIconPosition,
				tag = "anchor-center-left auto-xy",
				children = {
					Icon {
						scope = leadingScope,
						name = BuilderIcons.Icon.MagnifyingGlass,
						style = variantProps.icon.style,
						size = variantProps.icon.size,
					}
				}
			}
		end

		local placeholder = innerScope:Computed(function(use: Use)
			local p = unwrap(props.placeholder, use)
			if p then return p end
			return Translator:FormatByKey("CommonUI.Controls.Action.Search")
		end)

		local width = unwrap(props.width, use)

		return View {
			scope = innerScope,
			Size = if width
				then UDim2.new(width, UDim.new(0, 0))
				else UDim2.new(UDim.new(0, defaultWidth), UDim.new(0, 0)),
			tag = "auto-y",
			children = {
				BaseTextInput {
					scope = innerScope,
					text = props.text,
					hasError = props.hasError,
					isDisabled = props.isDisabled,
					hasClearButton = props.hasClearButton,
					size = props.size,
					radius = SHAPE_TO_RADIUS[inputShape],
					variant = props.variant,
					horizontalPadding = {
						left = horizontalPadding,
						right = horizontalPadding,
					},
					onChanged = props.onChanged,
					onFocus = props.onFocus,
					onFocusLost = props.onFocusLost,
					placeholder = placeholder,
					leadingElement = leadingElement,
				}
			}
		}
	end)
end