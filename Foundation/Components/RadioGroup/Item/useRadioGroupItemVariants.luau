local Foundation = script.Parent.Parent.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local BaseInput = require(Components.BaseInput)

local useVariants = require(Utility.useVariants)
local composeStyleVariant = require(Utility.composeStyleVariant)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)

type VariantProps = composeStyleVariant.VariantProps
type InputVariantProps = BaseInput.InputVariantProps
type ColorStyleValue = Types.ColorStyleValue
type InputSize = InputSize.InputSize

type RadioItemVariantProps = {
	input: InputVariantProps,
	checkmark: { tag: string, style: ColorStyleValue }
}

local function variantsFactory(tokens: {[string]: any})
	local common = {
		input = { tag = "radius-circle", cursorRadius = UDim.new(0, tokens.Radius.Circle) },
		checkmark = {
			tag = "position-center-center anchor-center-center radius-circle",
			style = tokens.Inverse.Content.Emphasis,
		},
	}

	local sizes: { [InputSize]: VariantProps } = {
		[InputSize.XSmall] = {
			input = { size = UDim2.fromOffset(tokens.Size.Size_400, tokens.Size.Size_400) },
			checkmark = { tag = "size-150" },
		},
		[InputSize.Small] = {
			input = { size = UDim2.fromOffset(tokens.Size.Size_500, tokens.Size.Size_500) },
			checkmark = { tag = "size-200" },
		},
		[InputSize.Medium] = {
			input = { size = UDim2.fromOffset(tokens.Size.Size_600, tokens.Size.Size_600) },
			checkmark = { tag = "size-250" },
		},
		[InputSize.Large] = {
			input = { size = UDim2.fromOffset(tokens.Size.Size_700, tokens.Size.Size_700) },
			checkmark = { tag = "size-300" },
		},
	}

	return { common = common, sizes = sizes }
end

return function(theme: string, tokens: {[string]: any}, size: InputSize): RadioItemVariantProps
	local variants = useVariants(theme, tokens, "RadioItem", variantsFactory)
	return composeStyleVariant(variants.common, variants.sizes[size])
end
