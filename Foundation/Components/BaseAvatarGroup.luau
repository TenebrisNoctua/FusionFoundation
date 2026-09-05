local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Dash = PackageManager.getPackage("Dash")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Icon = require(Components.Icon)
local Text = require(Components.Text)
local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local isState = require(Utility.isState)
local stripProps = require(Utility.stripProps)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local useCumulativeBackground = require(Utility.useCumulativeBackground)
local Types = require(Utility.Types)

local IconSize = require(Enums.IconSize)
local ColorNamespace = require(Enums.ColorNamespace)
local AvatarGroupType = require(Enums.AvatarGroupType)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local usePresentationContext = require(Foundation.Providers.ThemeProvider.PresentationContext).usePresentationContext

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type AvatarGroupType = AvatarGroupType.AvatarGroupType
type AvatarTable = { userId: UsedAs<number>, userPresence: any? }

export type AvatarData = AvatarTable | UsedAs<number>

export type AvatarLayoutProps = {
	LayoutOrder: number,
	Position: UDim2,
	key: string,
	ZIndex: number,
	backgroundStyle: Types.ColorStyle,
	backplateStyle: Types.ColorStyle,
}

export type AvatarGroupRender = (avatarData: AvatarData, layoutProps: AvatarLayoutProps) -> any

export type baseAvatarGroupProps = {
	type: UsedAs<AvatarGroupType>?,
	max: UsedAs<number>?,
	resolvedSize: UsedAs<number>,
	gap: UsedAs<number>,
	isEllipsedOverflow: UsedAs<boolean>?,
	backplateStyle: UsedAs<Types.ColorStyle>?,
	avatars: { AvatarData },
	renderAvatar: UsedAs<AvatarGroupRender>,
} & Types.CommonProps

local defaultProps = {
	type = AvatarGroupType.Spread,
	isEllipsedOverflow = false,
	max = math.huge
}

local COMPONENT_ONLY_PROPERTIES = {
	"type",
	"max",
	"resolvedSize",
	"gap",
	"isEllipsedOverflow",
	"backplateStyle",
	"avatars",
	"renderAvatar"
}

local function AvatarOverflow(props: {
	count: number,
	size: UDim2,
	isEllipsed: boolean,
	backgroundStyle: Types.ColorStyle,
	backplateStyle: Types.ColorStyle,
	tokens: {[string]: any},
	presentation: {[string]: any},
	scope: Scope
} & Types.CommonProps)
	local scope = props.scope
	local tokens = props.tokens
	local presentation = props.presentation
	local isEllipsed = props.isEllipsed
	
	local backgroundStyle = useCumulativeBackground(scope, props.backplateStyle, props.backgroundStyle)
	local textTag = if isEllipsed then "text-caption-small" else "text-caption-medium"
	local contentStyle = tokens[presentation.colorNamespace or ColorNamespace.Color].Content.Emphasis
	  	
	local children = {}
 	 	 
	if isEllipsed then
		children.Icon = Icon {
			scope = scope,
			name = "three-dots-horizontal",
			size = IconSize.XSmall,
			style = contentStyle
		}
	else
		children.Text = Text {
			scope = scope,
			Text = `+{props.count}`,
			tag = `auto-xy text-align-x-center {textTag}`,
			textStyle = contentStyle
		}
	end
 	  	
	return scope:Hydrate(View(withCommonProps(props, {
		scope = scope,
		Size = props.size,
		backgroundStyle = backgroundStyle,
		tag = "row align-x-center align-y-center radius-circle",
		children = children
	})))(stripProps(props, { "count", "size", "isEllipsed", "backgroundStyle", "backplateStyle" }))
end

return function(baseAvatarGroupProps: baseAvatarGroupProps)
	local scope = baseAvatarGroupProps.scope
	local theme = ThemeProvider()
	local presentationContext = usePresentationContext()
	assert(scope, "A scope has not been provided for the BaseAvatarGroup component.")

	local props = withDefaults(baseAvatarGroupProps, defaultProps)
	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local avatars = unwrap(props.avatars, use)
		local max = unwrap(props.max, use)
		
		local presentation = { colorNamespace = unwrap(presentationContext.colorNamespace, use) }
		local backgroundStyle = tokens[presentation.colorNamespace or ColorNamespace.Color].Shift.Shift_300
		local backplateStyle = unwrap(props.backplateStyle, use) or tokens.Color.Surface.Surface_0

		local size = unwrap(props.resolvedSize, use)
		local itemWidth = size + unwrap(props.gap, use)

		local children = {}
		for index, avatarData in avatars do
			local userId = if isState(avatarData) or typeof(avatarData) == "number"
				then avatarData
				elseif typeof(avatarData) == "table" then ((avatarData :: unknown) :: AvatarTable).userId
				else avatarData
			local stableId = tostring(unwrap(userId))

			local position = UDim2.fromOffset(itemWidth * (index - 1), 0)
			local ZIndex = #avatars - (index - 1)

			if index > max then
				children[index] = AvatarOverflow {
					scope = innerScope,
					count = #avatars - max,
					isEllipsed = unwrap(props.isEllipsedOverflow, use),
					size = UDim2.fromOffset(size, size),
					LayoutOrder = index,
					Position = position,
					ZIndex = ZIndex,
					backgroundStyle = backgroundStyle,
					backplateStyle = backplateStyle,
					tokens = tokens,
					presentation = presentation
				}
				break
			end

			children[index] = props.renderAvatar(innerScope, avatarData, {
				key = stableId,
				LayoutOrder = index,
				Position = position,
				ZIndex = ZIndex,
				backgroundStyle = backgroundStyle,
				backplateStyle = backplateStyle,
			})
		end

		return innerScope:Hydrate(View(withCommonProps(props, {
			scope = innerScope,
			tag = "auto-xy",
			children = children
		})))(stripProps(props, COMPONENT_ONLY_PROPERTIES))
	end)
end