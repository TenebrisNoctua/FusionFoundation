--!nonstrict

local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local InputLabel = require(Foundation.Components.InputLabel)
local View = require(Foundation.Components.View)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local InputLabelSize = require(Foundation.Enums.InputLabelSize)

type InputLabelSize = InputLabelSize.InputLabelSize

local function Story(props)
	local Scope = props.scope
	local Theme = ThemeProvider()
	local sizes: { InputLabelSize } = { InputLabelSize.Large, InputLabelSize.Medium, InputLabelSize.Small }
	
	return View {
		scope = Scope,
		tag = "row align-y-center gap-xxlarge auto-xy",
		children = Scope:Computed(function(use, innerScope) 
			local childrenTable = {}
			for i, size in sizes do
				table.insert(childrenTable, InputLabel {
					scope = innerScope,
					Text = props.Text,
					size = size,
					isRequired = props.isRequired,
					isDisabled = props.isDisabled,
					RichText = props.RichText,
					LayoutOrder = i
				})
			end
			return childrenTable
		end)
	}
end

return { 
	fusion = Fusion,
	controls = {
		Text = "Input label",
		isRequired = false,
		isDisabled = false,
		RichText = false
	},
	story = function(props)
		local scope = props.scope
		local Text = props.controls.Text
		local isRequired = props.controls.isRequired
		local RichText = props.controls.RichText
		
		local theme, cleanup = ThemeProvider()
		table.insert(scope, cleanup)

		return View {
			scope = scope,
			children = {
				Story {
					scope = scope,
					Text = Text,
					isRequired = isRequired,
					RichText = RichText
				},
				theme.StyleLink
			}
		}
	end,
}
