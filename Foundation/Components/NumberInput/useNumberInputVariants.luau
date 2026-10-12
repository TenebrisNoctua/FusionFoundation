local Foundation = script.Parent.Parent.Parent

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useVariants = require(Utility.useVariants)
local composeStyleVariant = require(Utility.composeStyleVariant)

local IconSize = require(Enums.IconSize)
local InputSize = require(Enums.InputSize)

type VariantProps = composeStyleVariant.VariantProps
type InputSize = InputSize.InputSize

local function variantsFactory(tokens: {[string]: any})
	local common = { controls = { tag = "row align-y-center bg-action-standard" } }
	local sizes: { [InputSize]: VariantProps } = {
		[InputSize.XSmall] = {
			controls = {
				width = tokens.Size.Size_1200,
				buttonSize = tokens.Size.Size_600,
				iconSize = IconSize.XSmall,
				tag = "radius-small",
				radius = tokens.Radius.Small,
			},
		},
		[InputSize.Small] = {
			controls = {
				width = tokens.Size.Size_1600,
				buttonSize = tokens.Size.Size_800,
				iconSize = IconSize.Small,
				tag = "radius-medium",
				radius = tokens.Radius.Medium,
			},
		},
		[InputSize.Medium] = {
			controls = {
				width = tokens.Size.Size_2000,
				buttonSize = tokens.Size.Size_1000,
				iconSize = IconSize.Medium,
				tag = "radius-medium",
				radius = tokens.Radius.Medium,
			},
		},
		[InputSize.Large] = {
			controls = {
				width = tokens.Size.Size_2400,
				buttonSize = tokens.Size.Size_1200,
				iconSize = IconSize.Large,
				tag = "radius-medium",
				radius = tokens.Radius.Medium,
			}
		}
	}

	return {
		common = common,
		sizes = sizes,
	}
end

return function(theme: string, tokens: {[string]: any}, size: InputSize)
	local props = useVariants(theme, tokens, "NumberInput", variantsFactory)
	return composeStyleVariant(props.common, props.sizes[size])
end
