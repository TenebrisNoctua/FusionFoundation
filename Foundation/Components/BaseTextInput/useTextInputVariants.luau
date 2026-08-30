local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useVariants = require(Utility.useVariants)
local composeStyleVariant = require(Utility.composeStyleVariant)
local Types = require(Utility.Types)

local Radius = require(Enums.Radius)
local IconSize = require(Enums.IconSize)
local InputSize = require(Enums.InputSize)
local InputVariant = require(Enums.InputVariant)

local getInputVariantsFactory = require(Components.InputField.getInputVariantsFactory)

type ColorStyle = Types.ColorStyle
type ColorStyleValue = Types.ColorStyleValue
type FontStyle = Types.FontStyle
type Tags = Types.Tags

type InputSize = InputSize.InputSize
type InputVariant = InputVariant.InputVariant
type IconSize = IconSize.IconSize
type Radius = Radius.Radius
type VariantProps = composeStyleVariant.VariantProps

type Icon = typeof(BuilderIcons.Icon)

export type TextInputVariantProps = {
	canvas: {
		tag: string,
	},
	container: {
		minHeight: number,
		horizontalPadding: UDim,
		radius: number,
		bgStyle: ColorStyleValue?,
		strokeStyle: ColorStyleValue?,
		strokeThickness: number?,
		tag: string,
	},
	textBox: {
		tag: string,
		fontStyle: FontStyle,
	},
	icon: {
		size: IconSize,
		style: ColorStyle,
	},
	clearButton: {
		icon: Icon,
		padding: number,
		tag: Tags
	}
}

local function computeProps(props: {
	containerTag: Tags?,
	horizontalPadding: number,
	radius: number,
	typography: FontStyle,
	iconSize: IconSize,
	minContainerHeight: number,
	clearButtonIcon: Icon,
	clearButtonPadding: number,
})
	return {
		container = {
			minHeight = props.minContainerHeight,
			horizontalPadding = UDim.new(0, props.horizontalPadding),
			radius = props.radius,
			tag = props.containerTag,
		},
		textBox = {
			fontStyle = props.typography,
		},
		icon = {
			size = props.iconSize,
		},
		clearButton = {
			icon = props.clearButtonIcon,
			padding = props.clearButtonPadding,
		},
	}
end

local function variantsFactory(tokens: {[string]: any})
	local common = {
		container = {
			strokeStyle = tokens.Color.Stroke.Emphasis,
			strokeThickness = tokens.Stroke.Standard,
			tag = "row",
		},
		textBox = {
			tag = "text-align-x-left text-align-y-center clip content-emphasis gui-object-defaults",
		},
		icon = {
			style = tokens.Color.Content.Muted,
		},
		clearButton = {
			tag = "auto-xy",
		},
	}

	local sizes: { [InputSize]: VariantProps } = {
		[InputSize.XSmall] = computeProps({
			radius = tokens.Radius.Small,
			containerTag = "size-full-600 gap-small",
			horizontalPadding = tokens.Padding.XSmall,
			typography = tokens.Typography.BodySmall,
			iconSize = IconSize.XSmall,
			minContainerHeight = tokens.Size.Size_600,
			clearButtonIcon = BuilderIcons.Icon.XSmall,
			clearButtonPadding = tokens.Padding.XSmall,
		}),
		[InputSize.Small] = computeProps({
			radius = tokens.Radius.Medium,
			containerTag = "size-full-800 gap-medium",
			horizontalPadding = tokens.Padding.Small,
			typography = tokens.Typography.BodyMedium,
			iconSize = IconSize.XSmall,
			minContainerHeight = tokens.Size.Size_800,
			clearButtonIcon = BuilderIcons.Icon.XSmall,
			clearButtonPadding = tokens.Size.Size_150,
		}),
		[InputSize.Medium] = computeProps({
			radius = tokens.Radius.Medium,
			containerTag = "size-full-1000 gap-large",
			horizontalPadding = tokens.Padding.Medium,
			typography = tokens.Typography.BodyMedium,
			iconSize = IconSize.Small,
			minContainerHeight = tokens.Size.Size_1000,
			clearButtonIcon = BuilderIcons.Icon.X,
			clearButtonPadding = tokens.Padding.Small,
		}),
		[InputSize.Large] = computeProps({
			radius = tokens.Radius.Medium,
			containerTag = "size-full-1200 gap-large",
			horizontalPadding = tokens.Padding.Medium,
			typography = tokens.Typography.BodyLarge,
			iconSize = IconSize.Small,
			minContainerHeight = tokens.Size.Size_1200,
			clearButtonIcon = BuilderIcons.Icon.X,
			clearButtonPadding = tokens.Padding.Small,
		}),
	}

	return {
		common = common,
		sizes = sizes,
	}
end

return function(
	theme: string,
	tokens: {[string]: any},
	size: InputSize,
	variant: InputVariant?,
	radius: Radius?,
	focused: boolean?,
	hasError: boolean?
): TextInputVariantProps
	local props = useVariants(theme, tokens, "TextInput", variantsFactory)
	local inputProps = getInputVariantsFactory(tokens)

	local variantAttributes = inputProps.variants[variant or InputVariant.Standard]
	return composeStyleVariant(
		props.common,
		inputProps.sizes[size],
		props.sizes[size],
		if variant ~= InputVariant.Utility then variantAttributes else {},
		if radius then inputProps.radius[radius] else inputProps.defaultRadius[size],
		if focused ~= nil then inputProps.focusedState[focused] else {},
		if hasError ~= nil then inputProps.errorState[hasError] else {},
		if variant == InputVariant.Utility then variantAttributes else {}
	)
end