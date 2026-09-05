local Foundation = script.Parent.Parent.Parent

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useVariants = require(Utility.useVariants)
local composeStyleVariant = require(Utility.composeStyleVariant)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)
local SliderVariant = require(Enums.SliderVariant)

type VariantProps = composeStyleVariant.VariantProps
type ColorStyleValue = Types.ColorStyleValue
type InputSize = InputSize.InputSize
type SliderVariant = SliderVariant.SliderVariant

type SliderVariantProps = {
	bar: { tag: string },
	fill: { tag: string },
	hitbox: { height: number },
	knob: {
		style: ColorStyleValue,
		dragStyle: ColorStyleValue?,
		stroke: Types.Stroke?,
		hasShadow: boolean?
	}
}

local function variantsFactory(tokens: {[string]: any})
	local common = {
		bar = { tag = "position-center-center anchor-center-center size-full-100 radius-small" },
		fill = { tag = "radius-small" }
	}

	local variants: { [SliderVariant]: VariantProps } = {
		[SliderVariant.Emphasis] = {
			bar = { tag = "bg-shift-400" },
			fill = { tag = "bg-emphasis" },
			knob = {
				style = tokens.Color.Extended.White.White_100,
				dragStyle = tokens.Color.ActionEmphasis.Background,
				hasShadow = true
			},
		},
		[SliderVariant.Standard] = {
			bar = { tag = "bg-shift-400" },
			fill = { tag = "bg-system-contrast" },
			knob = {
				style = tokens.Color.System.Contrast,
				dragStyle = tokens.Color.System.Contrast,
				hasShadow = false
			},
		},
		[SliderVariant.Utility] = {
			knob = {
				style = tokens.Color.None,
				dragStyle = tokens.Color.None,
				stroke = {
					Color = tokens.Color.System.Contrast.Color3,
					Transparency = tokens.Color.System.Contrast.Transparency,
					Thickness = tokens.Stroke.Thicker
				},
				hasShadow = true
			},
		},
	}

	local sizes: { [InputSize]: VariantProps } = {
		[InputSize.XSmall] = { hitbox = { height = tokens.Size.Size_300 } },
		[InputSize.Small] = { hitbox = { height = tokens.Size.Size_400 } },
		[InputSize.Medium] = { hitbox = { height = tokens.Size.Size_500 } },
		[InputSize.Large] = { hitbox = { height = tokens.Size.Size_700 } }
	}

	return { common = common, variants = variants, sizes = sizes }
end

return function(theme: string, tokens: {[string]: any}, size: InputSize, variant: SliderVariant): SliderVariantProps
	local variants = useVariants(theme, tokens, "Slider", variantsFactory)
	return composeStyleVariant(variants.common, variants.variants[variant], variants.sizes[size])
end
