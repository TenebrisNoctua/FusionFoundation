--!nonstrict

local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Children = Fusion.Children

local View = require(Foundation.Components.View)
local Text = require(Foundation.Components.Text)
local ControlState = require(Foundation.Enums.ControlState)

local themeProvider = require(Foundation.Utility.themeProvider)

type ControlState = ControlState.ControlState

local function Story(props)
	local Scope = props.scope
	local Theme = themeProvider(Scope)
	
	return View {
		scope = Scope,
		AutomaticSize = Enum.AutomaticSize.XY,
		GroupTransparency = props.GroupTransparency,
		padding = 10,
		backgroundStyle = {
			Transparency = 1
		},
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
				children = {
					Scope:New "UIListLayout" {
						VerticalAlignment = Enum.VerticalAlignment.Center,
						HorizontalAlignment = Enum.HorizontalAlignment.Center
					},
					
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
	local Theme = themeProvider(Scope)
	
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
			Scope:New "UIListLayout" {
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Center
			},
			
			Text {
				scope = Scope,
				textStyle = Theme:GetStyle("Content", "Emphasis"),
				fontStyle = {
					Font = Enum.Font.BuilderSansMedium,
					FontSize = 24,
					LineHeight = 1,
				},
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
		
		return View {
			scope = scope,
			backgroundStyle = {
				Transparency = 1
			},
			
			children = {
				scope:New "UIListLayout" {
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 16)
				},
				
				Story {
					scope = scope,
					GroupTransparency = transparency
				},
				StoryGuiState {
					scope = scope,
					GroupTransparency = transparency
				}
			}
		}
	end,
}