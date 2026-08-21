local Foundation = script.Parent.Parent.Parent

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Text = require(Foundation.Components.Text)
local View = require(Foundation.Components.View)

local useBaseMenuItemVariants = require(script.Parent.useBaseMenuItemVariants)
local BaseMenuContext = require(script.Parent.BaseMenuContext)

local withCommonProps = require(Utility.withCommonProps)
local withDefaults = require(Utility.withDefaults)
local unwrap = require(Utility.unwrap)
local stripProps = require(Utility.stripProps)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)

local COMPONENT_ONLY_PROPERTIES = {
	"text"
}

local defaultProps = {}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

type InputSize = InputSize.InputSize

export type BaseMenuTitleItemProps = {
	scope: Scope,
	text: UsedAs<string>,
} & Types.CommonProps

return function(titleItemProps: BaseMenuTitleItemProps)
	local Scope = titleItemProps.scope
	assert(Scope, "A scope has not been provided for the BaseMenuTitleItem component.")

	local props = withDefaults(titleItemProps, defaultProps)
	local context = BaseMenuContext:now()
	return Scope:Computed(function(use: Use, innerScope: Scope)
		local currentText = unwrap(props.text, use)
		local currentSize = unwrap(context.size)

		local variantProps = useBaseMenuItemVariants(currentSize, false)

		local menuHasCheck = unwrap(context.menuHasCheck, use) == true
		local leftPadding = if menuHasCheck
			then (variantProps.container.paddingLeftWithCheck or 0) + (variantProps.title.checkColumnWidth or 0)
			else (variantProps.container.paddingLeftWithoutCheck or 0)
		local rightPadding = variantProps.container.paddingRight or 0

		local viewProps = withCommonProps(props, {
			scope = innerScope,
			tag = `row align-y-center {variantProps.container.tag}`,
			padding = {
				left = UDim.new(0, leftPadding),
				right = UDim.new(0, rightPadding),
			},
			children = {
				TitleText = Text {
					scope = innerScope,
					Text = currentText,
					tag = variantProps.title.tag,
				},
			},
		})

		return innerScope:Hydrate(View(viewProps))(stripProps(props, COMPONENT_ONLY_PROPERTIES))
	end)
end