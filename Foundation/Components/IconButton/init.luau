local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useIconButtonVariants = require(script.useIconButtonVariants)

local Text = require(Components.Text)
local View = require(Components.View)
local Image = require(Components.Image)

local unwrap = require(Utility.unwrap)
local useIconSize = require(Utility.useIconSize)
local withDefaults = require(Utility.withDefaults)
local getIconScale = require(Utility.getIconScale)
local isBuilderIcon = require(Utility.isBuilderIcon)
local withCommonProps = require(Utility.withCommonProps)
local iconMigrationUtils = require(Utility.iconMigrationUtils)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)
local FillBehavior = require(Enums.FillBehavior)
local ButtonVariant = require(Enums.ButtonVariant)
local ColorNamespace = require(Enums.ColorNamespace)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local Constants = require(Foundation.Constants)

local migrationLookup = BuilderIcons.Migration["uiblox"]
local isMigrated = iconMigrationUtils.isMigrated
local isBuilderOrMigratedIcon = iconMigrationUtils.isBuilderOrMigratedIcon

local defaultProps = {
	isDisabled = false,
	size = InputSize.Medium,
	width = UDim.new(0, 0),
	isCircular = false,
	variant = ButtonVariant.Utility
}

-- IconButton and Button variants are not currently aligned, but eventually it should be.
-- For now we don't want to create a new variant enum for IconButton, so we'll use the Button variant enum
-- and extract only the supported variants.
type SupportedIconButtonVariant =
	typeof(ButtonVariant.Standard)
	| typeof(ButtonVariant.Emphasis)
	| typeof(ButtonVariant.Utility)
	| typeof(ButtonVariant.OverMedia)
	| typeof(ButtonVariant.Alert)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type InputSize = InputSize.InputSize
type FillBehavior = FillBehavior.FillBehavior
type ColorNamespace = ColorNamespace.ColorNamespace

type IconVariant = typeof(BuilderIcons.IconVariant)

export type IconButtonProps = {
	-- The scope in which the component will be created.
	scope: Scope,
	onActivated: () -> (),
	isDisabled: UsedAs<boolean>?,
	isCircular: UsedAs<boolean>?,
	-- Size of IconButton. `IconSize` is deprecated - use `InputSize`.
	-- `Large` and `XLarge` `IconSize`s map to `InputSize.Large` and are not supported.
	size: UsedAs<InputSize>?,
	-- Sets a custom width. Prefer wrapping in a fixed-width container and using `fillBehavior = Fill` instead.
	width: UsedAs<UDim>?,
	-- Controls how the IconButton fills space in a layout.
	fillBehavior: UsedAs<FillBehavior>?,
	variant: UsedAs<SupportedIconButtonVariant>?,
	icon: UsedAs<string | { name: string, variant: IconVariant? }>?,
	-- These properties are converted from contexts.
	colorNamespace: UsedAs<ColorNamespace>?,
} & Types.SelectionProps & Types.CommonProps

return function(iconButtonProps: IconButtonProps)
	local scope = iconButtonProps.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the IconButton component.")

	local props = withDefaults(iconButtonProps, defaultProps)

	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local currentIcon = unwrap(props.icon, use)
		local currentSize = unwrap(props.size, use)
		
		local presentation = theme.Presentation
		local iconName = if typeof(currentIcon) == "table" then currentIcon.name else currentIcon
		local iconVariant: IconVariant? = if typeof(currentIcon) == "table" then currentIcon.variant else nil

		local intrinsicIconSize: Vector2?, scale
		if isBuilderOrMigratedIcon(iconName) then
			intrinsicIconSize, scale = nil, 1
		else
			intrinsicIconSize, scale = getIconScale(iconName, currentSize :: any)
		end

		local currentVariant = unwrap(props.variant, use)
		local colorNamespace = if props.colorNamespace then unwrap(props.colorNamespace, use) else unwrap(presentation.colorNamespace, use)
		local variantProps = useIconButtonVariants(unwrap(theme.Theme), tokens, currentSize, currentVariant, colorNamespace)

		local containerSize = variantProps.container.size

		-- Override radius if circular
		local currentIsCircular = unwrap(props.isCircular, use)
		local componentRadius = if currentIsCircular
			then UDim.new(0, tokens.Radius.Circle)
			else UDim.new(0, variantProps.container.radius or tokens.Radius.Large)

		local iconSize = useIconSize(currentSize, isBuilderIcon(iconName), true)

		local cursor = {
			radius = componentRadius,
			offset = tokens.Size.Size_150,
			borderWidth = tokens.Stroke.Thicker,
		}

		-- Width/fillBehavior logic: fillBehavior.Fill takes precedence over width.
		-- Unlike Button, IconButton defaults to a fixed square (containerSize) rather than AutomaticSize
		local currentWidth = unwrap(props.width, use)
		local currentFillBehavior = unwrap(props.fillBehavior, use)

		local fillOverridesWidth = currentFillBehavior == FillBehavior.Fill
		local hasExplicitWidth = currentWidth.Scale ~= 0 or currentWidth.Offset ~= 0
		local sizeX = if fillOverridesWidth then UDim.new(1, 0) elseif hasExplicitWidth then currentWidth else containerSize.X

		local currentIsDisabled = unwrap(props.isDisabled, use)

		local iconChildren = {}

		if isBuilderOrMigratedIcon(iconName) then
			iconChildren.Icon = Text {
				scope = innerScope,
				Text = if isMigrated(iconName) then migrationLookup[iconName].name else iconName,
				fontStyle = {
					Font = BuilderIcons.Font[if isMigrated(iconName)
						then migrationLookup[iconName].variant
						else iconVariant or BuilderIcons.IconVariant.Regular],
					FontSize = iconSize.Y.Offset,
				},
				tag = "position-center-center anchor-center-center",
				Size = iconSize,
				textStyle = variantProps.content.style,
			}
		else
			iconChildren.Icon = Image {
				scope = innerScope,
				tag = "position-center-center anchor-center-center",
				Image = iconName,
				Size = if intrinsicIconSize
					then UDim2.fromOffset(intrinsicIconSize.X, intrinsicIconSize.Y)
					else iconSize,
				imageStyle = variantProps.content.style,
				scale = scale,
			}
		end

		local viewProps = withCommonProps(props, {
			scope = innerScope,
			onActivated = props.onActivated,
			Size = UDim2.new(sizeX, UDim.new(0, containerSize.Y.Offset)),
			flexItem = if currentFillBehavior
				then {
					FlexMode = if currentFillBehavior == FillBehavior.Fill
						then Enum.UIFlexMode.Fill
						else Enum.UIFlexMode.Shrink,
				}
				else nil,
			selection = {
				Selectable = if currentIsDisabled then false else props.Selectable,
				NextSelectionUp = props.NextSelectionUp,
				NextSelectionDown = props.NextSelectionDown,
				NextSelectionLeft = props.NextSelectionLeft,
				NextSelectionRight = props.NextSelectionRight,
			},
			isDisabled = currentIsDisabled,
			stateLayer = variantProps.container.stateLayer,
			padding = variantProps.container.padding,
			cornerRadius = componentRadius,
			backgroundStyle = variantProps.container.style,
			stroke = variantProps.container.stroke,
			cursor = cursor,
			GroupTransparency = if currentIsDisabled then Constants.DISABLED_TRANSPARENCY else nil,
			children = iconChildren
		})

		return View(viewProps)
	end)
end
