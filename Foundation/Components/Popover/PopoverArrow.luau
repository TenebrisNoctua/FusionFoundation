local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Dash = PackageManager.getPackage("Dash")

local Utility = Foundation.Utility

local View = require(Foundation.Components.View)

local withCommonProps = require(Utility.withCommonProps)
local withDefaults = require(Utility.withDefaults)
local unwrap = require(Utility.unwrap)
local stripProps = require(Utility.stripProps)
local Types = require(Utility.Types)

local COMPONENT_ONLY_PROPERTIES = {
	"size",
	"position",
	"backgroundStyle",
	"ZIndex",
}

local defaultProps = {}

type Scope = Types.Scope
type UsedAs<T> = Types.UsedAs<T>
type Use = Types.Use
type ColorStyleValue = Types.ColorStyleValue

export type PopoverArrowProps = {
	scope: Scope,
	size: UsedAs<number>,
	position: UsedAs<UDim2>,
	backgroundStyle: UsedAs<ColorStyleValue>,
	ZIndex: UsedAs<number>,
} & Types.CommonProps

return function(arrowProps: PopoverArrowProps)
	local Scope = arrowProps.scope
	assert(Scope, "A scope has not been provided for the PopoverArrow component.")

	local props = withDefaults(arrowProps, defaultProps)

	return Scope:Computed(function(use: Use, innerScope: Scope)
		local currentSize = unwrap(props.size, use)
		local currentPosition = unwrap(props.position, use)
		local currentZIndex = unwrap(props.ZIndex, use)
		local currentBackgroundStyle = unwrap(props.backgroundStyle, use)

		local viewProps = {
			scope = innerScope,
			Size = UDim2.fromOffset(currentSize, currentSize),
			Position = currentPosition,
			Rotation = 45,
			ZIndex = currentZIndex,
			backgroundStyle = currentBackgroundStyle,
			tag = "anchor-center-center"
		}

		return innerScope:Hydrate(View(viewProps))(Dash.join(withCommonProps(props, {}), stripProps(props, COMPONENT_ONLY_PROPERTIES)))
	end)
end