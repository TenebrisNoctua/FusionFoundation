local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local StorySection = require(Utility.Stories.StorySection)
local CommonControls = require(Utility.Stories.CommonControls)

local InputSize = require(Enums.InputSize)
local ButtonVariant = require(Enums.ButtonVariant)
local FillBehavior = require(Enums.FillBehavior)
local Orientation = require(Enums.Orientation)

local ButtonGroup = require(script.Parent)
local View = require(Foundation.Components.View)
local ScrollView = require(Foundation.Components.ScrollView)

type InputSize = InputSize.InputSize
type ButtonVariant = ButtonVariant.ButtonVariant
type FillBehavior = FillBehavior.FillBehavior
type Orientation = Orientation.Orientation
type ButtonGroupSize = ButtonGroup.ButtonGroupSize
type ButtonGroupItem = ButtonGroup.ButtonGroupItem

type Scope = Types.Scope
type Use = Types.Use

local function activated(label: string)
	return function()
		print(`ButtonGroup: "{label}" activated`)
	end
end

local function HorizontalHugStory(props)
	local scope = props.scope
	local controls = props.controls

	return ButtonGroup {
		scope = scope,
		LayoutOrder = props.layoutOrder,
		orientation = Orientation.Horizontal,
		size = controls.size,
		buttons = {
			{
				text = "Cancel",
				variant = ButtonVariant.Standard,
				onActivated = activated("Cancel"),
			},
			{
				text = "Accept",
				variant = ButtonVariant.Emphasis,
				onActivated = activated("Accept"),
			},
		} :: { ButtonGroupItem },
	}
end

local function HorizontalFillStory(props)
	local scope = props.scope
	local controls = props.controls

	return ButtonGroup {
		scope = scope,
		LayoutOrder = props.layoutOrder,
		orientation = Orientation.Horizontal,
		fillBehavior = FillBehavior.Fill,
		size = controls.size,
		buttons = {
			{
				text = "Cancel",
				variant = ButtonVariant.Standard,
				onActivated = activated("Cancel"),
			},
			{
				text = "Continue",
				variant = ButtonVariant.SoftEmphasis,
				onActivated = activated("Continue"),
			},
			{
				text = "Accept",
				variant = ButtonVariant.Emphasis,
				onActivated = activated("Accept"),
			},
		} :: { ButtonGroupItem },
	}
end

local function VerticalStory(props)
	local scope = props.scope
	local controls = props.controls

	return ButtonGroup {
		scope = scope,
		LayoutOrder = props.layoutOrder,
		orientation = Orientation.Vertical,
		size = controls.size,
		buttons = {
			{
				text = "Accept and continue",
				variant = ButtonVariant.Emphasis,
				onActivated = activated("Accept and continue"),
			},
			{
				text = "Cancel",
				variant = ButtonVariant.Standard,
				onActivated = activated("Cancel"),
			},
		} :: { ButtonGroupItem },
	}
end

local function VerticalWithIconsStory(props)
	local scope = props.scope
	local controls = props.controls

	return ButtonGroup {
		scope = scope,
		LayoutOrder = props.layoutOrder,
		orientation = Orientation.Vertical,
		size = controls.size,
		buttons = {
			{
				text = "Join experience",
				icon = "play-small",
				variant = ButtonVariant.Emphasis,
				onActivated = activated("Join experience"),
			},
			{
				text = "Add to favorites",
				icon = "heart",
				variant = ButtonVariant.Standard,
				onActivated = activated("Add to favorites"),
			},
		} :: { ButtonGroupItem },
	}
end

local function StatesStory(props)
	local scope = props.scope
	local controls = props.controls

	return ButtonGroup {
		scope = scope,
		LayoutOrder = props.layoutOrder,
		orientation = Orientation.Vertical,
		size = controls.size,
		buttons = {
			{
				text = "Loading",
				variant = ButtonVariant.Emphasis,
				onActivated = activated("Loading"),
				isLoading = true,
			},
			{
				text = "Disabled",
				variant = ButtonVariant.Standard,
				onActivated = activated("Disabled"),
				isDisabled = true,
			},
		} :: { ButtonGroupItem },
	}
end

return {
	fusion = Fusion,
	summary = "ButtonGroup",
	controls = {
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = InputSize.Medium,
			List = { InputSize.Medium, InputSize.Small, InputSize.XSmall },
			DefIndex = 1,
		},
		theme = CommonControls.theme,
	},
	story = StoryMiddleware(function(props)
		local scope = props.scope
		local controls = props.controls

		return ScrollView {
			scope = scope,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.fromScale(1, 0),
			scroll = {
				AutomaticSize = Enum.AutomaticSize.Y,
				ScrollingDirection = Enum.ScrollingDirection.Y,
			},
			tag = "back-clear",
			children = {
				scope:New "UIListLayout" {
					Padding = UDim.new(0, 16),
					SortOrder = Enum.SortOrder.LayoutOrder,
				},

				StorySection {
					scope = scope,
					title = "Horizontal — Hug (default)",
					description = "Buttons size to their content, side by side.",
					layoutOrder = 1,
					children = {
						HorizontalHugStory {
							scope = scope,
							controls = controls,
							layoutOrder = 3,
						}
					}
				},

				StorySection {
					scope = scope,
					title = "Horizontal — Fill",
					description = "Buttons fill the available width evenly using UIFlexItem.",
					layoutOrder = 2,
					children = {
						HorizontalFillStory {
							scope = scope,
							controls = controls,
							layoutOrder = 3,
						}
					}
				},

				StorySection {
					scope = scope,
					title = "Vertical — Basic",
					description = "Buttons stacked vertically, always filling full width.",
					layoutOrder = 3,
					children = {
						VerticalStory {
							scope = scope,
							controls = controls,
							layoutOrder = 3,
						}
					}
				},

				StorySection {
					scope = scope,
					title = "Vertical — With icons",
					description = "Stacked buttons with leading icons.",
					layoutOrder = 4,
					children = {
						VerticalWithIconsStory {
							scope = scope,
							controls = controls,
							layoutOrder = 3,
						}
					}
				},

				StorySection {
					scope = scope,
					title = "Vertical — Disabled & loading",
					description = "Shows loading and disabled states in a group.",
					layoutOrder = 5,
					children = {
						StatesStory {
							scope = scope,
							controls = controls,
							layoutOrder = 3,
						}
					}
				},
			}
		}
	end)
}