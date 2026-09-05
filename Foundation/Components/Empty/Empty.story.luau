local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Empty = require(script.Parent)
local ScrollView = require(Foundation.Components.ScrollView)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local StorySection = require(Utility.Stories.StorySection)
local CommonControls = require(Utility.Stories.CommonControls)

local IconSize = require(Enums.IconSize)

type Scope = Types.Scope
type Use = Types.Use

local function PlaygroundStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls

	return Empty {
		scope = scope,
		icon = scope:Computed(function(use: Use)
			return {
				name = unwrap(controls.iconName, use),
				size = unwrap(controls.iconSize, use),
			}
		end),
		text = scope:Computed(function(use: Use)
			local text = unwrap(controls.text, use)
			return if text ~= "" then text else nil
		end),
		button = scope:Computed(function(use: Use)
			if not unwrap(controls.showButton, use) then return nil end
			return {
				text = unwrap(controls.buttonText, use),
				onActivated = function() end,
			}
		end),
		LayoutOrder = props.layoutOrder,
	}
end

local function WithButtonStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope

	return Empty {
		scope = scope,
		icon = {
			name = "rbxasset://textures/ui/LuaChat/icons/ic-friends.png",
			size = IconSize.XLarge,
		},
		text = "To Party with friends, turn on Party in your privacy settings.",
		button = {
			text = "Privacy Settings",
			icon = "icons/navigation/externallink_medium",
			onActivated = function() end,
		},
		LayoutOrder = props.layoutOrder,
	}
end

return {
	fusion = Fusion,
	summary = "Empty component for displaying emptys",
	controls = {
		text = "To Party with friends, turn on Party in your privacy settings.",
		showButton = false,
		buttonText = "Privacy Settings",
		iconName = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = "icons/status/oof_xlarge",
			List = { "icons/status/oof_xlarge", "icons/status/noconnection_large" },
			DefIndex = 1,
		},
		iconSize = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = IconSize.XLarge,
			List = { IconSize.XLarge, IconSize.Large },
			DefIndex = 1,
		},
		theme = CommonControls.theme,
	},
	story = StoryMiddleware(function(props)
		local scope = props.scope
		local controls = props.controls

		return scope:Computed(function(use: Use, innerScope: Scope)
			unwrap(controls.theme, use)

			return ScrollView {
				scope = innerScope,
				tag = "col size-full padding-large gap-xxlarge",
				scroll = {
					AutomaticCanvasSize = Enum.AutomaticSize.XY	
				},
				children = {
					StorySection {
						scope = innerScope,
						title = "Playground",
						layoutOrder = 1,
						children = { PlaygroundStory { scope = innerScope, controls = controls, layoutOrder = 2 } },
					},
					StorySection {
						scope = innerScope,
						title = "With Button",
						layoutOrder = 2,
						children = { WithButtonStory { scope = innerScope, layoutOrder = 2 } },
					}
				}
			}
		end)
	end)
}
