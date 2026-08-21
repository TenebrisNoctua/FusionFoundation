local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Utility = Foundation.Utility

local View = require(Foundation.Components.View)

local withCommonProps = require(Utility.withCommonProps)
local withDefaults = require(Utility.withDefaults)
local unwrap = require(Utility.unwrap)
local stripProps = require(Utility.stripProps)
local Types = require(Utility.Types)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local Children = Fusion.Children

local COMPONENT_ONLY_PROPERTIES = {
	"LayoutOrder",
}

local defaultProps = {}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

export type BaseMenuDividerProps = {
	scope: Scope,
	LayoutOrder: UsedAs<number>?,
} & Types.CommonProps

return function(dividerProps: BaseMenuDividerProps)
	local Scope = dividerProps.scope
	local Theme = ThemeProvider()
	assert(Scope, "A scope has not been provided for the BaseMenuDivider component.")

	local props = withDefaults(dividerProps, defaultProps)

	return Scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(Theme.Tokens, use)
		local currentLayoutOrder = unwrap(props.LayoutOrder)

		local viewProps = {
			scope = innerScope,
			LayoutOrder = currentLayoutOrder,
			Size = UDim2.new(1, 0, 0, tokens.Stroke.Standard),
			tag = "row flex-x-fill",
			children = {
				Line = View {
					scope = innerScope,
					tag = "grow size-0-full",
					backgroundStyle = tokens.Color.Stroke.Default,
				}
			},
		}

		return innerScope:Hydrate(View(viewProps))(Dash.join(withCommonProps(props, {}), stripProps(props, COMPONENT_ONLY_PROPERTIES)))
	end)
end