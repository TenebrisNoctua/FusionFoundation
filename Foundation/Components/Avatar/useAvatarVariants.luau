local Foundation = script.Parent.Parent.Parent

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local unwrap = require(Utility.unwrap)
local isState = require(Utility.isState)
local useVariants = require(Utility.useVariants)
local composeStyleVariant = require(Utility.composeStyleVariant)
local Types = require(Utility.Types)

local AvatarSize = require(Enums.AvatarSize)
local UserPresence = require(Enums.UserPresence)
local StatusIndicatorSize = require(Enums.StatusIndicatorSize)
local StatusIndicatorShape = require(Enums.StatusIndicatorShape)
local StatusIndicatorVariant = require(Enums.StatusIndicatorVariant)

type Scope = Types.Scope
type Use = Types.Use

type AvatarSize = AvatarSize.AvatarSize
type UserPresence = UserPresence.UserPresence

type StatusIndicatorVariant = StatusIndicatorVariant.StatusIndicatorVariant
type StatusIndicatorSize = StatusIndicatorSize.StatusIndicatorSize
type StatusIndicatorShape = StatusIndicatorShape.StatusIndicatorShape

type ColorStyle = Types.ColorStyle
type VariantProps = composeStyleVariant.VariantProps

type AvatarVariantProps = {
	container: {
		tag: string,
		stroke: Types.Stroke?,
		backgroundStyle: ColorStyle?,
	},
	avatar: {
		tag: string,
	},
	statusIndicatorBackplate: {
		Position: UDim2,
		AnchorPoint: Vector2,
		tag: string,
		padding: UDim2,
		ZIndex: number,
	},
	statusIndicator: {
		size: StatusIndicatorSize?,
		shape: StatusIndicatorShape?,
		variant: StatusIndicatorVariant?,
		isVisible: boolean,
	}
}

local function variantsMap(tokens: {[string]: any})
	local common = {
		container = { tag = "radius-circle" },
		avatar = { tag = "size-full radius-circle" },
		statusIndicatorBackplate = {
			ZIndex = 2,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.fromScale(1, 1),
			tag = "auto-xy radius-circle bg-surface-0",
			padding = UDim2.fromOffset(tokens.Size.Size_150 / 2, tokens.Size.Size_150 / 2)
		}
	}

	local sizes: { [AvatarSize]: VariantProps } = {
		[AvatarSize.XSmall] = { statusIndicator = { size = StatusIndicatorSize.XSmall } },
		[AvatarSize.Small] = { statusIndicator = { size = StatusIndicatorSize.XSmall } },
		[AvatarSize.Medium] = { statusIndicator = { size = StatusIndicatorSize.Small } },
		[AvatarSize.Large] = { statusIndicator = { size = StatusIndicatorSize.Small } },
		[AvatarSize.XLarge] = { statusIndicator = { size = StatusIndicatorSize.Medium } },
		[AvatarSize.Pictogram] = { statusIndicator = { size = StatusIndicatorSize.Pictogram } }
	}

	local presence: { [UserPresence]: VariantProps } = {
		[UserPresence.InExperience] = {},
		[UserPresence.Away] = {
			statusIndicator = { shape = StatusIndicatorShape.Ring, variant = StatusIndicatorVariant.Neutral },
		},
		[UserPresence.Active] = {
			statusIndicator = { shape = StatusIndicatorShape.Circle, variant = StatusIndicatorVariant.Success },
		},
		[UserPresence.None] = {}
	}

	local sizeStrokes: { [AvatarSize]: number } = {
		[AvatarSize.Small] = tokens.Stroke.Thicker,
		[AvatarSize.Medium] = tokens.Stroke.Thicker,
		[AvatarSize.Large] = tokens.Stroke.Thicker,
		[AvatarSize.XLarge] = tokens.Stroke.Thicker,
		[AvatarSize.Pictogram] = tokens.Stroke.Thicker + tokens.Stroke.Standard
	}

	local iconSizeStrokes: { [AvatarSize]: number } = {
		[AvatarSize.XSmall] = tokens.Stroke.Standard,
		[AvatarSize.Small] = tokens.Stroke.Thick,
		[AvatarSize.Medium] = tokens.Stroke.Thick,
		[AvatarSize.Large] = tokens.Stroke.Thicker,
		[AvatarSize.XLarge] = tokens.Stroke.Thicker,
		[AvatarSize.Pictogram] = tokens.Stroke.Thicker
	}

	return {
		common = common,
		sizes = sizes,
		presence = presence,
		iconSizeStrokes = iconSizeStrokes,
		sizeStrokes = sizeStrokes,
		systemEmphasis = tokens.Color.System.Emphasis
	}
end

return function(
	theme: string,
	tokens: {[string]: any},
	size: AvatarSize,
	presence: UserPresence,
	backplateStyle: ColorStyle?,
	isIconSize: boolean
): AvatarVariantProps
	local props = useVariants(theme, tokens, "Avatar", variantsMap)

	local hasIndicator = not isIconSize and (presence == UserPresence.Active or presence == UserPresence.Away)
	local strokeColor = if not isIconSize and presence == UserPresence.InExperience
		then props.systemEmphasis
		else backplateStyle
	local strokeThickness = if isIconSize then props.iconSizeStrokes[size] else props.sizeStrokes[size]

	return composeStyleVariant(props.common, props.sizes[size], props.presence[presence], {
		container = {
			stroke = if strokeColor
				then {
					Color = strokeColor.Color3,
					Transparency = strokeColor.Transparency,
					Thickness = strokeThickness
				}
				else nil,
			backgroundStyle = backplateStyle
		},
		statusIndicator = {
			isVisible = hasIndicator
		}
	})
end