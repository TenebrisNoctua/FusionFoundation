local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Text = require(Foundation.Components.Text)
local View = require(Foundation.Components.View)

local useBaseMenuItemVariants = require(script.Parent.useBaseMenuItemVariants)

local withCommonProps = require(Utility.withCommonProps)
local withDefaults = require(Utility.withDefaults)
local unwrap = require(Utility.unwrap)
local stripProps = require(Utility.stripProps)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local Children = Fusion.Children

local COMPONENT_ONLY_PROPERTIES = {
	"text",
	"size",
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
	size: UsedAs<InputSize>,
} & Types.CommonProps

return function(titleItemProps: BaseMenuTitleItemProps)
	local Scope = titleItemProps.scope
	local Theme = ThemeProvider()
	assert(Scope, "A scope has not been provided for the BaseMenuTitleItem component.")

	local props = withDefaults(titleItemProps, defaultProps)

	return Scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(Theme.Tokens, use)
		local currentText = unwrap(props.text, use)
		local currentSize = unwrap(props.size, use)

		local variantProps = useBaseMenuItemVariants(innerScope, tokens, currentSize, false)
		local currentVariantProps = unwrap(variantProps, use)

		local viewProps = withCommonProps(props, {
			scope = innerScope,
			tag = currentVariantProps.container.tag,
			children = {
				TitleText = Text {
					scope = innerScope,
					Text = currentText,
					tag = currentVariantProps.title.tag,
				},
			},
		})

		return innerScope:Hydrate(View(viewProps))(stripProps(props, COMPONENT_ONLY_PROPERTIES))
	end)
end