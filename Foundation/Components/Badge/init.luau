local Foundation = script.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Icon = require(Components.Icon)
local Text = require(Components.Text)
local View = require(Components.View)

local useBadgeVariants = require(script.useBadgeVariants)

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local useScaledValue = require(Utility.useScaledValue)
local Types = require(Utility.Types)

local BadgeVariant = require(Enums.BadgeVariant)
local BadgeShape = require(Enums.BadgeShape)
local BadgeSize = require(Enums.BadgeSize)
local IconPosition = require(Enums.IconPosition)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local MAX_CONTENT_WIDTH = 200

-- DEPRECATED variants are scheduled for removal
local deprecatedVariantsMapping: { [string]: string } = {
	[BadgeVariant.Primary] = BadgeVariant.Contrast,
	[BadgeVariant.Secondary] = BadgeVariant.Standard,
	[BadgeVariant.Neutral] = BadgeVariant.Standard,
}

local defaultProps = {
	variant = BadgeVariant.Contrast,
	shape = BadgeShape.Pill,
	size = BadgeSize.XSmall,
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type BadgeVariant = BadgeVariant.BadgeVariant
type BadgeShape = BadgeShape.BadgeShape
type BadgeSize = BadgeSize.BadgeSize
type IconPosition = IconPosition.IconPosition

type BadgeIcon = {
	name: string,
	variant: any?,
	position: IconPosition,
}

export type BadgeProps = {
	text: UsedAs<string>?,
	icon: UsedAs<(string | BadgeIcon)>?,
	variant: UsedAs<BadgeVariant>?,
	shape: UsedAs<BadgeShape>?,
	size: UsedAs<BadgeSize>?,
} & Types.CommonProps

return function(badgeProps: BadgeProps)
	local scope = badgeProps.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the Badge component.")

	local props = withDefaults(badgeProps, defaultProps)
	local maxWidth = useScaledValue(MAX_CONTENT_WIDTH)

	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local variant = unwrap(props.variant, use)
		variant = deprecatedVariantsMapping[variant] or variant
		local shape = unwrap(props.shape, use)
		local size = unwrap(props.size, use)
		local rawIcon = unwrap(props.icon, use)
		local text = unwrap(props.text, use)

		local icon: BadgeIcon? = if typeof(rawIcon) == "string"
			then { name = rawIcon, position = IconPosition.Left }
			else rawIcon

		local hasText = text ~= nil and #text > 0

		local variantProps = useBadgeVariants(
			unwrap(theme.Theme, use),
			tokens,
			variant,
			shape,
			size,
			if icon then icon.position else nil
		)

		local children: { [string]: any } = {}

		if icon then
			local layoutOrder = if icon.position == IconPosition.Left then 1 else 3
			children.Icon = Icon {
				scope = innerScope,
				name = icon.name,
				variant = icon.variant,
				size = variantProps.icon.size,
				style = variantProps.icon.style,
				LayoutOrder = layoutOrder,
			}
		end

		if hasText then
			children.Text = Text {
				scope = innerScope,
				Text = text,
				textStyle = variantProps.content.style,
				RichText = true,
				LayoutOrder = 2,
				tag = variantProps.text.tag,
				sizeConstraint = {
					MaxSize = Vector2.new(maxWidth, math.huge),
				},
			}
		end

		return View(withCommonProps(props, {
			scope = innerScope,
			backgroundStyle = variantProps.container.backgroundStyle,
			tag = variantProps.container.tag,
			children = children,
		}))
	end)
end
