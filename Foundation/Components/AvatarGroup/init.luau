local Foundation = script.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Avatar = require(Components.Avatar)
local getAvatarSize = require(Components.Avatar.getAvatarSize)
local BaseAvatarGroup = require(Components.BaseAvatarGroup)

local unwrap = require(Utility.unwrap)
local stripProps = require(Utility.stripProps)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)
local UserPresence = require(Enums.UserPresence)
local ColorNamespace = require(Enums.ColorNamespace)
local AvatarGroupType = require(Enums.AvatarGroupType)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local COMPONENT_ONLY_PROPERTIES = {
	"type",
	"max",
	"size",
	"backplateStyle",
	"avatars"
}

local defaultProps = {
	type = AvatarGroupType.Spread,
	max = math.huge,
	size = InputSize.Medium
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type InputSize = InputSize.InputSize
type UserPresence = UserPresence.UserPresence
type AvatarGroupType = AvatarGroupType.AvatarGroupType

export type AvatarGroupItem = {
	userId: UsedAs<number>,
	userPresence: UsedAs<UserPresence>?
}

export type AvatarGroupProps = {
	type: UsedAs<AvatarGroupType>?,
	max: UsedAs<number>?,
	size: UsedAs<InputSize>?,
	backplateStyle: UsedAs<Types.ColorStyle>?,
	avatars: { AvatarGroupItem | number }
} & Types.CommonProps

return function(avatarGroupProps: AvatarGroupProps)
	local scope = avatarGroupProps.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the AvatarGroup component.")

	local props = withDefaults(avatarGroupProps, defaultProps)
	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local size = unwrap(props.size, use)
		local type = unwrap(props.type, use)
		
		local presentation = theme.Presentation
		local gap
		if type == AvatarGroupType.Spread then
			gap = tokens.Size.Size_200
		else
			if presentation.isIconSize then
				gap = if size == InputSize.Large or size == InputSize.Medium
					then -tokens.Size.Size_50
					else -tokens.Size.Size_0
			else
				gap = if size == InputSize.XSmall then -tokens.Size.Size_50 else -tokens.Size.Size_100
			end
		end

		local resolvedSize = getAvatarSize(tokens, size, presentation.isIconSize)
		local backplateStyle = unwrap(props.backplateStyle, use) or tokens.Color.Surface.Surface_0

		local function renderAvatarGroupItem(
			scope: Scope,
			avatarData: BaseAvatarGroup.AvatarData,
			layoutProps: BaseAvatarGroup.AvatarLayoutProps
		)
			local userPresence: UserPresence? = nil
			local userId: UsedAs<number>
			if typeof(avatarData) == "table" then
				userPresence = (avatarData :: AvatarGroupItem).userPresence
				userId = (avatarData :: AvatarGroupItem).userId
			else
				userId = avatarData
			end

			return Avatar {
				scope = scope,
				userId = userId,
				backgroundStyle = layoutProps.backgroundStyle,
				backplateStyle = layoutProps.backplateStyle,
				size = size,
				userPresence = userPresence,
				LayoutOrder = layoutProps.LayoutOrder,
				Position = layoutProps.Position,
				ZIndex = layoutProps.ZIndex
			}
		end

		return innerScope:Hydrate(BaseAvatarGroup(withCommonProps(props, {
			scope = innerScope,
			type = type,
			max = props.max,
			resolvedSize = resolvedSize,
			isEllipsedOverflow = size == InputSize.XSmall
				or (presentation.isIconSize and size == InputSize.Small),
			gap = gap,
			backplateStyle = backplateStyle,
			avatars = props.avatars,
			renderAvatar = renderAvatarGroupItem
		})))(stripProps(props, COMPONENT_ONLY_PROPERTIES))
	end)
end