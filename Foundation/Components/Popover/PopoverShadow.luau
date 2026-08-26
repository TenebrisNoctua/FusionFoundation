local Foundation = script.Parent.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility

local Image = require(Components.Image)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local Constants = require(Foundation.Constants)

local SHADOW_IMAGE = Constants.SHADOW_IMAGE
local SHADOW_SIZE = Constants.SHADOW_SIZE

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

export type PopoverShadowProps = {
	scope: Scope,
	contentSize: UsedAs<UDim2>,
	position: UsedAs<UDim2>,
	AnchorPoint: UsedAs<Vector2>?,
	ZIndex: UsedAs<number>,
} & Types.CommonProps

return function(shadowProps: PopoverShadowProps)
	local scope = shadowProps.scope
	assert(scope, "A scope has not been provided for the PopoverShadow component.")

	local themeProvider = ThemeProvider()

	local computedSize = scope:Computed(function(use: Use)
		local size = unwrap(shadowProps.contentSize, use)
		return size + UDim2.fromOffset(SHADOW_SIZE, SHADOW_SIZE)
	end)

	return Image {
		scope = scope,
		Image = SHADOW_IMAGE,
		Size = computedSize,
		Position = shadowProps.position,
		AnchorPoint = shadowProps.AnchorPoint,
		ZIndex = shadowProps.ZIndex,
		slice = {
			center = Rect.new(SHADOW_SIZE, SHADOW_SIZE, SHADOW_SIZE + 1, SHADOW_SIZE + 1),
		},
		imageStyle = scope:Computed(function(use: Use)
			local tokens = unwrap(themeProvider.Tokens, use)
			return tokens.Color.Extended.Black.Black_20
		end)
	}
end