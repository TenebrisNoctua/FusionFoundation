local Foundation = script.Parent.Parent

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local View = require(script.Parent.View)
local Image = require(script.Parent.Image)
local StatusIndicator = require(script.Parent.StatusIndicator)

local getAvatarSize = require(script.getAvatarSize)
local useAvatarVariants = require(script.useAvatarVariants)

local unwrap = require(Utility.unwrap)
local isState = require(Utility.isState)
local stripProps = require(Utility.stripProps)
local getRbxThumb = require(Utility.getRbxThumb)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)

local AvatarSize = require(Enums.AvatarSize)
local ThumbnailSize = require(Enums.ThumbnailSize)
local ThumbnailType = require(Enums.ThumbnailType)
local UserPresence = require(Enums.UserPresence)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local COMPONENT_ONLY_PROPERTIES = {
	"userId",
	"backgroundStyle",
	"backplateStyle",
	"size",
	"userPresence",
	"isIconSize"
}

local defaultProps = {
	size = AvatarSize.Medium,
	userPresence = UserPresence.None
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type AvatarSize = AvatarSize.AvatarSize
type UserPresence = UserPresence.UserPresence

export type AvatarProps = {
	userId: UsedAs<number>,
	backgroundStyle: UsedAs<Types.ColorStyle>?,
	backplateStyle: UsedAs<Types.ColorStyle>?,
	size: UsedAs<AvatarSize>?,
	userPresence: UsedAs<UserPresence>?,
	isIconSize: UsedAs<boolean>?
} & Types.CommonProps

return function(avatarProps: AvatarProps)
	local scope = avatarProps.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the Avatar component.")

	local props = withDefaults(avatarProps, defaultProps)
	return scope:Computed(function(use: Use, innerScope: Scope)
		local size = unwrap(props.size, use)
		local tokens = unwrap(theme.Tokens, use)
		local userPresence = unwrap(props.userPresence, use)
		local backplateStyle = unwrap(props.backplateStyle, use)
		
		local presentation = theme.Presentation
		local isIconSize = if props.isIconSize ~= nil
			then unwrap(props.isIconSize, use)
			else presentation.isIconSize
		
		local variantProps = useAvatarVariants(
			unwrap(theme.Theme),
			tokens,
			size,
			userPresence,
			backplateStyle,
			isIconSize
		)
		
		local size = getAvatarSize(tokens, size, isIconSize)
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

		if variantProps.statusIndicator.isVisible then
			local indicatorProps = withCommonProps(props, {
				scope = innerScope,
				tag = variantProps.statusIndicatorBackplate.tag,
				padding = variantProps.statusIndicatorBackplate.padding,
				children = {
					StatusIndicatorChild = StatusIndicator {
						scope = innerScope,
						variant = variantProps.statusIndicator.variant,
						shape = variantProps.statusIndicator.shape,
						size = variantProps.statusIndicator.size,
					}
				}
			})
			-- Set after withCommonProps to avoid being overwritten by nil values from props
			indicatorProps.Position = variantProps.statusIndicatorBackplate.Position
			indicatorProps.AnchorPoint = variantProps.statusIndicatorBackplate.AnchorPoint
			indicatorProps.ZIndex = variantProps.statusIndicatorBackplate.ZIndex
			children.Indicator = View(indicatorProps)
		end
		return innerScope:Hydrate(View(withCommonProps(props, {
			scope = innerScope,
			tag = variantProps.container.tag,
			backgroundStyle = variantProps.container.backgroundStyle,
			stroke = variantProps.container.stroke,
			Size = UDim2.fromOffset(size, size),
			children = children
		})))(stripProps(props, COMPONENT_ONLY_PROPERTIES))
	end)
end