local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Fusion = PackageManager.getPackage("Fusion")

local Constants = require(Foundation.Constants)
local Types = require(Utility.Types.Types)

local ButtonVariant = require(Enums.ButtonVariant)
local ColorMode = require(Enums.ColorMode)
local StateLayerMode = require(Enums.StateLayerMode)
local InputSize = require(Enums.InputSize)

local composeStyleVariant = require(Utility.composeStyleVariant)
local unwrap = require(Utility.unwrap)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

type ColorStyleValue = Types.ColorStyleValue
type StateLayer = Types.StateLayer
type ButtonVariant = ButtonVariant.ButtonVariant
type ColorMode = ColorMode.ColorMode
type StateLayerMode = StateLayerMode.StateLayerMode
type VariantProps = composeStyleVariant.VariantProps
type InputSize = InputSize.InputSize
type Use = Types.Use

type ButtonStyle = {
	Background: ColorStyleValue?,
	Border: ColorStyleValue?,
	Foreground: ColorStyleValue?,
}

export type ButtonStroke = {
	Color: Color3?,
	Transparency: number?,
}

-- Stroke color is keyed as Color, not Color3 :(
local function toStroke(token: ColorStyleValue?): ButtonStroke?
	if not token then return nil end
	return {
		Color = token.Color3,
		Transparency = token.Transparency,
	}
end

-- Helper function to create a standard button variant style
local function createButtonVariantStyles(
	use: Use,
	actionName: string | { string },
	isInverse: boolean?
): { [ColorMode]: VariantProps }
	local themeProvider = ThemeProvider()
	local buttonStyle: ButtonStyle = {}
	if type(actionName) == "table" then
		buttonStyle.Foreground = unwrap(themeProvider:GetStyle(actionName[1], actionName[2]), use)
	else
		buttonStyle.Background = unwrap(themeProvider:GetStyle(actionName, "Background"), use)
		buttonStyle.Border = unwrap(themeProvider:GetStyle(actionName, "Border", use))
		buttonStyle.Foreground = unwrap(themeProvider:GetStyle(actionName, "Foreground"), use)
	end

	local styles: { [ColorMode]: any } = {}

	for colorMode in ColorMode do
		styles[colorMode :: ColorMode] = {
			container = {
				style = buttonStyle.Background,
				stroke = toStroke(buttonStyle.Border),
				stateLayer = {
					mode = Constants.COLOR_MODE_TO_STATE_LAYER_MODE[isInverse or false][colorMode :: ColorMode],
				},
			},
			content = {
				style = buttonStyle.Foreground,
			},
		}
	end

	return styles
end

type SharedButtonVariantProps = {
	container: {
		height: UDim2,
		stroke: ButtonStroke?,
		radius: number,
		style: ColorStyleValue,
		stateLayer: StateLayer?,
	},
	content: {
		style: ColorStyleValue,
	},
}

local function getButtonTypes(use: Use): { [ButtonVariant]: { [ColorMode]: VariantProps } }
	return {
		[ButtonVariant.Utility] = createButtonVariantStyles(use, "ActionUtility"),
		[ButtonVariant.Standard] = createButtonVariantStyles(use, "ActionStandard"),
		-- TODO: Update to use StateLayerMode.Dark
		[ButtonVariant.Emphasis] = createButtonVariantStyles(use, "ActionEmphasis"),
		[ButtonVariant.Alert] = createButtonVariantStyles(use, "ActionAlert"),
		[ButtonVariant.SubEmphasis] = createButtonVariantStyles(use, "ActionSubEmphasis", true),
		-- TODO: Update to use StateLayerMode.Inverse
		[ButtonVariant.SoftEmphasis] = createButtonVariantStyles(use, "ActionSoftEmphasis"),
		[ButtonVariant.Subtle] = createButtonVariantStyles(use, "ActionSubtle"),
		[ButtonVariant.Text] = createButtonVariantStyles(use, { "Content", "Emphasis" }),
		[ButtonVariant.Link] = createButtonVariantStyles(use, { "Content", "Link" }),
		[ButtonVariant.OverMedia] = createButtonVariantStyles(use, "ActionOverMedia", true),
	}
end

local function getSizes(use: Use): { [InputSize]: VariantProps }
	local themeProvider = ThemeProvider()
	local radiusSmall = unwrap(themeProvider.Tokens).Radius.Small
	local radiusMedium = unwrap(themeProvider.Tokens).Radius.Medium

	local size600 = unwrap(themeProvider.Tokens).Size.Size_600
	local size800 = unwrap(themeProvider.Tokens).Size.Size_800
	local size1000 = unwrap(themeProvider.Tokens).Size.Size_1000
	local size1200 = unwrap(themeProvider.Tokens).Size.Size_1200

	return {
		[InputSize.XSmall] = {
			container = { radius = radiusSmall, height = size600 },
		},
		[InputSize.Small] = {
			container = { radius = radiusMedium, height = size800 },
		},
		[InputSize.Medium] = {
			container = { radius = radiusMedium, height = size1000 },
		},
		[InputSize.Large] = {
			container = { radius = radiusMedium, height = size1200 },
		},
	}
end

local function getSharedVariants(use: Use): {
	sizes: { [InputSize]: VariantProps },
	types: { [ButtonVariant]: { [ColorMode]: VariantProps } }
}
	local sizes = getSizes(use)
	local types = getButtonTypes(use)

	return { sizes = sizes, types = types }
end

return getSharedVariants