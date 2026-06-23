--!nonstrict

local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local InputLabel = require(Foundation.Components.InputLabel)
local View = require(Foundation.Components.View)

local themeProvider = require(Foundation.Utility.themeProvider)
local InputLabelSize = require(Foundation.Enums.InputLabelSize)

type InputLabelSize = InputLabelSize.InputLabelSize

local function Story(props)
	local Scope = props.scope
	local Theme = themeProvider(Scope)
	local sizes: { InputLabelSize } = { InputLabelSize.Large, InputLabelSize.Medium, InputLabelSize.Small }
	
	return View {
		scope = Scope,
		AutomaticSize = Enum.AutomaticSize.XY,
		children = Scope:Computed(function(use, innerScope) 
			local childrenTable = {
				innerScope:New "UIListLayout" {
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = UDim.new(0, 24)
				}
			}
			
			-- The size option here is not used, because FusionFoundation does not come with built-in tags.
			-- You can give a tag property depending on the size, or just modify the "Size" property manually.
			
			for i, size in sizes do
				table.insert(childrenTable, InputLabel {
					scope = innerScope,
					Text = props.Text,
					type = props.isRequired,
					RichText = props.RichText,
					LayoutOrder = i,
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundTransparency = 1,
					textStyle = Theme:GetStyle("Content", "Default")
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
		isRequired = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = "None",
			List = {
				"None",
				"Optional",
				"Required"
			},
			DefIndex = 1
		},
		RichText = false
	},
	story = function(props)
		local scope = props.scope
		local Text = props.controls.Text
		local isRequired = props.controls.isRequired
		local RichText = props.controls.RichText

		return Story {
			scope = scope,
			Text = Text,
			isRequired = isRequired,
			RichText = RichText
		}
	end,
}
