local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Dash = PackageManager.getPackage("Dash")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local getSharedVariants = require(Components.Button.getSharedVariants)

local unwrap = require(Utility.unwrap)
local useVariants = require(Utility.useVariants)
local composeStyleVariant = require(Utility.composeStyleVariant)
local Types = require(Utility.Types)

local IconSize = require(Enums.IconSize)
local InputSize = require(Enums.InputSize)
local ButtonVariant = require(Enums.ButtonVariant)
local ColorNamespace = require(Enums.ColorNamespace)
local CloseAffordanceVariant = require(Enums.CloseAffordanceVariant)

local Constants = require(Foundation.Constants)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type IconSize = IconSize.IconSize
type InputSize = InputSize.InputSize
type ColorNamespace = ColorNamespace.ColorNamespace

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
		stateLayer: StateLayer?
	},
	content: {
		style: ColorStyleValue,
		iconSize: IconSize
	}
}

local function variantsMap(tokens: {[string]: any})
	local sharedVariants = getSharedVariants(tokens)
	
	local common = {
		container = {
			tag = "row align-x-center align-y-center auto-xy clip"
		}
	}
	
	local sizes: { [boolean]: { [InputSize]: VariantProps } } = {
		[true] = {
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
		},
		[false] = {
			[InputSize.XSmall] = { content = { iconSize = IconSize.XSmall } },
			[InputSize.Small] = { content = { iconSize = IconSize.Small } },
			[InputSize.Medium] = { content = { iconSize = IconSize.Large } },
		},
	}

	local types: { [CloseAffordanceVariant]: { [ColorNamespace]: VariantProps } } = {
		[CloseAffordanceVariant.OverMedia] = Dash.map(ColorNamespace, function()
			return {
				container = { tag = "bg-over-media-100" },
				content = { style = tokens.Color.Content.Emphasis },
			}
		end),
		[CloseAffordanceVariant.Utility] = Dash.map(ColorNamespace, function(colorNamespace: ColorNamespace)
			return {
				container = {
					stateLayer = {
						mode = Constants.COLOR_NAMESPACE_TO_STATE_LAYER_MODE[false][colorNamespace],
					},
				},
				content = { style = tokens[colorNamespace].Content.Emphasis },
			}
		end),
	}

	local padding: { [boolean]: VariantProps } = {
		[true] = { container = { radius = tokens.Radius.Medium } },
		[false] = { container = { radius = 0 } },
	}

	local circular: { [boolean]: VariantProps } = {
		[true] = { container = { radius = tokens.Radius.Circle } },
		[false] = {},
	}

	return {
		common = common,
		types = types,
		sizes = sizes,
		padding = padding,
		circular = circular
	}
end

return function(theme: string, tokens: {[string]: any}, size: InputSize, variant: CloseAffordanceVariant, colorNamespace: ColorNamespace?, hasPadding: boolean, isCircular: boolean): CloseAffordanceVariantProps
	local variants = useVariants(theme, tokens, "CloseAffordance", variantsMap)
	local isShapeCircular = variant == CloseAffordanceVariant.OverMedia or isCircular
	return composeStyleVariant(
		variants.common,
		variants.types[variant][colorNamespace or ColorNamespace.Color],
		variants.sizes[hasPadding][size],
		variants.padding[hasPadding],
		variants.circular[isShapeCircular]
	)
end