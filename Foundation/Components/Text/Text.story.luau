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
	
	return Text {
		scope = Scope,
		Text = props.text,
		tag = "auto-xy content-default",
		fontStyle = {
			FontSize = props.textSize,
		},
		LayoutOrder = props.layoutOrder
	}
end

local function StoryGuiState(props)
	local Scope = props.scope
	local Theme = ThemeProvider()

	local guiState = Scope:Value(ControlState.Initialize)
	local function onStateChanged(new: ControlState)
		guiState:set(new)
	end
	
	return Text {
		scope = Scope,
		Text = Scope:Computed(function(use)
			return "State: " .. use(guiState)
		end),
		tag = "col align-x-center align-y-center size-2800 content-default",
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
		
		local theme, cleanup = ThemeProvider()
		table.insert(scope, cleanup)

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
				},
				
				theme.StyleLink
			}
		}
	end,
}