local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local BuilderIcons = PackageManager.getPackage("BuilderIcons")
local IconVariant = BuilderIcons.IconVariant

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useChipVariants = require(script.useChipVariants)
local Accessory = require(script.Accessory)

local Text = require(Components.Text)
local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)

local ChipSize = require(Enums.ChipSize)
local ChipVariant = require(Enums.ChipVariant)
local IconPosition = require(Enums.IconPosition)
local StateLayerMode = require(Enums.StateLayerMode)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local Constants = require(Foundation.Constants)

local defaultProps = {
	isChecked = false,
	Selectable = true,
	isDisabled = false,
	size = ChipSize.Medium,
	variant = ChipVariant.Standard
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

-- DEPRECATED
type Icon = {
	name: string,
	position: IconPosition
}

type ChipSize = ChipSize.ChipSize
type Accessory = Accessory.Accessory
type ChipVariant = ChipVariant.ChipVariant
type IconPosition = IconPosition.IconPosition

export type ChipProps = {
	scope: Scope,
	-- Make required
	text: UsedAs<string>?,
	leading: (UsedAs<string> | Accessory)?,
	trailing: (UsedAs<string> | Accessory)?,
	onActivated: () -> (),
	isChecked: UsedAs<boolean>?,
	size: UsedAs<ChipSize>?,
	variant: UsedAs<ChipVariant>?,

	isDisabled: UsedAs<boolean>?,
	-- DEPRECATED
	icon: (string | Icon)?
} & Types.SelectionProps & Types.CommonProps

return function(chipProps: ChipProps)
	local scope = chipProps.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the Chip component.")

	local props = withDefaults(chipProps, defaultProps)
	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local size = unwrap(props.size, use)
		local variant = unwrap(props.variant, use)
		local isChecked = unwrap(props.isChecked, use)
		local isDisabled = unwrap(props.isDisabled, use)
		local text = unwrap(props.text, use)

		local leadingIcon = unwrap(props.leading, use)
		local trailingIcon = unwrap(props.trailing, use)

		-- Migration step for the deprecated `icon` prop
		if props.icon ~= nil then
			if typeof(props.icon) == "string" then
				leadingIcon = {
					iconName = props.icon,
				} :: Accessory
			else
				local icon = {
					iconName = (props.icon :: Icon).name,
				} :: Accessory
				if (props.icon :: Icon).position == IconPosition.Left then
					leadingIcon = icon
				else
					trailingIcon = icon
				end
			end
		end

		if typeof(leadingIcon) == "table" and (leadingIcon :: Accessory).isCircular then
			(leadingIcon :: any).iconVariant = IconVariant.Filled
		end
		if typeof(trailingIcon) == "table" and (trailingIcon :: Accessory).isCircular then
			(trailingIcon :: any).iconVariant = IconVariant.Filled
		end

		local hasLeading = leadingIcon ~= nil
		local hasTrailing = trailingIcon ~= nil

		local variantProps = useChipVariants(
			unwrap(theme.Theme, use),
			tokens,
			size,
			variant,
			isChecked,
			hasLeading,
			hasTrailing
		)
		
		local cursorBorderWidth = math.floor(tokens.Stroke.Thicker)
		local children: {[string]: any} = {}

		if leadingIcon then
			children.Leading = Accessory {
				scope = innerScope,
				isLeading = true,
				config = leadingIcon :: Accessory,
				size = size,
				chipBackgroundStyle = variantProps.chip.backgroundStyle,
				contentStyle = variantProps.text.contentStyle,
				isDisabled = isDisabled
			}
		end

		if text and text ~= "" then
			children.Text = Text {
				scope = innerScope,
				Text = text,
				textStyle = variantProps.text.contentStyle,
				LayoutOrder = 2,
				tag = variantProps.text.tag,
				padding = variantProps.text.padding
			}
		end

		if trailingIcon then
			children.Trailing = Accessory {
				scope = innerScope,
				isLeading = false,
				config = trailingIcon :: Accessory,
				size = size,
				chipBackgroundStyle = variantProps.chip.backgroundStyle,
				contentStyle = variantProps.text.contentStyle,
				isDisabled = isDisabled
			}
		end

		return View(withCommonProps(props, {
			scope = innerScope,
			isDisabled = isDisabled,
			selection = {
				Selectable = if isDisabled then false else props.Selectable,
				NextSelectionUp = props.NextSelectionUp,
				NextSelectionDown = props.NextSelectionDown,
				NextSelectionLeft = props.NextSelectionLeft,
				NextSelectionRight = props.NextSelectionRight,
			},
			onActivated = props.onActivated,
			stateLayer = if isChecked
				then { mode = StateLayerMode.Inverse }
				else nil,
			backgroundStyle = variantProps.chip.backgroundStyle,
			padding = variantProps.chip.padding,
			cursor = {
				radius = UDim.new(0, tokens.Radius.Circle),
				offset = cursorBorderWidth * 2,
				borderWidth = cursorBorderWidth
			},
			tag = variantProps.chip.tag,
			GroupTransparency = if isDisabled then Constants.DISABLED_TRANSPARENCY else 0,
			children = children
		}))
	end)
end
