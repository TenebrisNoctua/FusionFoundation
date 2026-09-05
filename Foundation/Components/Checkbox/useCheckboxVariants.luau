local Foundation = script.Parent.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local BaseInput = require(Components.BaseInput)

local useVariants = require(Utility.useVariants)
local composeStyleVariant = require(Utility.composeStyleVariant)

local InputSize = require(Enums.InputSize)

type VariantProps = composeStyleVariant.VariantProps
type InputVariantProps = BaseInput.InputVariantProps
type InputSize = InputSize.InputSize

type CheckboxVariantProps = {
	input: InputVariantProps,
	checkmark: { tag: string }
}

local function variantsFactory(tokens: {[string]: any})
	local common = {
		input = {
			tag = "radius-small",
			colors = {
				checkedStyle = tokens.Color.ActionSubEmphasis.Background,
			},
			cursorRadius = UDim.new(0, tokens.Radius.Small)
		},
		checkmark = { tag = "position-center-center anchor-center-center content-action-sub-emphasis" }
	}

	local sizes: { [InputSize]: VariantProps } = {
		[InputSize.XSmall] = {
			input = { size = UDim2.fromOffset(tokens.Size.Size_400, tokens.Size.Size_400) },
			checkmark = { tag = "size-400" },
		},
		[InputSize.Small] = {
			input = { size = UDim2.fromOffset(tokens.Size.Size_500, tokens.Size.Size_500) },
			checkmark = { tag = "size-500" },
		},
		[InputSize.Medium] = {
			input = { size = UDim2.fromOffset(tokens.Size.Size_600, tokens.Size.Size_600) },
			checkmark = { tag = "size-600" },
		},
		[InputSize.Large] = {
			input = { size = UDim2.fromOffset(tokens.Size.Size_700, tokens.Size.Size_700) },
			checkmark = { tag = "size-700" },
		}
	}

	return { common = common, sizes = sizes }
end

return function(theme: string, tokens: {[string]: any}, size: InputSize): CheckboxVariantProps
	local variants = useVariants(theme, tokens, "Checkbox", variantsFactory)
	return composeStyleVariant(variants.common, variants.sizes[size])
end

