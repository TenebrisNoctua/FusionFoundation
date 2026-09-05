local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Tooltip = require(script.Parent)

local Icon = require(Components.Icon)
local View = require(Components.View)
local ScrollView = require(Components.ScrollView)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local StorySection = require(Utility.Stories.StorySection)
local CommonControls = require(Utility.Stories.CommonControls)

local IconSize = require(Enums.IconSize)
local PopoverSide = require(Enums.PopoverSide)
local PopoverAlign = require(Enums.PopoverAlign)

type Scope = Types.Scope
type Use = Types.Use

-- Used as a constant on purpose so a fresh table isn't rebuilt each render.
local SHORTCUT = table.freeze { Enum.KeyCode.F2, Enum.KeyCode.One, Enum.KeyCode.ButtonR3 }

local LONG_TEXT =
	"Generally we should avoid tooltips with long titles and bodys. Consider using other affordances for sharing contextual information when content expands beyond a few lines."

local function anchorContent(scope: Scope): { Instance }
	return {
		View {
			scope = scope,
			tag = "auto-xy radius-medium bg-surface-100",
			children = {
				Icon {
					scope = scope,
					name = "icons/controls/voice/microphone_off_light",
					size = IconSize.Medium,
				}
			}
		}
	}
end

local function PlaygroundStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls

	return View {
		scope = scope,
		Size = UDim2.new(1, 0, 0, 300),
		tag = "row align-x-center align-y-center",
		LayoutOrder = props.layoutOrder,
		children = {
			Tooltip {
				scope = scope,
				title = controls.title,
				shortcut = SHORTCUT,
				side = controls.side,
				align = controls.align,
				text = scope:Computed(function(use: Use)
					local text = unwrap(controls.text, use)
					return if text ~= "" then text else nil
				end),
				children = anchorContent
			}
		}
	}
end

local function LongTextStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls

	return View {
		scope = scope,
		Size = UDim2.new(1, 0, 0, 300),
		tag = "row align-x-right align-y-center",
		LayoutOrder = props.layoutOrder,
		children = {
			Tooltip {
				scope = scope,
				title = "Title",
				shortcut = SHORTCUT,
				side = controls.side,
				align = controls.align,
				text = LONG_TEXT,
				children = anchorContent
			}
		}
	}
end

local function OnlyTitleStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls

	return View {
		scope = scope,
		tag = "row auto-xy",
		LayoutOrder = props.layoutOrder,
		children = {
			Tooltip {
				scope = scope,
				title = controls.title,
				shortcut = SHORTCUT,
				side = controls.side,
				align = controls.align,
				children = anchorContent
			}
		}
	}
end

local function ShortTextStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls

	return View {
		scope = scope,
		Size = UDim2.new(1, 0, 0, 300),
		tag = "row align-x-center align-y-center",
		LayoutOrder = props.layoutOrder,
		children = {
			Tooltip {
				scope = scope,
				title = "Test",
				shortcut = SHORTCUT,
				side = controls.side,
				align = controls.align,
				text = "Hi!",
				children = anchorContent
			}
		}
	}
end

return {
	fusion = Fusion,
	summary = "Tooltip",
	controls = {
		title = "Title",
		text = "Tooltip body text",
		side = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = PopoverSide.Right,
			List = Dash.values(PopoverSide),
			DefIndex = 4,
		},
		align = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = PopoverAlign.Start,
			List = Dash.values(PopoverAlign),
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
						title = "Long text",
						layoutOrder = 2,
						children = { LongTextStory { scope = innerScope, controls = controls, layoutOrder = 2 } },
					},
					StorySection {
						scope = innerScope,
						title = "Only title",
						layoutOrder = 3,
						children = { OnlyTitleStory { scope = innerScope, controls = controls, layoutOrder = 2 } },
					},
					StorySection {
						scope = innerScope,
						title = "Short text",
						layoutOrder = 4,
						children = { ShortTextStory { scope = innerScope, controls = controls, layoutOrder = 2 } },
					}
				}
			}
		end)
	end)
}
