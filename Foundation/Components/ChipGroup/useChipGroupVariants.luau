local Foundation = script.Parent.Parent.Parent

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useVariants = require(Utility.useVariants)

local ChipSize = require(Enums.ChipSize)
local ChipGroupVariant = require(Enums.ChipGroupVariant)
type ChipGroupVariant = ChipGroupVariant.ChipGroupVariant

-- We omit ChipSize.Large because it doesn't look great when used in a large
-- group of Chips. We'll consider supporting it in the future if we have
-- compelling use cases.
--
-- This is exported so we can access it internally. Do not expose off the public
-- API. We expect consumers to use ChipSize directly.
export type ChipGroupSize = typeof(ChipSize.Small) | typeof(ChipSize.Medium)

type ChipGroupVariantConfig = {
	isWrapped: boolean,
	hasScrim: boolean,
}

export type ChipGroupVariants = {
	isWrapped: boolean,
	hasScrim: boolean,
	scrimWidth: number,
	gap: number,
}

local function variantsFactory(tokens: {[string]: any})
	local scrimWidth: { [ChipGroupSize]: number } = {
		[ChipSize.Small] = tokens.Size.Size_600,
		[ChipSize.Medium] = tokens.Size.Size_800,
	}

	local gap: { [ChipGroupSize]: number } = {
		[ChipSize.Small] = tokens.Padding.XSmall,
		[ChipSize.Medium] = tokens.Padding.Small,
	}

	local variants: { [ChipGroupVariant]: ChipGroupVariantConfig } = {
		[ChipGroupVariant.Row] = {
			isWrapped = false,
			hasScrim = true,
		},
		[ChipGroupVariant.Wrap] = {
			isWrapped = true,
			hasScrim = false,
		},
	}

	return {
		scrimWidth = scrimWidth,
		gap = gap,
		variants = variants,
	}
end

return function(theme: string, tokens: {[string]: any}, variant: ChipGroupVariant, size: ChipGroupSize): ChipGroupVariants
	local props = useVariants(theme, tokens, "ChipGroup", variantsFactory)
	local config = props.variants[variant]
	return {
		isWrapped = config.isWrapped,
		hasScrim = config.hasScrim,
		scrimWidth = props.scrimWidth[size],
		gap = props.gap[size],
	}
end
