local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useAvatarIconVariants = require(script.useAvatarIconVariants)

local Image = require(Components.Image)
local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local isState = require(Utility.isState)
local stripProps = require(Utility.stripProps)
local getRbxThumb = require(Utility.getRbxThumb)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)

local ThumbnailSize = require(Enums.ThumbnailSize)
local ThumbnailType = require(Enums.ThumbnailType)
local AvatarIconSize = require(Enums.AvatarIconSize)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local COMPONENT_ONLY_PROPERTIES = {
	"userId",
	"backgroundStyle",
	"backplateStyle",
	"size"
}

local defaultProps = {
	size = AvatarIconSize.Medium
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type AvatarIconSize = AvatarIconSize.AvatarIconSize

export type AvatarIconProps = {
	userId: UsedAs<number>,
	backgroundStyle: UsedAs<Types.ColorStyle>?,
	backplateStyle: UsedAs<Types.ColorStyle>?,
	size: UsedAs<AvatarIconSize>?
} & Types.CommonProps

return function(avatarIconProps: AvatarIconProps)
	local scope = avatarIconProps.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the AvatarIcon component.")

	local props = withDefaults(avatarIconProps, defaultProps)
	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local backplateStyle = unwrap(props.backplateStyle, use)
		local variantProps = useAvatarIconVariants(unwrap(theme.Theme), tokens, unwrap(props.size, use), backplateStyle)

		local children = {
			Image = Image {
				scope = innerScope,
				Image = if isState(props.userId) then innerScope:Computed(function(use: Use)
					local userId = unwrap(props.userId, use)
					return getRbxThumb(ThumbnailType.AvatarHeadShot, userId, ThumbnailSize.Medium)
				end) else getRbxThumb(ThumbnailType.AvatarHeadShot, props.userId :: number, ThumbnailSize.Medium),
				tag = variantProps.avatar.tag,
				backgroundStyle = props.backgroundStyle
			}
		}

		return innerScope:Hydrate(View(withCommonProps(props, {
			scope = innerScope,
			tag = variantProps.container.tag,
			stroke = variantProps.container.stroke,
			backgroundStyle = backplateStyle,
			Size = UDim2.fromOffset(variantProps.container.size, variantProps.container.size),
			children = children
		})))(stripProps(props, COMPONENT_ONLY_PROPERTIES))
	end)
end