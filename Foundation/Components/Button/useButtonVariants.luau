local Foundation = script.Parent.Parent.Parent

local Enums = Foundation.Enums
local Utility = Foundation.Utility

local getSharedVariants = require(script.Parent.getSharedVariants)

local composeStyleVariant = require(Utility.composeStyleVariant)
local useVariants = require(Utility.useVariants)
local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)
local ButtonVariant = require(Enums.ButtonVariant)
local ColorNamespace = require(Enums.ColorNamespace)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

type Scope = Types.Scope
type UsedAs<T> = Types.UsedAs<T>
type Use = Types.Use

type InputSize = InputSize.InputSize
type ButtonVariant = ButtonVariant.ButtonVariant
type ColorNamespace = ColorNamespace.ColorNamespace

type ColorStyleValue = Types.ColorStyleValue
type StateLayer = Types.StateLayer
type Stroke = Types.Stroke

type VariantProps = composeStyleVariant.VariantProps
type ButtonStroke = getSharedVariants.ButtonStroke

type ButtonVariantProps = {
	container: {
		tag: string,
		height: number,
		stroke: ButtonStroke?,
		radius: number,
		style: ColorStyleValue,
		stateLayer: StateLayer?,
	},
	content: {
		style: ColorStyleValue,
	},
	text: {
		tag: string,
	},
	icon: {
		size: UDim2,
	},
}

local function variantsMap()
	local sharedVariants = getSharedVariants()
	local themeProvider = ThemeProvider()
	local tokens = unwrap(themeProvider.Tokens)

	local common = {
		container = {
			tag = "row align-x-center align-y-center clip",
		},
		text = {
			tag = "shrink size-0-full auto-x text-truncate-end",
		},
	}

	local size300 = tokens.Size.Size_300
	local size400 = tokens.Size.Size_400
	local size500 = tokens.Size.Size_500
	local size600 = tokens.Size.Size_600

	local sizes: { [InputSize]: VariantProps } = {
		[InputSize.XSmall] = {
			container = {
				tag = "gap-xsmall padding-small",
				radius = sharedVariants.sizes[InputSize.XSmall].container.radius,
				height = sharedVariants.sizes[InputSize.XSmall].container.height,
			},
			icon = {
				size = UDim2.fromOffset(size300, size300),
			},
			text = {
				tag = "text-label-small",
			},
		},
		[InputSize.Small] = {
			container = {
				tag = "gap-xsmall padding-small",
				radius = sharedVariants.sizes[InputSize.Small].container.radius,
				height = sharedVariants.sizes[InputSize.Small].container.height,
			},
			icon = {
				size = UDim2.fromOffset(size400, size400),
			},
			text = {
				tag = "text-title-small",
			},
		},
		[InputSize.Medium] = {
			container = {
				tag = "gap-small padding-medium",
				radius = sharedVariants.sizes[InputSize.Medium].container.radius,
				height = sharedVariants.sizes[InputSize.Medium].container.height,
			},
			icon = {
				size = UDim2.fromOffset(size500, size500),
			},
			text = {
				tag = "text-label-medium",
			},
		},
		[InputSize.Large] = {
			container = {
				tag = "gap-small padding-medium",
				radius = sharedVariants.sizes[InputSize.Large].container.radius,
				height = sharedVariants.sizes[InputSize.Large].container.height,
			},
			icon = {
				size = UDim2.fromOffset(size600, size600),
			},
			text = {
				tag = "text-label-large",
			},
		},
	}

	return { common = common, sizes = sizes, types = sharedVariants.types }
end

local function useButtonVariants(size: InputSize, variant: ButtonVariant, colorNamespace: ColorNamespace?): ButtonVariantProps
	local variants = useVariants("Button", variantsMap)
	local resolvedColorMode = colorNamespace or ColorNamespace.Color
	return composeStyleVariant(
		variants.common,
		variants.sizes[size],
		variants.types[variant][resolvedColorMode]
	)
end

return useButtonVariants