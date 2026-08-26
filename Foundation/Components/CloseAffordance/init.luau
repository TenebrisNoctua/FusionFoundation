local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useCloseAffordanceVariants = require(script.useCloseAffordanceVariants)

local Icon = require(Components.Icon)
local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)

local Radius = require(Enums.Radius)
local IconSize = require(Enums.IconSize)
local InputSize = require(Enums.InputSize)
local ColorNamespace = require(Enums.ColorNamespace)
local CloseAffordanceVariant = require(Enums.CloseAffordanceVariant)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local Constants = require(Foundation.Constants)

local IconVariant = BuilderIcons.IconVariant

local defaultProps = {
	isDisabled = false,
	size = InputSize.Medium,
	variant = CloseAffordanceVariant.OverMedia,
	isCircular = false,
	hasPadding = true
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type InputSize = InputSize.InputSize
type IconSize = IconSize.IconSize

type IconVariant = typeof(BuilderIcons.IconVariant)
type CloseAffordanceVariant = CloseAffordanceVariant.CloseAffordanceVariant
type ColorNamespace = ColorNamespace.ColorNamespace

type Radius = Radius.Radius

type CloseAffordanceProps = {
	scope: Scope,
	onActivated: () -> (),
	isDisabled: UsedAs<boolean>?,
	size: UsedAs<(typeof(InputSize.XSmall) | typeof(InputSize.Small) | typeof(InputSize.Medium))>?,
	variant: UsedAs<CloseAffordanceVariant>?,
	isCircular: UsedAs<boolean>?,
	hasPadding: UsedAs<boolean>?,
	colorNamespace: UsedAs<ColorNamespace>?
} & Types.SelectionProps & Types.CommonProps

return function(closeAffordanceProps: CloseAffordanceProps)
	local scope = closeAffordanceProps.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the CloseAffordance component.")
	
	local props = withDefaults(closeAffordanceProps, defaultProps)
	
	return scope:Computed(function(use: Use, innerScope: Scope)
		local colorNamespace = if props.colorNamespace then unwrap(props.colorNamespace, use) else unwrap(theme.Presentation.colorNamespace, use)
		local hasPadding = unwrap(props.hasPadding, use)
		local isCircular = unwrap(props.isCircular, use)
		local variant = unwrap(props.variant, use)
		local tokens = unwrap(theme.Tokens, use)
		local size = unwrap(props.size, use)
		
		local variantProps = useCloseAffordanceVariants(unwrap(theme.Tokens), tokens, size, variant, colorNamespace, hasPadding, isCircular)
		local componentRadius = UDim.new(0, variantProps.container.radius)
		
		local cursor = {
			radius = componentRadius,
			offset = tokens.Size.Size_150,
			borderWidth = tokens.Stroke.Thicker
		}
		
		local viewProps = withCommonProps(props, {
			Name = props.Name,
			scope = innerScope,
			Size = variantProps.container.size,
			onActivated = props.onActivated,
			selection = {
				Selectable = if props.isDisabled then false else props.Selectable,
				NextSelectionUp = props.NextSelectionUp,
				NextSelectionDown = props.NextSelectionDown,
				NextSelectionLeft = props.NextSelectionLeft,
				NextSelectionRight = props.NextSelectionRight,
			},
			isDisabled = unwrap(props.isDisabled, use),
			padding = variantProps.container.padding,
			cornerRadius = componentRadius,
			stateLayer = variantProps.container.stateLayer,
			cursor = cursor,
			tag = variantProps.container.tag,
			GroupTransparency = if props.isDisabled then Constants.DISABLED_TRANSPARENCY else nil,
			children = {
				Icon {
					scope = innerScope,
					name = BuilderIcons.Icon.X,
					variant = IconVariant.Regular,
					size = variantProps.content.iconSize,
					style = variantProps.content.style
				}
			}
		})
		
		return View(viewProps)
	end)
end