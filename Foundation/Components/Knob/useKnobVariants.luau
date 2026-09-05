local Foundation = script.Parent.Parent.Parent

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local getKnobSize = require(script.Parent.getKnobSize)

local useVariants = require(Utility.useVariants)
local composeStyleVariant = require(Utility.composeStyleVariant)
local Types = require(Utility.Types)

local IconSize = require(Enums.IconSize)
local InputSize = require(Enums.InputSize)

type VariantProps = composeStyleVariant.VariantProps
type ColorStyleValue = Types.ColorStyleValue
type InputSize = InputSize.InputSize
type IconSize = IconSize.IconSize

type KnobVariantProps = {
	knob: {
		tag: string,
		size: UDim2,
		style: ColorStyleValue,
		iconSize: IconSize
	},
	knobShadow: {
		tag: string,
		size: UDim2,
		padding: number
	},
	iconContainer: {
		backgroundStyle: ColorStyleValue
	}
}

local function computeProps(props: { size: UDim2, shadowPadding: number, iconSize: IconSize })
	local knobWidth = props.size.X.Offset
	local shadowSize = knobWidth + 2 * props.shadowPadding
	return {
		knob = {
			size = props.size,
			iconSize = props.iconSize,
		},
		knobShadow = {
			size = UDim2.fromOffset(shadowSize, shadowSize),
			padding = props.shadowPadding
		}
	}
end

local function variantsFactory(tokens: {[string]: any})
	local common = {
		knob = {
			tag = "position-center-center anchor-center-center auto-xy radius-circle",
		},
		knobShadow = {
			tag = "position-center-center anchor-center-center",
		}
	}

	local sizes: { [InputSize]: VariantProps } = {
		[InputSize.XSmall] = computeProps({
			iconSize = IconSize.XSmall,
			size = getKnobSize(tokens, InputSize.XSmall),
			shadowPadding = tokens.Padding.XXSmall,
		}),
		[InputSize.Small] = computeProps({
			iconSize = IconSize.Small,
			size = getKnobSize(tokens, InputSize.Small),
			shadowPadding = tokens.Padding.XSmall,
		}),
		[InputSize.Medium] = computeProps({
			iconSize = IconSize.Medium,
			size = getKnobSize(tokens, InputSize.Medium),
			shadowPadding = tokens.Padding.Small,
		}),
		[InputSize.Large] = computeProps({
			iconSize = IconSize.Large,
			size = getKnobSize(tokens, InputSize.Large),
			shadowPadding = tokens.Padding.Small,
		})
	}

	local isInverse: { [boolean]: VariantProps } = {
		[false] = {
			knob = { style = tokens.Color.Content.Emphasis },
			iconContainer = { backgroundStyle = tokens.Inverse.Content.Emphasis },
		},
		[true] = {
			knob = { style = tokens.Inverse.Content.Emphasis },
			iconContainer = { backgroundStyle = tokens.Color.Content.Emphasis },
		}
	}

	return { common = common, sizes = sizes, isInverse = isInverse }
end

return function(theme: string, tokens: {[string]: any}, size: InputSize, isInverse: boolean): KnobVariantProps
	local variants = useVariants(theme, tokens, "Knob", variantsFactory)
	return composeStyleVariant(variants.common, variants.sizes[size], variants.isInverse[isInverse])
end
