local Foundation = script.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useDividerVariants = require(script.useDividerVariants)

local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)

local Orientation = require(Enums.Orientation)
local DividerVariant = require(Enums.DividerVariant)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local defaultProps = {
	variant = DividerVariant.Default,
	orientation = Orientation.Horizontal
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type DividerVariant = DividerVariant.DividerVariant
type Orientation = Orientation.Orientation

export type DividerProps = {
	variant: UsedAs<DividerVariant>?,
	orientation: UsedAs<Orientation>?,
} & Types.CommonProps

return function(dividerProps: DividerProps)
	local scope = dividerProps.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the Divider component.")

	local props = withDefaults(dividerProps, defaultProps)

	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local variant = unwrap(props.variant, use)
		local orientation = unwrap(props.orientation, use)

		local variantProps = useDividerVariants(unwrap(theme.Theme, use), tokens, variant, orientation)
		local isHeavy = variant == DividerVariant.Heavy and orientation ~= Orientation.Vertical

		return View(withCommonProps(props, {
			scope = innerScope,
			tag = variantProps.container.tag,
			children = {
				DividerStroke = View {
					scope = innerScope,
					Size = variantProps.stroke.Size,
					backgroundStyle = variantProps.stroke.backgroundStyle
				},
				DividerLine = if isHeavy
					then View {
						scope = innerScope,
						tag = variantProps.line.tag,
						Position = variantProps.line.position,
						backgroundStyle = variantProps.line.backgroundStyle
					}
					else nil
			}
		}))
	end)
end
