local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Dash = PackageManager.getPackage("Dash")

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local composeStyleVariant = require(Utility.composeStyleVariant)
local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)
local ButtonVariant = require(Enums.ButtonVariant)
local StateLayerMode = require(Enums.StateLayerMode)
local ColorNamespace = require(Enums.ColorNamespace)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local Constants = require(Foundation.Constants)

type ColorNamespace = ColorNamespace.ColorNamespace
type ColorStyleValue = Types.ColorStyleValue
type StateLayer = Types.StateLayer
type ButtonVariant = ButtonVariant.ButtonVariant
type StateLayerMode = StateLayerMode.StateLayerMode
type VariantProps = composeStyleVariant.VariantProps
type InputSize = InputSize.InputSize
type Use = Types.Use

type ButtonStyle = {
	Background: ColorStyleValue?,
	Border: ColorStyleValue?,
	Foreground: ColorStyleValue?,
}

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
	actionName: string | { string },
	isInverse: boolean?
): { [ColorNamespace]: VariantProps }
	local themeProvider = ThemeProvider()
	local tokens = unwrap(themeProvider.Tokens)
	local styles: { [ColorNamespace]: any } = {}
	
	for colorNamespace in ColorNamespace do
		local colors = tokens[colorNamespace]
		local buttonStyle = if type(actionName) == "table"
			then { Foreground = Dash.get(colors, actionName) }
			else colors[actionName]
		styles[colorNamespace :: ColorNamespace] = {
			container = {
				style = buttonStyle.Background,
				stroke = if buttonStyle.Border then toStroke(buttonStyle.Border) else nil,
				stateLayer = {
					mode = Constants.COLOR_NAMESPACE_TO_STATE_LAYER_MODE[isInverse or false][colorNamespace :: ColorNamespace],
				},
			},
			content = {
				style = buttonStyle.Foreground,
			},
		}
	end
	return styles
end

-- Returns all button variant types - indexed by variant then by ColorNamespace
local function getButtonTypes(): { [ButtonVariant]: { [ColorNamespace]: VariantProps } }
	return {
		[ButtonVariant.Utility] = createButtonVariantStyles("ActionUtility"),
		[ButtonVariant.Standard] = createButtonVariantStyles("ActionStandard"),
		-- TODO: Update to use StateLayerMode.Dark
		[ButtonVariant.Emphasis] = createButtonVariantStyles("ActionEmphasis"),
		[ButtonVariant.Alert] = createButtonVariantStyles("ActionAlert"),
		[ButtonVariant.SubEmphasis] = createButtonVariantStyles("ActionSubEmphasis", true),
		-- TODO: Update to use StateLayerMode.Inverse
		[ButtonVariant.SoftEmphasis] = createButtonVariantStyles("ActionSoftEmphasis"),
		[ButtonVariant.Subtle] = createButtonVariantStyles("ActionSubtle"),
		[ButtonVariant.Text] = createButtonVariantStyles({ "Content", "Emphasis" }),
		[ButtonVariant.Link] = createButtonVariantStyles({ "Content", "Link" }),
		[ButtonVariant.OverMedia] = createButtonVariantStyles("ActionOverMedia", true),
	}
end

local function getSizes(): { [InputSize]: VariantProps }
	local themeProvider = ThemeProvider()
	local tokens = unwrap(themeProvider.Tokens)
	
	local radiusSmall = tokens.Radius.Small
	local radiusMedium = tokens.Radius.Medium

	local size600 = tokens.Size.Size_600
	local size800 = tokens.Size.Size_800
	local size1000 = tokens.Size.Size_1000
	local size1200 = tokens.Size.Size_1200

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
		}
	}
end

local function getSharedVariants(): {
	sizes: { [InputSize]: VariantProps },
	types: { [ButtonVariant]: { [ColorNamespace]: VariantProps } },
}
	local sizes = getSizes()
	local types = getButtonTypes()

	return { sizes = sizes, types = types }
end

return getSharedVariants