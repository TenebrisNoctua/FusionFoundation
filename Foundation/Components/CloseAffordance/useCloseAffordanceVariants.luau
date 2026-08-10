local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Dash = PackageManager.getPackage("Dash")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local getSharedVariants = require(Components.Button.getSharedVariants)

local composeStyleVariant = require(Utility.composeStyleVariant)
local useVariants = require(Utility.useVariants)
local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)
local ButtonVariant = require(Enums.ButtonVariant)
local ColorMode = require(Enums.ColorMode)
local IconSize = require(Enums.IconSize)
local CloseAffordanceVariant = require(Enums.CloseAffordanceVariant)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local Constants = require(Foundation.Constants)

type Scope = Types.Scope
type UsedAs<T> = Types.UsedAs<T>
type Use = Types.Use

type IconSize = IconSize.IconSize
type InputSize = InputSize.InputSize
type ColorMode = ColorMode.ColorMode

type ButtonVariant = ButtonVariant.ButtonVariant
type ColorStyleValue = Types.ColorStyleValue
type StateLayer = Types.StateLayer

type VariantProps = composeStyleVariant.VariantProps
type CloseAffordanceVariant = CloseAffordanceVariant.CloseAffordanceVariant

type CloseAffordanceVariantProps = {
	container: {
		tag: string,
		size: UDim2,
		radius: number,
		padding: UDim,
		stateLayer: StateLayer?,
	},
	content: {
		style: ColorStyleValue,
		iconSize: IconSize,
	}
}

local function variantsMap(use: Use)
	local sharedVariants = getSharedVariants(use)
	local themeProvider = ThemeProvider()
	local tokens = unwrap(themeProvider.Tokens, use)
	
	local common = {
		container = {
			tag = "row align-x-center align-y-center auto-xy clip",
		}
	}
	
	local sizes: { [InputSize]: VariantProps } = {
		[InputSize.XSmall] = {
			container = {
				size = UDim2.fromOffset(
					sharedVariants.sizes[InputSize.XSmall].container.height,
					sharedVariants.sizes[InputSize.XSmall].container.height
				),
				padding = UDim.new(0, tokens.Size.Size_100),
			},
			content = {
				iconSize = IconSize.Small,
			},
		},
		[InputSize.Small] = {
			container = {
				size = UDim2.fromOffset(
					sharedVariants.sizes[InputSize.Small].container.height,
					sharedVariants.sizes[InputSize.Small].container.height
				),
				padding = UDim.new(0, tokens.Size.Size_150),
			},
			content = {
				iconSize = IconSize.Medium,
			},
		},
		[InputSize.Medium] = {
			container = {
				size = UDim2.fromOffset(
					sharedVariants.sizes[InputSize.Medium].container.height,
					sharedVariants.sizes[InputSize.Medium].container.height
				),
				padding = UDim.new(0, tokens.Size.Size_200),
			},
			content = {
				iconSize = IconSize.Large,
			},
		},
	}

	local types: { [CloseAffordanceVariant]: { [ColorMode]: VariantProps } } = {
		[CloseAffordanceVariant.OverMedia] = Dash.map(ColorMode, function(_)
			return {
				container = {
					radius = tokens.Radius.Circle,
					tag = "bg-over-media-100",
				},
				content = { style = tokens.Color.Content.Emphasis },
			}
		end),
		[CloseAffordanceVariant.Utility] = Dash.map(ColorMode, function(colorMode: ColorMode)
			return {
				container = {
					radius = tokens.Radius.Medium,
					stateLayer = {
						mode = Constants.COLOR_MODE_TO_STATE_LAYER_MODE[false][colorMode],
					},
				},
				content = { style = tokens[colorMode].Content.Emphasis },
			}
		end),
	}

	return { common = common, sizes = sizes, types = types }
end

return function(scope: Scope, size: InputSize, variant: CloseAffordanceVariant, colorMode: UsedAs<ColorMode>?): UsedAs<CloseAffordanceVariantProps>
	return scope:Computed(function(use: Use)
		local variants = useVariants(use, "CloseAffordance", variantsMap)
		return composeStyleVariant(
			variants.common,
			variants.sizes[size],
			variants.types[variant][unwrap(colorMode, use) or ColorMode.Color]
		)
	end)
end