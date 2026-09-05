local Foundation = script.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Icon = require(Components.Icon)
local Text = require(Components.Text)
local View = require(Components.View)
local Button = require(Components.Button)

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)

local Types = require(Utility.Types)
local Translator = require(Utility.Localization.Translator)

local IconSize = require(Enums.IconSize)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local defaultProps = {
	icon = {
		name = "icons/status/oof_xlarge",
		size = IconSize.Large
	},
	text = Translator:FormatByKey("CommonUI.Controls.NoResultsFound"),
	button = {
		icon = "icons/common/refresh",
		text = Translator:FormatByKey("CommonUI.Controls.Action.Refresh"),
		onActivated = nil
	}
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type IconSize = IconSize.IconSize

export type EmptyProps = {
	icon: UsedAs<{
		name: string?,
		size: IconSize?,
	}?>,
	text: UsedAs<string>,
	button: UsedAs<{
		text: string?,
		icon: string?,
		onActivated: (() -> ())?,
	}?>
} & Types.CommonProps

return function(emptyProps: EmptyProps)
	local scope = emptyProps.scope
	assert(scope, "A scope has not been provided for the Empty component.")

	local theme = ThemeProvider()
	local props = withDefaults(emptyProps, defaultProps)

	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local icon = unwrap(props.icon, use)
		local text = unwrap(props.text, use)
		local button = unwrap(props.button, use)

		return View(withCommonProps(props, {
			scope = innerScope,
			tag = "col align-x-center align-y-center gap-small size-full auto-xy",
			children = {
				Icon = if icon
					then Icon {
						scope = innerScope,
						name = icon.name,
						size = icon.size,
						style = tokens.Color.Content.Default,
						LayoutOrder = 1
					}
					else nil,
				Text = Text {
					scope = innerScope,
					Text = text,
					LayoutOrder = 2,
					tag = "size-full-0 auto-y text-body-large text-wrap text-align-x-center content-default"
				},
				Button = if button and button.onActivated
					then Button {
						scope = innerScope,
						text = button.text,
						icon = button.icon,
						onActivated = button.onActivated,
						LayoutOrder = 3
					}
					else nil
			}
		}))
	end)
end
