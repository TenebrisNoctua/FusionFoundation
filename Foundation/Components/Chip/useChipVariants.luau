local Foundation = script.Parent.Parent.Parent

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useVariants = require(Utility.useVariants)
local composeStyleVariant = require(Utility.composeStyleVariant)
local Types = require(Utility.Types)

local ChipSize = require(Enums.ChipSize)
local ChipVariant = require(Enums.ChipVariant)

type ChipSize = ChipSize.ChipSize
type ChipVariant = ChipVariant.ChipVariant
type VariantProps = composeStyleVariant.VariantProps

local function variantsFactory(tokens: {[string]: any})
	local textSpacing: { [ChipSize]: UDim } = {
		[ChipSize.Small] = UDim.new(0, tokens.Padding.Small),
		[ChipSize.Medium] = UDim.new(0, tokens.Padding.Medium),
		[ChipSize.Large] = UDim.new(0, tokens.Padding.Large)
	}

	local common = {
		chip = { tag = "row align-x-center align-y-center auto-x radius-circle clip" },
		text = { tag = "shrink size-0-full auto-x text-truncate-end" },
	}

	local sizes: { [ChipSize]: VariantProps } = {
		[ChipSize.Small] = {
			chip = { tag = "size-0-600" },
			text = { tag = "text-label-small" },
		},
		[ChipSize.Medium] = {
			chip = { tag = "size-0-800" },
			text = { tag = "text-label-medium" },
		},
		[ChipSize.Large] = {
			chip = { tag = "size-0-1000" },
			text = { tag = "text-label-medium" },
		},
	}

	local types: { [ChipVariant]: { [boolean]: VariantProps } } = {
		[ChipVariant.Utility] = {
			[true] = {
				chip = { backgroundStyle = tokens.Inverse.Surface.Surface_0 },
				text = { contentStyle = tokens.Inverse.Content.Emphasis },
			},
			[false] = {
				chip = { backgroundStyle = tokens.Color.ActionUtility.Background },
				text = { contentStyle = tokens.Color.ActionUtility.Foreground },
			},
		},
		[ChipVariant.Standard] = {
			[true] = {
				chip = { backgroundStyle = tokens.Inverse.Surface.Surface_0 },
				text = { contentStyle = tokens.Inverse.Content.Emphasis },
			},
			[false] = {
				chip = { backgroundStyle = tokens.Color.ActionStandard.Background },
				text = { contentStyle = tokens.Color.ActionStandard.Foreground },
			}
		}
	}

	return {
		common = common,
		sizes = sizes,
		types = types,
		textSpacing = textSpacing
	}
end

return function(
	theme: string,
	tokens: {[string]: any},
	size: ChipSize,
	variant: ChipVariant,
	isChecked: boolean,
	hasLeading: boolean,
	hasTrailing: boolean
)
	local props = useVariants(theme, tokens, "Chip", variantsFactory)
	return composeStyleVariant(props.common, props.sizes[size], props.types[variant][isChecked], {
		text = {
			padding = {
				left = if hasLeading then nil else props.textSpacing[size],
				right = if hasTrailing then nil else props.textSpacing[size],
			}
		}
	})
end
