local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")
local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Chip = require(script.Parent)
local Accessory = require(script.Parent.Accessory)
type Accessory = Accessory.Accessory
type AvatarGroupConfig = Accessory.AvatarGroupConfig

local View = require(Components.View)
local Text = require(Components.Text)
local ScrollView = require(Components.ScrollView)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local StorySection = require(Utility.Stories.StorySection)
local CommonControls = require(Utility.Stories.CommonControls)

local AvatarGroupType = require(Enums.AvatarGroupType)
local ChipSize = require(Enums.ChipSize)
local ChipVariant = require(Enums.ChipVariant)

type Scope = Types.Scope
type Use = Types.Use

local IconName = BuilderIcons.Icon

local function activated(label: string)
	return function()
		print(`Chip: "{label}" activated`)
	end
end

local AVATAR_ACCESSORY: AvatarGroupConfig = {
	type = "AvatarGroup",
	props = {
		avatars = { 24813339, 24813338, 24813337, 24813336 },
		type = AvatarGroupType.Stacked,
		max = 3,
	},
}

-- A Chip only ever accepts a single accessory slot, so the generic
-- "AvatarAccessory" example (used in the Leading/Trailing showcases) uses a
-- single avatar rather than a whole stacked group - the multi-avatar,
-- overflowing AVATAR_ACCESSORY above is reserved for the dedicated
-- "AvatarGroup" section further down.
local SINGLE_AVATAR_ACCESSORY: AvatarGroupConfig = {
	type = "AvatarGroup",
	props = {
		avatars = { 24813339 },
	},
}

local CIRCULAR_ACCESSORY: Accessory = {
	iconName = IconName.CircleX,
	isCircular = true,
}

type AccessoryOption = {
	caption: string,
	text: string,
	value: (string | Accessory)?,
}

local ACCESSORY_OPTIONS: { AccessoryOption } = {
	{ caption = "None", text = "None" },
	{ caption = "Icon", text = "Icon", value = IconName.DiamondSimplified },
	{ caption = "AvatarAccessory", text = "Avatar", value = SINGLE_AVATAR_ACCESSORY },
	{ caption = "CircularAccessory", text = "Circular", value = CIRCULAR_ACCESSORY },
}

local function Group(props: { scope: Scope, caption: string, contentTag: string, LayoutOrder: number?, children: any })
	local scope = props.scope
	return View {
		scope = scope,
		tag = "col gap-medium auto-xy",
		LayoutOrder = props.LayoutOrder,
		children = {
			Caption = Text {
				scope = scope,
				Text = props.caption,
				tag = "text-body-small content-default auto-xy",
				LayoutOrder = 1,
			},
			Content = View {
				scope = scope,
				tag = props.contentTag,
				LayoutOrder = 2,
				children = props.children,
			},
		},
	}
end

local function PlaygroundStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls

	return Chip {
		scope = scope,
		text = controls.text,
		leading = scope:Computed(function(use: Use)
			local value = unwrap(controls.leading, use)
			return if value ~= "" then value else nil
		end),
		trailing = scope:Computed(function(use: Use)
			local value = unwrap(controls.trailing, use)
			return if value ~= "" then value else nil
		end),
		onActivated = activated("Playground"),
		isChecked = controls.isChecked,
		isDisabled = controls.isDisabled,
		size = controls.size,
		variant = controls.variant,
		LayoutOrder = props.layoutOrder,
	}
end

local function SizesStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope

	local children = {}
	for index, size in Dash.values(ChipSize) do
		children[size] = Group {
			scope = scope,
			caption = size :: string,
			contentTag = "row gap-small auto-xy",
			LayoutOrder = index,
			children = {
				Plain = Chip { scope = scope, text = "Chip", onActivated = activated("Plain"), size = size, LayoutOrder = 1 },
				LeadingIcon = Chip {
					scope = scope,
					text = "Chip",
					onActivated = activated("LeadingIcon"),
					size = size,
					leading = IconName.DiamondSimplified,
					LayoutOrder = 2,
				},
				TrailingIcon = Chip {
					scope = scope,
					text = "Chip",
					onActivated = activated("TrailingIcon"),
					size = size,
					trailing = IconName.ChevronSmallDown,
					LayoutOrder = 3,
				},
				AvatarAndClose = Chip {
					scope = scope,
					text = "Chip",
					onActivated = activated("AvatarAndClose"),
					size = size,
					leading = AVATAR_ACCESSORY,
					trailing = CIRCULAR_ACCESSORY,
					LayoutOrder = 4,
				},
			},
		}
	end

	return View {
		scope = scope,
		tag = "col gap-xxlarge auto-xy",
		LayoutOrder = props.layoutOrder,
		children = children,
	}
end

local function VariantsStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope

	local children = {}
	for index, variant in Dash.values(ChipVariant) do
		children[variant] = Group {
			scope = scope,
			caption = variant :: string,
			contentTag = "auto-xy",
			LayoutOrder = index,
			children = {
				Chip { scope = scope, text = variant :: string, onActivated = activated(variant :: string), variant = variant },
			},
		}
	end

	return View {
		scope = scope,
		tag = "row gap-xxlarge auto-xy",
		LayoutOrder = props.layoutOrder,
		children = children,
	}
end

local function IsCheckedStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	return View {
		scope = scope,
		tag = "row gap-xxlarge auto-xy",
		LayoutOrder = props.layoutOrder,
		children = {
			False = Group {
				scope = scope,
				caption = "False",
				contentTag = "auto-xy",
				LayoutOrder = 1,
				children = { Chip { scope = scope, text = "Unchecked", onActivated = activated("Unchecked"), isChecked = false } },
			},
			True = Group {
				scope = scope,
				caption = "True",
				contentTag = "auto-xy",
				LayoutOrder = 2,
				children = { Chip { scope = scope, text = "Checked", onActivated = activated("Checked"), isChecked = true } },
			},
		},
	}
end

local function IsDisabledStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	return View {
		scope = scope,
		tag = "row gap-xxlarge auto-xy",
		LayoutOrder = props.layoutOrder,
		children = {
			False = Group {
				scope = scope,
				caption = "False",
				contentTag = "auto-xy",
				LayoutOrder = 1,
				children = { Chip { scope = scope, text = "Enabled", onActivated = activated("Enabled"), isDisabled = false } },
			},
			True = Group {
				scope = scope,
				caption = "True",
				contentTag = "auto-xy",
				LayoutOrder = 2,
				children = { Chip { scope = scope, text = "Disabled", onActivated = activated("Disabled"), isDisabled = true } },
			},
		},
	}
end

local function LeadingStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	local children = {}
	for index, option in ACCESSORY_OPTIONS do
		children[option.caption] = Group {
			scope = scope,
			caption = option.caption,
			contentTag = "auto-xy",
			LayoutOrder = index,
			children = { Chip { scope = scope, text = option.text, onActivated = activated(option.text), leading = option.value } },
		}
	end
	return View { scope = scope, tag = "row gap-xxlarge auto-xy", LayoutOrder = props.layoutOrder, children = children }
end

local function TrailingStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	local children = {}
	for index, option in ACCESSORY_OPTIONS do
		children[option.caption] = Group {
			scope = scope,
			caption = option.caption,
			contentTag = "auto-xy",
			LayoutOrder = index,
			children = { Chip { scope = scope, text = option.text, onActivated = activated(option.text), trailing = option.value } }
		}
	end
	return View { scope = scope, tag = "row gap-xxlarge auto-xy", LayoutOrder = props.layoutOrder, children = children }
end

-- The overflow avatar only collapses to a "..." glyph
-- when the accessory renders at the icon-sized tier (see AvatarGroup's
-- isEllipsedOverflow check), which Chip's Accessory opts into via
-- isIconSize = true. At larger chip sizes the overflow avatar instead shows
-- a "+N" count.
local function AvatarGroupStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	return Chip {
		scope = scope,
		text = "Filter",
		onActivated = activated("AvatarGroup"),
		leading = AVATAR_ACCESSORY,
		size = ChipSize.Small,
		LayoutOrder = props.layoutOrder
	}
end

return {
	fusion = Fusion,
	summary = "Chip",
	controls = {
		text = "Filter",
		leading = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = IconName.ThreeBarsHorizontalNarrowing,
			List = {
				IconName.ThreeBarsHorizontalNarrowing,
				IconName.Robux,
				IconName.ChevronSmallRight,
				CIRCULAR_ACCESSORY,
				"",
			},
			DefIndex = 1,
		},
		trailing = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = IconName.ChevronLargeDown,
			List = {
				IconName.ChevronLargeDown,
				IconName.CircleX,
				IconName.PlusSmall,
				IconName.X,
				CIRCULAR_ACCESSORY,
				"",
			},
			DefIndex = 1,
		},
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = ChipSize.Medium,
			List = Dash.values(ChipSize),
			DefIndex = 2,
		},
		variant = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = ChipVariant.Standard,
			List = Dash.values(ChipVariant),
			DefIndex = 1,
		},
		isChecked = false,
		isDisabled = false,
		theme = CommonControls.theme,
	},
	story = StoryMiddleware(function(props)
		local scope = props.scope
		local controls = props.controls

		return scope:Computed(function(use: Use, innerScope: Scope)
			unwrap(controls.theme, use)

			return ScrollView {
				scope = innerScope,
				tag = "auto-x size-full padding-x-large padding-top-large col",
				scroll = {
					AutomaticCanvasSize = Enum.AutomaticSize.XY,
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
						title = "Sizes",
						layoutOrder = 2,
						children = { SizesStory { scope = innerScope, layoutOrder = 2 } },
					},
					StorySection {
						scope = innerScope,
						title = "Variants",
						layoutOrder = 3,
						children = { VariantsStory { scope = innerScope, layoutOrder = 2 } },
					},
					StorySection {
						scope = innerScope,
						title = "IsChecked",
						layoutOrder = 4,
						children = { IsCheckedStory { scope = innerScope, layoutOrder = 2 } },
					},
					StorySection {
						scope = innerScope,
						title = "IsDisabled",
						layoutOrder = 5,
						children = { IsDisabledStory { scope = innerScope, layoutOrder = 2 } },
					},
					StorySection {
						scope = innerScope,
						title = "Leading",
						layoutOrder = 6,
						children = { LeadingStory { scope = innerScope, layoutOrder = 2 } },
					},
					StorySection {
						scope = innerScope,
						title = "Trailing",
						layoutOrder = 7,
						children = { TrailingStory { scope = innerScope, layoutOrder = 2 } },
					},
					StorySection {
						scope = innerScope,
						title = "AvatarGroup",
						description = "At Small size, an overflowing avatar accessory collapses to \"...\" instead of a \"+N\" count.",
						layoutOrder = 8,
						children = { AvatarGroupStory { scope = innerScope, layoutOrder = 2 } },
					},
				},
			}
		end)
	end),
}
