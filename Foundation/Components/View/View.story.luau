--!nonstrict

local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Children = Fusion.Children

local View = require(Foundation.Components.View)
local Text = require(Foundation.Components.Text)

local ControlState = require(Foundation.Enums.ControlState)
local ThemeProvider = require(Foundation.Providers.ThemeProvider)

type ControlState = ControlState.ControlState

local function Story(props)
	local Scope = props.scope
	local Theme = ThemeProvider()
	
	return View {
		scope = Scope,
		AutomaticSize = Enum.AutomaticSize.XY,
		GroupTransparency = props.GroupTransparency,
		padding = 10,
		stroke = {
			Color = Theme:GetColor("Stroke", "Emphasis"),
			Transparency = Theme:GetTransparency("Stroke", "Emphasis"),
			Thickness = 2
		},
		children = {
			View {
				scope = Scope,
				Size = UDim2.new(0, 100, 0, 100),
				backgroundStyle = Theme:GetStyle("Surface", "Surface_200"),
				tag = "row align-x-center align-y-center",
				children = {
					Text {
						scope = Scope,
						textStyle = Theme:GetStyle("Content", "Emphasis"),
						fontStyle = {
							Font = Enum.Font.BuilderSansMedium,
							FontSize = 24,
							LineHeight = 1,
						},
						Text = "View",
					}
				}
			}
		}
	}
end

local function StoryGuiState(props)
	local Scope = props.scope
	local Theme = ThemeProvider()
	
	local guiState = Scope:Value(ControlState.Initialize)
	local function onStateChanged(new: ControlState)
		guiState:set(new)
	end

	return View {
		scope = Scope,
		Size = UDim2.new(0, 120, 0, 120),
		LayoutOrder = 2,
		GroupTransparency = props.GroupTransparency,
		backgroundStyle = Theme:GetStyle("Extended", "Purple", "Purple_500"),
		layout = {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		},
		onStateChanged = onStateChanged,
		children = {
			Text {
				scope = Scope,
				textStyle = Theme:GetStyle("Content", "Emphasis"),
				Text = guiState,
			}
		}
	}
end

return { 
	fusion = Fusion,
	controls = {
		transparency = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = 0,
			List = {
				0,
				0.25,
				0.75,
			},
			DefIndex = 1
		},
	},
	story = function(props)
		local scope = props.scope
		local transparency = props.controls.transparency
		
		local theme, cleanup = ThemeProvider()
		table.insert(scope, cleanup)
		
		return View {
			scope = scope,
			tag = "row gap-large auto-xy",
			children = {
				Story {
					scope = scope,
					GroupTransparency = transparency
				},
				StoryGuiState {
					scope = scope,
					GroupTransparency = transparency
				},
				theme.StyleLink
			}
		}
	end,
}