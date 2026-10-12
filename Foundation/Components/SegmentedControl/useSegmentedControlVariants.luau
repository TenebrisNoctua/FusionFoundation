local Foundation = script.Parent.Parent.Parent

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useVariants = require(Utility.useVariants)
local composeStyleVariant = require(Utility.composeStyleVariant)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)
local IconSize = require(Enums.IconSize)

type ColorStyleValue = Types.ColorStyleValue
type VariantProps = composeStyleVariant.VariantProps
type InputSize = InputSize.InputSize
type IconSize = IconSize.IconSize

type SegmentedControlVariantProps = {
	container: { tag: string },
	segment: { tag: string },
	text: { tag: string },
	icon: { size: IconSize, style: ColorStyleValue }?,
	divider: { Size: UDim2?, tag: string? },
}

local function variantsFactory(tokens: {[string]: any})
	local common = {
		container = {
			tag = "row align-y-center auto-x bg-surface-300",
		},
		segment = {
			tag = "row align-y-center size-0-full auto-x",
		},
		text = { tag = "auto-x text-truncate-end content-emphasis" },
		icon = { style = tokens.Color.Content.Emphasis },
		divider = { tag = "row" },
	}

	local sizes: { [InputSize]: VariantProps } = {
		[InputSize.XSmall] = {
			container = { tag = "size-600" },
			segment = { tag = "padding-small" },
			text = { tag = "text-caption-small" },
			icon = { size = IconSize.Small },
			divider = { Size = UDim2.new(0, tokens.Stroke.Standard, 1, 0) },
		},
		[InputSize.Small] = {
			container = { tag = "size-800" },
			segment = { tag = "padding-small" },
			text = { tag = "text-caption-small" },
			icon = { size = IconSize.Medium },
			divider = { Size = UDim2.new(0, tokens.Stroke.Standard, 1, 0) },
		},
		[InputSize.Medium] = {
			container = { tag = "size-1000 padding-xsmall" },
			segment = { tag = "padding-small" },
			text = { tag = "text-caption-medium" },
			icon = { size = IconSize.Medium },
			divider = { Size = UDim2.new(0, tokens.Stroke.Standard, 1, 0) },
		},
		[InputSize.Large] = {
			container = { tag = "size-1200 padding-xsmall" },
			segment = { tag = "padding-medium" },
			text = { tag = "text-caption-medium" },
			icon = { size = IconSize.Large },
			divider = { Size = UDim2.new(0, tokens.Stroke.Standard, 1, 0) },
		},
	}

	-- Radius is pulled out of `sizes` into separate overlays so the circular
	-- variant can swap in `radius-circle` without duplicating per-size
	-- declarations.
	local defaultRadius: { [InputSize]: VariantProps } = {
		[InputSize.XSmall] = {
			container = { tag = "radius-medium" },
			segment = { tag = "radius-medium" },
		},
		[InputSize.Small] = {
			container = { tag = "radius-medium" },
			segment = { tag = "radius-medium" },
		},
		[InputSize.Medium] = {
			container = { tag = "radius-medium" },
			segment = { tag = "radius-small" },
		},
		[InputSize.Large] = {
			container = { tag = "radius-medium" },
			segment = { tag = "radius-small" },
		},
	}

	local circularRadius: VariantProps = {
		container = { tag = "radius-circle" },
		segment = { tag = "radius-circle" },
	}

	return {
		common = common,
		sizes = sizes,
		defaultRadius = defaultRadius,
		circularRadius = circularRadius,
	}
end

return function(theme: string, tokens: {[string]: any}, size: InputSize, isCircular: boolean?): SegmentedControlVariantProps
	local props = useVariants(theme, tokens, "SegmentedControl", variantsFactory)
	return composeStyleVariant(
		props.common,
		props.sizes[size],
		if isCircular then props.circularRadius else props.defaultRadius[size]
	)
end
