local Foundation = script.Parent.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local getSharedVariants = require(Components.Button.getSharedVariants)

local unwrap = require(Utility.unwrap)
local useVariants = require(Utility.useVariants)
local composeStyleVariant = require(Utility.composeStyleVariant)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)
local ButtonVariant = require(Enums.ButtonVariant)
local ColorNamespace = require(Enums.ColorNamespace)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type InputSize = InputSize.InputSize
type ButtonVariant = ButtonVariant.ButtonVariant
type ColorNamespace = ColorNamespace.ColorNamespace

type ColorStyleValue = Types.ColorStyleValue
type StateLayer = Types.StateLayer
type Stroke = Types.Stroke

type VariantProps = composeStyleVariant.VariantProps

type IconButtonVariantProps = {
	container: {
		tag: string,
		size: UDim2,
		stroke: Stroke?,
		radius: number,
		style: ColorStyleValue,
		padding: UDim,
		stateLayer: StateLayer?,
	},
	content: {
		style: ColorStyleValue,
	},
}

local function variantsMap(tokens: {[string]: any})
	local sharedVariants = getSharedVariants(tokens)
	local common = {}

	local sizes: { [InputSize]: VariantProps } = {
		[InputSize.XSmall] = {
			container = {
				radius = sharedVariants.sizes[InputSize.XSmall].container.radius,
				size = UDim2.fromOffset(
					sharedVariants.sizes[InputSize.XSmall].container.height,
					sharedVariants.sizes[InputSize.XSmall].container.height
				),
				padding = UDim.new(0, tokens.Size.Size_150),
			},
		},
		[InputSize.Small] = {
			container = {
				radius = sharedVariants.sizes[InputSize.Small].container.radius,
				size = UDim2.fromOffset(
					sharedVariants.sizes[InputSize.Small].container.height,
					sharedVariants.sizes[InputSize.Small].container.height
				),
				padding = UDim.new(0, tokens.Size.Size_200),
			},
		},
		[InputSize.Medium] = {
			container = {
				radius = sharedVariants.sizes[InputSize.Medium].container.radius,
				size = UDim2.fromOffset(
					sharedVariants.sizes[InputSize.Medium].container.height,
					sharedVariants.sizes[InputSize.Medium].container.height
				),
				padding = UDim.new(0, tokens.Size.Size_250),
			},
		},
		[InputSize.Large] = {
			container = {
				radius = sharedVariants.sizes[InputSize.Large].container.radius,
				size = UDim2.fromOffset(
					sharedVariants.sizes[InputSize.Large].container.height,
					sharedVariants.sizes[InputSize.Large].container.height
				),
				padding = UDim.new(0, tokens.Size.Size_300),
			},
		},
	}

	return { common = common, sizes = sizes, types = sharedVariants.types }
end

return function(theme: string, tokens: {[string]: any}, size: InputSize, variant: ButtonVariant, colorNamespace: ColorNamespace?): IconButtonVariantProps
	local variants = useVariants(theme, tokens, "IconButton", variantsMap)
	local resolvedColorMode = colorNamespace or ColorNamespace.Color
	return composeStyleVariant(
		variants.common,
		variants.sizes[size],
		variants.types[variant][resolvedColorMode]
	)
end
