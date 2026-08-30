local Foundation = script.Parent.Parent.Parent

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useVariants = require(Utility.useVariants)
local composeStyleVariant = require(Utility.composeStyleVariant)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)

type InputSize = InputSize.InputSize
type VariantProps = composeStyleVariant.VariantProps
type ColorStyleValue = Types.ColorStyleValue

export type InputVariantProps = {
	container: { tag: string, padding: UDim },
	input: { style: ColorStyleValue, stroke: {
		style: ColorStyleValue,
		thickness: number,
	} },
	label: { style: ColorStyleValue },
}

local function variantsFactory(tokens: {[string]: any})
	local strokeThickness = math.ceil(tokens.Stroke.Standard)
	local common = {
		container = {
			tag = "row align-x-left align-y-center auto-xy",
			padding = UDim.new(0, strokeThickness),
		},
		input = { stroke = { thickness = strokeThickness } },
	}

	local sizes: { [InputSize]: VariantProps } = {
		[InputSize.XSmall] = { container = { tag = "gap-medium" } },
		[InputSize.Small] = { container = { tag = "gap-medium" } },
		[InputSize.Medium] = { container = { tag = "gap-medium" } },
		[InputSize.Large] = { container = { tag = "gap-medium" } },
	}

	local labelPosition: { [Enum.HorizontalAlignment]: VariantProps } = {
		[Enum.HorizontalAlignment.Left] = { container = { tag = "" } },
		[Enum.HorizontalAlignment.Right] = { container = { tag = "" } },
	}

	return { common = common, sizes = sizes, labelPosition = labelPosition }
end

return function(theme: string, tokens: {[string]: any}, size: InputSize, labelPosition: Enum.HorizontalAlignment): InputVariantProps
	local props = useVariants(theme, tokens, "BaseInput", variantsFactory)
	return composeStyleVariant(props.common, props.sizes[size], props.labelPosition[labelPosition])
end