local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Dash = PackageManager.getPackage("Dash")
local Fusion = PackageManager.getPackage("Fusion")
local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local SegmentedControl = require(script.Parent)
local SegmentModule = require(script.Parent.Segment)

local Text = require(Components.Text)
local View = require(Components.View)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local CommonControls = require(Utility.Stories.CommonControls)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)

type Scope = Types.Scope
type Segment = SegmentModule.Segment

local inputSizes = Dash.values(InputSize)

local function Story(props)
	local scope: Scope = props.scope
	local controls = props.controls

	local segments: { Segment } = {
		{ id = "1", text = "Lorem Ipsum" },
		{ id = "2", text = "Lorem Ipsum" },
		{ id = "3", text = "Lorem Ipsum" },
		{ id = "4", text = "Lorem Ipsum" },
		{ id = "5", text = "Lorem Ipsum Long" },
	}

	local iconSegments: { Segment } = {
		{ id = "1", icon = { name = BuilderIcons.Icon.House } },
		{ id = "2", icon = { name = BuilderIcons.Icon.Gear } },
		{ id = "3", icon = { name = BuilderIcons.Icon.MagnifyingGlass } },
	}

	local mixedSegments: { Segment } = {
		{ id = "1", icon = { name = BuilderIcons.Icon.House } },
		{ id = "2", text = "Browse" },
		{ id = "3", icon = { name = BuilderIcons.Icon.Gear } },
	}

	local value = scope:Value(segments[1].id)
	local iconValue = scope:Value(iconSegments[1].id)
	local mixedValue = scope:Value(mixedSegments[1].id)
	local tabsValue = scope:Value(segments[1].id)

	return View {
		scope = scope,
		tag = "col auto-xy gap-small",
		children = {
			TextSegments = SegmentedControl {
				scope = scope,
				size = controls.size,
				isCircular = controls.isCircular,
				segments = segments,
				value = value,
				onActivated = function(id)
					value:set(id)
				end,
				LayoutOrder = 1,
			},
			IconSegments = SegmentedControl {
				scope = scope,
				size = controls.size,
				isCircular = controls.isCircular,
				segments = iconSegments,
				value = iconValue,
				onActivated = function(id)
					iconValue:set(id)
				end,
				LayoutOrder = 2,
			},
			MixedSegments = SegmentedControl {
				scope = scope,
				size = controls.size,
				isCircular = controls.isCircular,
				segments = mixedSegments,
				value = mixedValue,
				onActivated = function(id)
					mixedValue:set(id)
				end,
				LayoutOrder = 3,
			},
			SegmentsAsChild = View {
				scope = scope,
				tag = "col auto-y size-full-0",
				LayoutOrder = 4,
				children = {
					First = Text {
						scope = scope,
						LayoutOrder = 1,
						Text = "I go first!",
						Size = UDim2.fromOffset(50, 50),
					},
					TabsComponent = SegmentedControl {
						scope = scope,
						LayoutOrder = 2,
						size = controls.size,
						isCircular = controls.isCircular,
						segments = segments,
						value = tabsValue,
						onActivated = function(id)
							tabsValue:set(id)
						end,
					},
					Last = Text {
						scope = scope,
						LayoutOrder = 3,
						Text = "I go last!",
						Size = UDim2.fromOffset(50, 50),
					},
				}
			}
		}
	}
end

return {
	summary = "SegmentedControl",
	fusion = Fusion,
	controls = {
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = InputSize.Medium,
			List = inputSizes,
			DefIndex = table.find(inputSizes, InputSize.Medium) or 1,
		},
		isCircular = false,
		theme = CommonControls.theme
	},
	story = StoryMiddleware(Story)
}
