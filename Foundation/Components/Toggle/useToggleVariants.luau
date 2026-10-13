local Foundation = script.Parent.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local BaseInput = require(Components.BaseInput)
local getKnobSize = require(Components.Knob.getKnobSize)

local useVariants = require(Utility.useVariants)
local composeStyleVariant = require(Utility.composeStyleVariant)

local InputSize = require(Enums.InputSize)

type VariantProps = composeStyleVariant.VariantProps
type InputVariantProps = BaseInput.InputVariantProps
type InputSize = InputSize.InputSize

type ToggleVariantProps = {
	input: InputVariantProps,
	knob: {
		offPosition: UDim2,
		onPosition: UDim2,
	},
}

local function computeProps(props: {
	tag: string,
	size: { height: number, width: number },
	knobSize: UDim2,
	strokeThickness: number?,
})
	local knobWidth = props.knobSize.X.Offset
	local padding = (props.size.height - knobWidth) / 2

	return {
		input = {
			tag = props.tag,
			size = UDim2.fromOffset(props.size.width, props.size.height),
			stroke = {
				thickness = props.strokeThickness,
			},
		},
		knob = {
			offPosition = UDim2.new(0, padding, 0.5, 0),
			onPosition = UDim2.new(0, props.size.width - knobWidth - padding, 0.5, 0),
		},
	}

end

local function variantsFactory(tokens: { [string]: any })
	local common = {
		input = {
			colors = {
				backgroundStyle = tokens.Color.ActionStandard.Background,
				hoverStyle = tokens.Color.State.Hover,
				checkedStyle = tokens.Color.System.Contrast,
				labelStyle = tokens.Color.Content.Emphasis,
				labelHoverStyle = tokens.Color.Content.Emphasis,
			},
			cursorRadius = UDim.new(0, tokens.Radius.Circle),
		},
	}

	local sizes: { [InputSize]: VariantProps } = {
		[InputSize.XSmall] = computeProps({
			tag = "radius-circle",
			size = { width = tokens.Size.Size_700, height = tokens.Size.Size_400 },
			knobSize = getKnobSize(tokens, InputSize.XSmall),
			strokeThickness = tokens.Stroke.None,
		}),
		[InputSize.Small] = computeProps({
			tag = "radius-circle",
			size = { width = tokens.Size.Size_800, height = tokens.Size.Size_500 },
			knobSize = getKnobSize(tokens, InputSize.Small),
			strokeThickness = tokens.Stroke.None,
		}),
		[InputSize.Medium] = computeProps({
			tag = "radius-circle",
			size = { width = tokens.Size.Size_1000, height = tokens.Size.Size_600 },
			knobSize = getKnobSize(tokens, InputSize.Medium),
			strokeThickness = tokens.Stroke.None,
		}),
		[InputSize.Large] = computeProps({
			tag = "radius-circle",
			size = { width = tokens.Size.Size_1100, height = tokens.Size.Size_600 },
			knobSize = getKnobSize(tokens, InputSize.Medium),
			strokeThickness = tokens.Stroke.None,
		}),
	}

	return { common = common, sizes = sizes }
end

return function(theme: string, tokens: { [string]: any }, size: InputSize): ToggleVariantProps
	local variants = useVariants(theme, tokens, "Toggle", variantsFactory)
	return composeStyleVariant(variants.common, variants.sizes[size])
end
