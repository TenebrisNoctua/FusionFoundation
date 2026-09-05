local Foundation = script.Parent.Parent.Parent

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useVariants = require(Utility.useVariants)
local composeStyleVariant = require(Utility.composeStyleVariant)
local Types = require(Utility.Types)

local Orientation = require(Enums.Orientation)
local DividerVariant = require(Enums.DividerVariant)

type ColorStyleValue = Types.ColorStyleValue
type DividerVariant = DividerVariant.DividerVariant
type Orientation = Orientation.Orientation
type VariantProps = composeStyleVariant.VariantProps

type DividerVariantProps = {
	container: { tag: string },
	stroke: { Size: UDim2, backgroundStyle: ColorStyleValue },
	line: { tag: string, position: UDim2, backgroundStyle: ColorStyleValue },
}

local function variantsFactory(tokens: {[string]: any})
	local common = {
		container = {
			tag = "col",
		},
		stroke = {
			backgroundStyle = tokens.Color.Stroke.Default,
		},
		line = {
			tag = "size-full-200",
			position = UDim2.fromOffset(0, tokens.Size.Size_50),
			backgroundStyle = tokens.Color.Common.HeavyDivider,
		},
	}

	local orientation: { [Orientation]: VariantProps } = {
		[Orientation.Horizontal] = {
			container = {
				tag = "size-full-0 auto-y",
			},
			stroke = {
				Size = UDim2.new(1, 0, 0, tokens.Stroke.Standard),
			},
		},
		[Orientation.Vertical] = {
			container = {
				tag = "size-0-full auto-x",
			},
			stroke = {
				Size = UDim2.new(0, tokens.Stroke.Standard, 1, 0),
			},
		},
	}

	local padding: { [DividerVariant]: VariantProps } = {
		[DividerVariant.Inset] = {
			container = {
				tag = "padding-x-xlarge",
			},
		},
		[DividerVariant.InsetLeft] = {
			container = {
				tag = "padding-left-xlarge",
			},
		},
		[DividerVariant.InsetRight] = {
			container = {
				tag = "padding-right-xlarge",
			},
		},
	}

	return { common = common, padding = padding, orientation = orientation }
end

return function(theme: string, tokens: {[string]: any}, variant: DividerVariant, orientation: Orientation): DividerVariantProps
	local props = useVariants(theme, tokens, "Divider", variantsFactory)
	return composeStyleVariant(
		props.common,
		if orientation == Orientation.Horizontal then props.padding[variant] else {},
		props.orientation[orientation]
	)
end
