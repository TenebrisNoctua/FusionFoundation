--!nonstrict

local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Text = require(Foundation.Components.Text)
local View = require(Foundation.Components.View)
local ScrollView = require(Foundation.Components.ScrollView)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local ControlState = require(Foundation.Enums.ControlState)

local function StoryScrolling(props)
	local scope = props.scope
	local theme = ThemeProvider()
	
	return View {
		scope = scope,
		tag = "row gap-large auto-xy",
		children = {
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

local function StoryScrollViewWithTags(props)
	local scope = props.scope
	local tag = "row gap-medium bg-surface-100 padding-medium radius-medium size-full-3000"

	local items = {}
	for i = 1, 10 do
		items[`Item{i}`] = Text {
			scope = scope,
			tag = "size-3000-2000 radius-medium bg-shift-100 content-muted",
			Text = `Item {i}`,
			LayoutOrder = i,
		}
	end

	return View {
		scope = scope,
		tag = "col gap-large size-full-0 auto-y",
		children = {
			ScrollView = ScrollView {
				scope = scope,
				tag = tag,
				selection = {
					Selectable = props.selectable,
				},
				scroll = {
					AutomaticCanvasSize = Enum.AutomaticSize.X,
					CanvasSize = UDim2.fromScale(0, 1),
					ScrollingDirection = Enum.ScrollingDirection.X,
					scrollBarVisibility = props.scrollBarVisibility
				},
				LayoutOrder = 1,
				children = items
			},
			TagInfo = Text {
				scope = scope,
				tag = "size-full-200 text-label-small content-default",
				Text = `tag = {tag}`,
				LayoutOrder = 2,
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
		
		local theme, cleanup = ThemeProvider()
		table.insert(scope, cleanup)
		
		return View {
			scope = scope,
			tag = "column gap-large auto-xy",
			children = {
				StoryScrolling {
					scope = scope,
					scrollBarVisibility = scrollBarVisibility,
					selectable = selectable,
				},
				
				StoryScrollViewWithTags {
					scope = scope,
					scrollBarVisibility = scrollBarVisibility,
					selectable = selectable
				},
				
				scope:New "StyleLink" {
					StyleSheet = theme.RegistryStyleSheet
				}
			}
		}
	end,
}