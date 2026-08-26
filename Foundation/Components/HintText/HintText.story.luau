--!nonstrict

local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local HintText = require(Foundation.Components.HintText)
local View = require(Foundation.Components.View)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local function StoryPlayground(props)
	local controls = props.controls

	return HintText {
		scope = props.scope,
		text = controls.text,
		hasError = controls.hasError,
		isDisabled = controls.isDisabled
	}
end

return { 
	fusion = Fusion,
	summary = "Helper text put below inputs",
	controls = {
		text = "Helper text",
		hasError = false,
		isDisabled = false
	},
	story = function(props)
		local scope = props.scope
		local theme, cleanup = ThemeProvider()
		table.insert(scope, cleanup)

		return View {
			scope = scope,
			tag = "auto-xy",
			children = {
				StoryPlayground {
					scope = scope,
					controls = props.controls
				},
				theme.StyleLink
			}
		}
	end
}