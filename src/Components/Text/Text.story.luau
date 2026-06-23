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
	
	return Text {
		scope = Scope,
		Text = props.text,
		Size = UDim2.new(0, 100, 0, 100),
		textStyle = Theme:GetStyle("Content", "Default"), 
		backgroundStyle = {
			Transparency = 1,	
		},
		fontStyle = {
			FontSize = props.textSize,
		},
		LayoutOrder = props.layoutOrder
	}
end

local function StoryGuiState(props)
	local Scope = props.scope
	local Theme = themeProvider(Scope)

	local guiState = Scope:Value(ControlState.Initialize)
	local function onStateChanged(new: ControlState)
		guiState:set(new)
	end
	
	return Text {
		scope = Scope,
		Size = UDim2.new(0, 100, 0, 100),
		Text = Scope:Computed(function(use)
			return "State: " .. use(guiState)
		end),
		textStyle = Theme:GetStyle("Content", "Default"), 
		fontStyle = {
			FontSize = 20,
		},
		backgroundStyle = Theme:GetStyle("Extended", "Purple", "Purple_500"),
		onStateChanged = onStateChanged,
		LayoutOrder = props.layoutOrder
	}
end

return { 
	fusion = Fusion,
	controls = {
		text = "Hello, world!",
		textSize = 24
	},
	story = function(props)
		local scope = props.scope
		local text = props.controls.text
		local textSize = props.controls.textSize

		return View {
			scope = scope,
			backgroundStyle = {
				Transparency = 1
			},

			children = {
				scope:New "UIListLayout" {
					Padding = UDim.new(0, 16),
					SortOrder = Enum.SortOrder.LayoutOrder
				},

				Story {
					scope = scope,
					text = text,
					textSize = textSize,
					layoutOrder = 1
				},
				StoryGuiState {
					scope = scope,
					text = text,
					textSize = textSize,
					layoutOrder = 2
				}
			}
		}
	end,
}