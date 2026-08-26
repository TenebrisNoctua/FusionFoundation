local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useStatusIndicatorVariants = require(script.useStatusIndicatorVariants)

local Text = require(Components.Text)
local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local isState = require(Utility.isState)
local stripProps = require(Utility.stripProps)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)

local StatusIndicatorSize = require(Enums.StatusIndicatorSize)
local StatusIndicatorShape = require(Enums.StatusIndicatorShape)
local StatusIndicatorVariant = require(Enums.StatusIndicatorVariant)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local COMPONENT_ONLY_PROPERTIES = {
	"variant",
	"shape",
	"size",
	"max",
	"value"
}

local defaultProps = {
	variant = StatusIndicatorVariant.Standard,
	shape = StatusIndicatorShape.Circle,
	size = StatusIndicatorSize.Small,
	max = math.huge
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type StatusIndicatorSize = StatusIndicatorSize.StatusIndicatorSize
type StatusIndicatorVariant = StatusIndicatorVariant.StatusIndicatorVariant
type StatusIndicatorShape = StatusIndicatorShape.StatusIndicatorShape

type StatusIndicatorEmpty = {
	variant: UsedAs<StatusIndicatorVariant>?,
	shape: UsedAs<StatusIndicatorShape>?,
	size: UsedAs<StatusIndicatorSize>?,
	max: nil,
	value: nil
} & Types.CommonProps

type StatusIndicatorNumeric = {
	variant: UsedAs<StatusIndicatorVariant>?,
	value: UsedAs<number>,
	size: UsedAs<StatusIndicatorSize>?,
	max: UsedAs<number>?,
	shape: nil
}

type StatusIndicatorEmptyProps = StatusIndicatorEmpty & Types.CommonProps
type StatusIndicatorNumericProps = StatusIndicatorNumeric & Types.CommonProps

export type StatusIndicatorProps = StatusIndicatorEmptyProps | StatusIndicatorNumericProps

return function(statusIndicatorProps: StatusIndicatorProps)
	local scope = statusIndicatorProps.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the StatusIndicator component.")

	local props = withDefaults(statusIndicatorProps, defaultProps)
	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local value = unwrap(props.value, use)
		local variant = unwrap(props.variant, use)
		local size = unwrap(props.size, use)
		local max = unwrap(props.max, use)
		
		local refinedShape: StatusIndicatorShape = if value and value > 0 then StatusIndicatorShape.Circle else unwrap(props.shape, use)
		local hasValue = value ~= nil and value > 0
	
		local variantProps = useStatusIndicatorVariants(
			unwrap(theme.Theme),
			tokens,
			variant,
			hasValue,
			refinedShape,
			size
		)

		local function formatValue(value: number)
			if max and value > max then
				return `{max}+`
			else
				return tostring(value)
			end
		end

		local children = {}

		if hasValue and variantProps.content.style then
			children.Text = Text {
				scope = innerScope,
				Text = formatValue(value),
				textStyle = variantProps.content.style,
				fontStyle = {
					Font = variantProps.content.font,
					FontSize = tokens.Typography.LabelSmall.FontSize,
					LineHeight = tokens.Typography.LabelSmall.LineHeight
				},
				tag = variantProps.content.tag
			}
		end

		if refinedShape == StatusIndicatorShape.Ring and variantProps.ring then
			children.InnerRing = View {
				scope = innerScope,
				tag = variantProps.ring.tag,
				Size = variantProps.ring.size
			}
		end

		return innerScope:Hydrate(View(withCommonProps(props, {
			scope = innerScope,
			tag = variantProps.container.tag,
			backgroundStyle = if variantProps.container.backgroundStyle
				then variantProps.container.backgroundStyle
				else nil,
			Size = variantProps.container.size,
			AutomaticSize = if hasValue then nil else Enum.AutomaticSize.XY,
			children = children
		})))(stripProps(props, COMPONENT_ONLY_PROPERTIES))
	end)
end