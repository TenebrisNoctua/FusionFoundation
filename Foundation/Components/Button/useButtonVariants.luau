local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Enums = Foundation.Enums
local Utility = Foundation.Utility
local TypesSource = Utility.Types

local InputSize = require(Enums.InputSize)
local ButtonVariant = require(Enums.ButtonVariant)
local ColorMode = require(Enums.ColorMode)

local composeStyleVariant = require(Utility.composeStyleVariant)
local useVariants = require(Utility.useVariants)
local unwrap = require(Utility.unwrap)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)()
local getSharedVariants = require(script.Parent.getSharedVariants)

local Types = require(TypesSource.Types)

type Scope = Types.Scope
type UsedAs<T> = Types.UsedAs<T>
type Use = Types.Use

type InputSize = InputSize.InputSize
type ButtonVariant = ButtonVariant.ButtonVariant
type ColorMode = ColorMode.ColorMode

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

local function variantsMap(use: Use)
	local sharedVariants = getSharedVariants(use)

	local common = {
		container = {
			tag = "row align-y-center align-x-center clip",
		},
		text = {
			tag = "size-0-full auto-x text-truncate-end shrink",
		},
	}

	-- Fetching token data reactively
	local size300 = unwrap(ThemeProvider:GetTokenData("Size", "Size_300"), use)
	local size400 = unwrap(ThemeProvider:GetTokenData("Size", "Size_400"), use)
	local size500 = unwrap(ThemeProvider:GetTokenData("Size", "Size_500"), use)
	local size600 = unwrap(ThemeProvider:GetTokenData("Size", "Size_600"), use)

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
				tag = "text-title-small",
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
				tag = "text-title-medium",
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
				tag = "text-title-large",
			},
		},
	}

	return { common = common, sizes = sizes, types = sharedVariants.types }
end

local function useButtonVariants(scope: Scope, size: InputSize, variant: ButtonVariant, colorMode: ColorMode?): UsedAs<ButtonVariantProps>
	return scope:Computed(function(use: Use)
		local variants = useVariants(use, "Button", variantsMap)
		return composeStyleVariant(
			variants.common,
			variants.sizes[size],
			variants.types[variant][unwrap(colorMode) or ColorMode.Color]
		)
	end)
end

return useButtonVariants