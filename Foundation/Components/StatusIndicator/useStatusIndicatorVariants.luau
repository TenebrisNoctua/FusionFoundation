local Foundation = script.Parent.Parent.Parent

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local unwrap = require(Utility.unwrap)
local useVariants = require(Utility.useVariants)
local composeStyleVariant = require(Utility.composeStyleVariant)
local Types = require(Utility.Types)

local StatusIndicatorSize = require(Enums.StatusIndicatorSize)
local StatusIndicatorShape = require(Enums.StatusIndicatorShape)
local StatusIndicatorVariant = require(Enums.StatusIndicatorVariant)

local Constants = require(Foundation.Constants)


local BuilderSansSemiBold = Font.new(Constants.BUILDER_SANS_FONT_ASSET, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)

type StatusIndicatorSize = StatusIndicatorSize.StatusIndicatorSize
type StatusIndicatorVariant = StatusIndicatorVariant.StatusIndicatorVariant
type StatusIndicatorShape = StatusIndicatorShape.StatusIndicatorShape

type ColorStyleValue = Types.ColorStyleValue
type VariantProps = composeStyleVariant.VariantProps

type StatusIndicatorVariantProps = {
	container: { tag: string, backgroundStyle: ColorStyleValue?, size: UDim2? },
	content: { tag: string, style: ColorStyleValue?, font: Font },
	ring: { tag: string, size: UDim2? }?,
}

local function variantsMap(tokens: {[string]: any})
	local common = {
		content = {
			tag = "auto-xy text-align-x-left",
			font = BuilderSansSemiBold
		}
	}

	local variants: { [StatusIndicatorVariant]: VariantProps } = {
		[StatusIndicatorVariant.Alert] = {
			container = { tag = "bg-system-alert" },
			content = { style = tokens.DarkMode.Content.Emphasis },
		},
		[StatusIndicatorVariant.Success] = {
			container = { tag = "bg-system-success" },
			content = { style = tokens.LightMode.Content.Emphasis },
		},
		[StatusIndicatorVariant.Warning] = {
			container = { tag = "bg-system-warning" },
			content = { style = tokens.LightMode.Content.Emphasis },
		},
		[StatusIndicatorVariant.Emphasis] = {
			container = { tag = "bg-system-emphasis" },
			content = { style = tokens.DarkMode.Content.Emphasis },
		},
		[StatusIndicatorVariant.Neutral] = {
			container = { tag = "bg-system-neutral" },
			content = { style = tokens.Inverse.Content.Emphasis },
		},
		[StatusIndicatorVariant.Standard] = {
			container = { tag = "bg-action-standard" },
			content = { style = tokens.Color.Content.Emphasis },
		},
		[StatusIndicatorVariant.Contrast_Experiment] = {
			container = { tag = "bg-system-contrast" },
			content = { style = tokens.Inverse.Content.Emphasis },
		},
		[StatusIndicatorVariant.Voice] = {
			container = {
				backgroundStyle = tokens.Color.Extended.Orange.Orange_600,
			},
		},
	}

	local hasValue: { [boolean]: any } = {
		[true] = {
			container = { tag = "row align-x-center align-y-center size-400-400 auto-x padding-xsmall" },
		},
	}

	local shape: { [StatusIndicatorShape]: any } = {
		[StatusIndicatorShape.Circle] = {
			container = { tag = "radius-circle" },
		},
		[StatusIndicatorShape.Ring] = {
			container = { tag = "align-x-center align-y-center radius-circle" },
			ring = {
				tag = "radius-circle bg-surface-100",
			},
		},
		[StatusIndicatorShape.Square] = {
			container = { tag = "radius-none" },
		},
	}

	local sizes: { [StatusIndicatorSize]: VariantProps } = {
		[StatusIndicatorSize.XSmall] = {
			container = { size = UDim2.fromOffset(tokens.Size.Size_150, tokens.Size.Size_150) },
			ring = { size = UDim2.fromOffset(tokens.Size.Size_150 / 2, tokens.Size.Size_150 / 2) },
		},
		[StatusIndicatorSize.Small] = {
			container = { size = UDim2.fromOffset(tokens.Size.Size_200, tokens.Size.Size_200) },
			ring = { size = UDim2.fromOffset(tokens.Size.Size_200 / 2, tokens.Size.Size_200 / 2) },
		},
		[StatusIndicatorSize.Medium] = {
			container = { size = UDim2.fromOffset(tokens.Size.Size_250, tokens.Size.Size_250) },
			ring = { size = UDim2.fromOffset(tokens.Size.Size_250 / 2, tokens.Size.Size_250 / 2) },
		},
		[StatusIndicatorSize.Pictogram] = {
			container = { size = UDim2.fromOffset(tokens.Size.Size_500, tokens.Size.Size_500) },
			ring = { size = UDim2.fromOffset(tokens.Size.Size_500 / 2, tokens.Size.Size_500 / 2) },
		},
	}

	return {
		common = common,
		variants = variants,
		hasValue = hasValue,
		shape = shape,
		sizes = sizes,
	}
end

return function(
	theme: string,
	tokens: {[string]: any},
	variant: StatusIndicatorVariant,
	hasValue: boolean,
	shape: StatusIndicatorShape,
	size: StatusIndicatorSize
): StatusIndicatorVariantProps
	local props = useVariants(theme, tokens, "StatusIndicator", variantsMap)
	return composeStyleVariant(
		props.common,
		props.variants[variant],
		props.hasValue[hasValue],
		props.shape[shape],
		if not hasValue then props.sizes[size] else {}
	)
end