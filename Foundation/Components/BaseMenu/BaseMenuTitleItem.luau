local Foundation = script.Parent.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useBaseMenuItemVariants = require(script.Parent.useBaseMenuItemVariants)
local BaseMenuContext = require(script.Parent.BaseMenuContext)

local Text = require(Components.Text)
local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local stripProps = require(Utility.stripProps)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

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
	local scope = titleItemProps.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the BaseMenuTitleItem component.")

	local props = withDefaults(titleItemProps, defaultProps)
	local context = BaseMenuContext:now()
	
	return scope:Computed(function(use: Use, innerScope: Scope)
		local currentText = unwrap(props.text, use)
		local currentSize = unwrap(context.size)

		local variantProps = useBaseMenuItemVariants(unwrap(theme.Theme), unwrap(theme.Tokens, use), currentSize, false)
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
			}
		})

		return innerScope:Hydrate(View(viewProps))(stripProps(props, COMPONENT_ONLY_PROPERTIES))
	end)
end