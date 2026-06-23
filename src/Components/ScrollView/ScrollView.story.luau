--!nonstrict

local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Text = require(Foundation.Components.Text)
local View = require(Foundation.Components.View)
local ScrollView = require(Foundation.Components.ScrollView)

local themeProvider = require(Foundation.Utility.themeProvider)
local ControlState = require(Foundation.Enums.ControlState)

local function StoryScrolling(props)
	local scope = props.scope
	local theme = themeProvider(scope)
	
	return View {
		scope = scope,
		AutomaticSize = Enum.AutomaticSize.XY,
		children = {
			scope:New "UIListLayout" {
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4)
			},
			
			ScrollView {
				scope = scope,
				
				LayoutOrder = 2,
				Size = UDim2.new(0, 120, 0, 120),
				layout = {
					FillDirection = Enum.FillDirection.Vertical,
				},
				selection = {
					Selectable = props.selectable,
				},
				scroll = {
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					CanvasSize = UDim2.fromOffset(0, 0),
					ScrollingDirection = Enum.ScrollingDirection.Y,
					scrollBarVisibility = props.scrollBarVisibility,
				},
				children = {
					View {
						scope = scope,
						Size = UDim2.fromOffset(120, 75),
						backgroundStyle = theme:GetStyle("Extended", "Turquoise", "Turquoise_500")
					},
					
					View {
						scope = scope,
						Size = UDim2.fromOffset(120, 75),
						backgroundStyle = theme:GetStyle("Extended", "Magenta", "Magenta_500")
					}
				}
			},
			
			ScrollView {
				scope = scope,
				
				LayoutOrder = 1,
				Size = UDim2.new(0, 120, 0, 120),
				layout = {
					FillDirection = Enum.FillDirection.Horizontal,
				},
				selection = {
					Selectable = props.selectable,
				},
				scroll = {
					AutomaticCanvasSize = Enum.AutomaticSize.X,
					CanvasSize = UDim2.fromOffset(0, 0),
					ScrollingDirection = Enum.ScrollingDirection.X,
					scrollBarVisibility = props.scrollBarVisibility,
				},
				children = {
					View {
						scope = scope,
						Size = UDim2.fromOffset(120, 75),
						backgroundStyle = theme:GetStyle("Extended", "Turquoise", "Turquoise_500")
					},

					View {
						scope = scope,
						Size = UDim2.fromOffset(120, 75),
						backgroundStyle = theme:GetStyle("Extended", "Magenta", "Magenta_500")
					}
				}
			},
		}
	}
end

return {
	fusion = Fusion,
	controls = {
		selectable = true,
		scrollBarVisibility = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = "Auto",
			List = {
				"Auto",
				"Always",
				"None"
			},
			DefIndex = 1
		}
	},
	story = function(props)
		local scope = props.scope
		local scrollBarVisibility = props.controls.scrollBarVisibility
		local selectable = props.controls.selectable
		
		return StoryScrolling {
			scope = scope,
			scrollBarVisibility = scrollBarVisibility,
			selectable = selectable
		}
	end,
}