local Foundation = script.Parent.Parent.Parent
local Utility = Foundation.Utility

local Image = require(Foundation.Components.Image)

local withCommonProps = require(Utility.withCommonProps)
local withDefaults = require(Utility.withDefaults)
local unwrap = require(Utility.unwrap)
local stripProps = require(Utility.stripProps)
local Types = require(Utility.Types)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local Constants = require(Foundation.Constants)

local SHADOW_IMAGE = Constants.SHADOW_IMAGE
local SHADOW_SIZE = Constants.SHADOW_SIZE

local COMPONENT_ONLY_PROPERTIES = {
	"contentSize",
	"position",
	"AnchorPoint",
	"ZIndex",
}

local defaultProps = {}

type Scope = Types.Scope
type UsedAs<T> = Types.UsedAs<T>
type Use = Types.Use

export type PopoverShadowProps = {
	scope: Scope,
	contentSize: UsedAs<UDim2>,
	position: UsedAs<UDim2>,
	AnchorPoint: UsedAs<Vector2>?,
	ZIndex: UsedAs<number>,
} & Types.CommonProps

return function(shadowProps: PopoverShadowProps)
	local Scope = shadowProps.scope
	assert(Scope, "A scope has not been provided for the PopoverShadow component.")

	local props = withDefaults(shadowProps, defaultProps)
	local themeProvider = ThemeProvider()

	return Scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(themeProvider.Tokens, use)

		local currentContentSize = unwrap(props.contentSize, use)
		local currentPosition = unwrap(props.position, use)
		local currentAnchorPoint = unwrap(props.AnchorPoint, use)
		local currentZIndex = unwrap(props.ZIndex, use)

		local computedSize = currentContentSize + UDim2.fromOffset(SHADOW_SIZE, SHADOW_SIZE)

		local imageProps = withCommonProps(props, {
			scope = innerScope,
			AnchorPoint = currentAnchorPoint,
			Image = SHADOW_IMAGE,
			Size = computedSize,
			Position = currentPosition,
			ZIndex = currentZIndex,
			slice = {
				center = Rect.new(SHADOW_SIZE, SHADOW_SIZE, SHADOW_SIZE + 1, SHADOW_SIZE + 1),
			},
			imageStyle = tokens.Color.Extended.Black.Black_20,
		})

		return innerScope:Hydrate(Image(imageProps))(stripProps(props, COMPONENT_ONLY_PROPERTIES))
	end)
end