local Foundation = script.Parent.Parent.Parent

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local getInputVariantsFactory = require(script.Parent.getInputVariantsFactory)
local composeStyleVariant = require(Utility.composeStyleVariant)

local Radius = require(Enums.Radius)
local InputSize = require(Enums.InputSize)
local InputVariant = require(Enums.InputVariant)

type InputSize = InputSize.InputSize
type InputVariant = InputVariant.InputVariant
type Radius = Radius.Radius
type VariantProps = composeStyleVariant.VariantProps

local function composeInputFieldVariants(
	tokens: {[string]: any},
	size: InputSize,
	variant: InputVariant?,
	radius: Radius?,
	focused: boolean?,
	hover: boolean?,
	hasError: boolean?
): VariantProps
	local props = getInputVariantsFactory(tokens)
	local variantAttributes = props.variants[variant or InputVariant.Standard]

	return composeStyleVariant(
		props.common,
		props.sizes[size],
		if variant ~= InputVariant.Utility then variantAttributes else {},
		if radius then props.radius[radius] else props.defaultRadius[size],
		if hover ~= nil then props.hoverState[hover] else {},
		if focused ~= nil then props.focusedState[focused] else {},
		if hasError ~= nil then props.errorState[hasError] else {},
		if variant == InputVariant.Utility then variantAttributes else {}
	)
end

return composeInputFieldVariants