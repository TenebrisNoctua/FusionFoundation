local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Dash = PackageManager.getPackage("Dash")

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local unwrap = require(Utility.unwrap)
local composeStyleVariant = require(Utility.composeStyleVariant)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)
local ButtonVariant = require(Enums.ButtonVariant)
local StateLayerMode = require(Enums.StateLayerMode)
local ColorNamespace = require(Enums.ColorNamespace)

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
	Foreground: ColorStyleValue?
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
		style: ColorStyleValue
	}
}

export type ButtonStroke = {
	Color: Color3?,
	Transparency: number?
}

-- Stroke color is keyed as Color, not Color3 :(
local function toStroke(token: ColorStyleValue?): ButtonStroke?
	if not token then return nil end
	return {
		Color = token.Color3,
		Transparency = token.Transparency
	}
end

-- Helper function to create a standard button variant style
local function createButtonVariantStyles(
	tokens: {[string]: any},
	actionName: string | { string },
	isInverse: boolean?
): { [ColorNamespace]: VariantProps }
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
				style = buttonStyle.Foreground
			}
		}
	end
	return styles
end

-- Returns all button variant types - indexed by variant then by ColorNamespace
local function getButtonTypes(tokens: {[string]: any}): { [ButtonVariant]: { [ColorNamespace]: VariantProps } }
	return {
		[ButtonVariant.Utility] = createButtonVariantStyles(tokens, "ActionUtility"),
		[ButtonVariant.Standard] = createButtonVariantStyles(tokens, "ActionStandard"),
		-- TODO: Update to use StateLayerMode.Dark
		[ButtonVariant.Emphasis] = createButtonVariantStyles(tokens, "ActionEmphasis"),
		[ButtonVariant.Alert] = createButtonVariantStyles(tokens, "ActionAlert"),
		[ButtonVariant.SubEmphasis] = createButtonVariantStyles(tokens, "ActionSubEmphasis", true),
		-- TODO: Update to use StateLayerMode.Inverse
		[ButtonVariant.SoftEmphasis] = createButtonVariantStyles(tokens, "ActionSoftEmphasis"),
		[ButtonVariant.Subtle] = createButtonVariantStyles(tokens, "ActionSubtle"),
		[ButtonVariant.Text] = createButtonVariantStyles(tokens, { "Content", "Emphasis" }),
		[ButtonVariant.Link] = createButtonVariantStyles(tokens, { "Content", "Link" }),
		[ButtonVariant.OverMedia] = createButtonVariantStyles(tokens, "ActionOverMedia", true)
	}
end

local function getSizes(tokens: {[string]: any}): { [InputSize]: VariantProps }
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

local function getSharedVariants(tokens: {[string]: any}): {
	sizes: { [InputSize]: VariantProps },
	types: { [ButtonVariant]: { [ColorNamespace]: VariantProps } },
}
	local sizes = getSizes(tokens)
	local types = getButtonTypes(tokens)

	return { sizes = sizes, types = types }
end

return getSharedVariants