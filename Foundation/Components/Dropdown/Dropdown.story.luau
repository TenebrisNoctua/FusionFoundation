local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")
local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Utility = Foundation.Utility
local Enums = Foundation.Enums
local Components = Foundation.Components

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local StorySection = require(Utility.Stories.StorySection)
local CommonControls = require(Utility.Stories.CommonControls)

local InputSize = require(Enums.InputSize)
local InputVariant = require(Enums.InputVariant)
local BadgeVariant = require(Enums.BadgeVariant)

local View = require(Components.View)
local Text = require(Components.Text)
local Dropdown = require(Components.Dropdown)
local ScrollView = require(Components.ScrollView)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type ItemId = Types.ItemId
type DropdownItem = Dropdown.DropdownItem
type DropdownItems = Dropdown.DropdownItems

local LEADING_ICON_PALETTE = {
	BuilderIcons.Icon.Pencil,
	BuilderIcons.Icon.ClipboardPencil,
	BuilderIcons.Icon.TextBBold,
	BuilderIcons.Icon.PaperAirplane,
	BuilderIcons.Icon.TwoStackedSquares,
	BuilderIcons.Icon.TrashCan
}

local HINT_PALETTE = { "\u{2318}B", "\u{2318}I", "\u{2318}C", "\u{2318}V", "\u{2318}S", "\u{2318}Z" }

local BADGE_PALETTE = {
	{ text = "New", variant = BadgeVariant.Success },
	{ text = "Beta", variant = BadgeVariant.Warning },
	{ text = "Pro", variant = BadgeVariant.Contrast },
	{ text = "Soon", variant = BadgeVariant.Neutral },
}

local SHOWCASE_WIDTH = UDim.new(0, 220)

local NONE = "None"

local LEADING_CHOICES = { "Icon", "Avatar", "Mixed", NONE }
local TRAILING_CHOICES = { "Hint", "Badge", "Mixed", NONE }

local function leadingFor(mode: string?, index: number): any
	if mode == nil or mode == NONE then
		return nil
	end
	if mode == "Avatar" then
		return { type = "Avatar", userId = 24813339 } :: any
	end
	if mode == "Mixed" then
		local r = (index - 1) % 3
		if r == 1 then
			return { type = "Avatar", userId = 24813339 } :: any
		elseif r == 2 then
			return nil
		end
	end
	return { iconName = LEADING_ICON_PALETTE[((index - 1) % #LEADING_ICON_PALETTE) + 1] } :: any
end

local function trailingFor(mode: string?, index: number): any
	if mode == nil or mode == NONE then
		return nil
	end
	if mode == "Hint" then
		return { type = "Hint", text = HINT_PALETTE[((index - 1) % #HINT_PALETTE) + 1] } :: any
	end
	if mode == "Badge" then
		local b = BADGE_PALETTE[((index - 1) % #BADGE_PALETTE) + 1]
		return { type = "Badge", text = b.text, variant = b.variant } :: any
	end
	if index % 2 == 1 then
		return { type = "Hint", text = HINT_PALETTE[((index - 1) % #HINT_PALETTE) + 1] } :: any
	end
	local b = BADGE_PALETTE[((index - 1) % #BADGE_PALETTE) + 1]
	return { type = "Badge", text = b.text, variant = b.variant } :: any
end

local function getItems(hasIcon: boolean?): DropdownItems
	local icon = if hasIcon then BuilderIcons.Icon.ShieldCheck else nil
	return {
		{ id = "A", text = "Item A", icon = icon },
		{ id = "B", text = "Item B", isDisabled = true },
		{ id = "G", text = "Long text item that should be truncated in the dropdown menu" },
		{ id = "C", text = "Item C", icon = icon },
	}
end

local function DemoDropdown(props: {
	scope: Scope,
	label: UsedAs<string>,
	size: UsedAs<InputSize.InputSize>?,
	variant: UsedAs<InputVariant.InputVariant>?,
	isDisabled: UsedAs<boolean>?,
	hasError: UsedAs<boolean>?,
	hasIcon: boolean?,
	placeholder: UsedAs<string>?,
	hint: UsedAs<string>?,
	items: UsedAs<DropdownItems>?,
	width: UsedAs<UDim>?,
	maxHeight: UsedAs<number>?,
	layoutOrder: number?,
	name: string?
})
	local scope = props.scope
	local value = scope:Value(nil :: ItemId?)

	return Dropdown {
		Name = props.name,
		scope = scope,
		value = value,
		placeholder = props.placeholder,
		onItemChanged = function(itemId: ItemId)
			value:set(itemId)
		end,
		hasError = props.hasError,
		isDisabled = props.isDisabled,
		items = props.items or getItems(props.hasIcon),
		size = props.size,
		variant = props.variant,
		label = props.label,
		hint = props.hint,
		width = props.width,
		maxHeight = props.maxHeight,
		LayoutOrder = props.layoutOrder
	}
end

local function Label(scope: Scope, text: string, layoutOrder: number)
	return Text {
		scope = scope,
		Text = text,
		tag = "auto-xy text-label-medium content-muted",
		LayoutOrder = layoutOrder,
	}
end

local function Section(scope: Scope, title: string, layoutOrder: number, containerTag: string, children: { [string]: any })
	return View {
		scope = scope,
		tag = "col gap-xsmall " .. containerTag,
		LayoutOrder = layoutOrder,
		children = {
			Label = Label(scope, title, 1),
			Content = View {
				scope = scope,
				tag = containerTag,
				LayoutOrder = 2,
				children = children,
			},
		},
	}
end

-- Interactive playground bound to the shared controls above.
local function PlaygroundStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls

	local items = scope:Computed(function(use: Use)
		local leadingMode = unwrap(controls.leading, use)
		local trailingMode = unwrap(controls.trailing, use)
		local baseTexts = { "Action one", "Action two", "Action three", "Other one", "Other two", "Other three" }
		local built: DropdownItems = {}
		for index, text in baseTexts do
			table.insert(built, {
				id = `item-{index}`,
				text = text,
				leading = leadingFor(leadingMode, index),
				trailing = trailingFor(trailingMode, index),
				isDisabled = index == 5,
			})
		end
		return built
	end)

	local placeholder = scope:Computed(function(use: Use)
		if unwrap(controls.hasPlaceholder, use) then
			return unwrap(controls.placeholder, use)
		end
		return nil
	end)

	local hint = scope:Computed(function(use: Use)
		if unwrap(controls.hasHint, use) then
			return unwrap(controls.hint, use)
		end
		return nil
	end)

	local width = scope:Computed(function(use: Use)
		return UDim.new(0, unwrap(controls.width, use))
	end)

	return DemoDropdown {
		name = "Test",
		scope = scope,
		label = controls.label,
		size = controls.size,
		variant = controls.variant,
		isDisabled = controls.isDisabled,
		hasError = controls.hasError,
		placeholder = placeholder,
		hint = hint,
		width = width,
		items = items,
		layoutOrder = props.layoutOrder
	}
end

local function SizesStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	return View {
		scope = scope,
		tag = "col gap-xlarge size-full-0 auto-y",
		LayoutOrder = props.layoutOrder,
		children = {
			Large = Section(scope, "Large", 1, "auto-xy", {
				Dropdown = DemoDropdown {
					scope = scope,
					label = "Label",
					size = InputSize.Large,
					placeholder = "Select an option",
					width = SHOWCASE_WIDTH,
				},
			}),
			Medium = Section(scope, "Medium", 2, "auto-xy", {
				Dropdown = DemoDropdown {
					scope = scope,
					label = "Label",
					size = InputSize.Medium,
					placeholder = "Select an option",
					width = SHOWCASE_WIDTH,
				},
			}),
			Small = Section(scope, "Small", 3, "auto-xy", {
				Dropdown = DemoDropdown {
					scope = scope,
					label = "Label",
					size = InputSize.Small,
					placeholder = "Select an option",
					width = SHOWCASE_WIDTH,
				},
			}),
			XSmall = Section(scope, "XSmall", 4, "auto-xy", {
				Dropdown = DemoDropdown {
					scope = scope,
					label = "Label",
					size = InputSize.XSmall,
					placeholder = "Select an option",
					width = SHOWCASE_WIDTH,
				},
			}),
		},
	}
end

local function VariantsStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	return View {
		scope = scope,
		tag = "col gap-xlarge size-full-0 auto-y",
		LayoutOrder = props.layoutOrder,
		children = {
			Standard = Section(scope, "Standard", 1, "auto-xy", {
				Dropdown = DemoDropdown {
					scope = scope,
					label = "Label",
					variant = InputVariant.Standard,
					placeholder = "Select an option",
					width = SHOWCASE_WIDTH,
				},
			}),
			Contrast = Section(scope, "Contrast", 2, "auto-xy", {
				Dropdown = DemoDropdown {
					scope = scope,
					label = "Label",
					variant = InputVariant.Contrast,
					placeholder = "Select an option",
					width = SHOWCASE_WIDTH,
				},
			}),
			Utility = Section(scope, "Utility", 3, "auto-xy", {
				Dropdown = DemoDropdown {
					scope = scope,
					label = "Label",
					variant = InputVariant.Utility,
					placeholder = "Select an option",
					width = SHOWCASE_WIDTH,
				},
			}),
		},
	}
end

local function StatesStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	return View {
		scope = scope,
		tag = "col gap-xlarge size-full-0 auto-y",
		LayoutOrder = props.layoutOrder,
		children = {
			Default = Section(scope, "Default", 1, "auto-xy", {
				Dropdown = DemoDropdown {
					scope = scope,
					label = "Label",
					placeholder = "Select an option",
					width = SHOWCASE_WIDTH,
				},
			}),
			WithHint = Section(scope, "With hint", 2, "auto-xy", {
				Dropdown = DemoDropdown {
					scope = scope,
					label = "Label",
					placeholder = "Select an option",
					hint = "Pick wisely",
					width = SHOWCASE_WIDTH,
				},
			}),
			Disabled = Section(scope, "Disabled", 3, "auto-xy", {
				Dropdown = DemoDropdown {
					scope = scope,
					label = "Label",
					placeholder = "Select an option",
					isDisabled = true,
					width = SHOWCASE_WIDTH,
				},
			}),
			Error = Section(scope, "Error", 4, "auto-xy", {
				Dropdown = DemoDropdown {
					scope = scope,
					label = "Label",
					placeholder = "Select an option",
					hasError = true,
					hint = "This field is required",
					width = SHOWCASE_WIDTH,
				},
			}),
		},
	}
end

local function WidthsStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	local narrowItems: DropdownItems = {
		{ id = "A", text = "Item A" },
		{ id = "B", text = "Item B", isDisabled = true },
	}
	return View {
		scope = scope,
		tag = "col gap-xlarge size-full-0 auto-y",
		LayoutOrder = props.layoutOrder,
		children = {
			NarrowNarrow = Section(scope, "Narrow dropdown - narrow items", 1, "auto-xy", {
				Dropdown = DemoDropdown {
					scope = scope,
					label = "Label",
					placeholder = "Pick one",
					width = UDim.new(0, 150),
					items = narrowItems,
				},
			}),
			NarrowWide = Section(scope, "Narrow dropdown - wide items (truncate)", 2, "auto-xy", {
				Dropdown = DemoDropdown {
					scope = scope,
					label = "Label",
					placeholder = "Pick one",
					width = UDim.new(0, 150),
				},
			}),
			Fill = Section(scope, "Fill width - narrow items", 3, "size-full-0 auto-y", {
				Dropdown = DemoDropdown {
					scope = scope,
					label = "Label",
					placeholder = "Pick one",
					width = UDim.new(1, 0),
					items = narrowItems,
				},
			}),
		},
	}
end

local function ItemGroupsStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	local groupedItems: DropdownItems = {
		{
			title = "First title",
			items = {
				{ id = "a1", icon = BuilderIcons.Icon.Robux, text = "Alpha 1" },
				{ id = "a2", text = "Alpha 2" },
			},
		},
		{
			items = {
				{ id = "b1", text = "Beta 1" },
				{ id = "b2", isDisabled = true, text = "Beta 2 (disabled)" },
			},
		},
		{
			items = {
				{ id = "c1", text = "Untitled group item" },
			},
		},
	}
	return DemoDropdown {
		scope = scope,
		label = "With item groups",
		placeholder = "Select an option",
		width = SHOWCASE_WIDTH,
		items = groupedItems,
		layoutOrder = props.layoutOrder,
	}
end

local function OverflowStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	local items: DropdownItems = {}
	for i = 1, 100 do
		local itemId = tostring(i)
		table.insert(items, {
			id = itemId,
			icon = BuilderIcons.Icon.Robux,
			text = `Item {itemId}`,
			isDisabled = i % 7 == 0,
		})
	end

	return DemoDropdown {
		scope = scope,
		label = "Overflow",
		placeholder = "Choose a value",
		width = SHOWCASE_WIDTH,
		maxHeight = 500,
		items = items,
		layoutOrder = props.layoutOrder,
	}
end

local function LeadingAccessoriesStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	local iconItems: DropdownItems = {
		{ id = "edit", text = "Edit", leading = { iconName = BuilderIcons.Icon.Pencil } :: any },
		{ id = "share", text = "Share", leading = { iconName = BuilderIcons.Icon.PaperAirplane } :: any },
		{ id = "copy", text = "Duplicate", leading = { iconName = BuilderIcons.Icon.TwoStackedSquares } :: any },
		{ id = "delete", text = "Delete", leading = { iconName = BuilderIcons.Icon.TrashCan } :: any },
	}
	local avatarItems: DropdownItems = {
		{ id = "u1", text = "Builderman", leading = { type = "Avatar", userId = 156 } :: any },
		{ id = "u2", text = "User", leading = { type = "Avatar", userId = 24813339 } :: any },
		{ id = "u3", text = "Roblox", leading = { type = "Avatar", userId = 1 } :: any },
	}
	local mixedItems: DropdownItems = {
		{ id = "i1", text = "Settings", leading = { iconName = BuilderIcons.Icon.Pencil } :: any },
		{ id = "i2", text = "Profile", leading = { type = "Avatar", userId = 24813339 } :: any },
		{ id = "i3", text = "No leading" },
		{ id = "i4", text = "Trash", leading = { iconName = BuilderIcons.Icon.TrashCan } :: any },
	}

	return View {
		scope = scope,
		tag = "col gap-xlarge size-full-0 auto-y",
		LayoutOrder = props.layoutOrder,
		children = {
			Icons = Section(scope, "Icon leading", 1, "auto-xy", {
				Dropdown = DemoDropdown {
					scope = scope,
					label = "Action",
					placeholder = "Pick an action",
					width = SHOWCASE_WIDTH,
					items = iconItems,
				},
			}),
			Avatars = Section(scope, "Avatar leading", 2, "auto-xy", {
				Dropdown = DemoDropdown {
					scope = scope,
					label = "Member",
					placeholder = "Pick a member",
					width = SHOWCASE_WIDTH,
					items = avatarItems,
				},
			}),
			Mixed = Section(scope, "Mixed leading (some items have none)", 3, "auto-xy", {
				Dropdown = DemoDropdown {
					scope = scope,
					label = "Sample",
					placeholder = "Pick one",
					width = SHOWCASE_WIDTH,
					items = mixedItems,
				},
			}),
		},
	}
end

local function TrailingAccessoriesStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	local hintItems: DropdownItems = {
		{ id = "b", text = "Bold", trailing = { type = "Hint", text = "\u{2318}B" } :: any },
		{ id = "i", text = "Italic", trailing = { type = "Hint", text = "\u{2318}I" } :: any },
		{ id = "u", text = "Underline", trailing = { type = "Hint", text = "\u{2318}U" } :: any },
	}
	local badgeItems: DropdownItems = {
		{ id = "new", text = "New feature", trailing = { type = "Badge", text = "New", variant = BadgeVariant.Success } :: any },
		{ id = "beta", text = "Beta channel", trailing = { type = "Badge", text = "Beta", variant = BadgeVariant.Warning } :: any },
		{ id = "pro", text = "Pro mode", trailing = { type = "Badge", text = "Pro", variant = BadgeVariant.Contrast } :: any },
	}
	local mixedItems: DropdownItems = {
		{ id = "save", text = "Save", trailing = { type = "Hint", text = "\u{2318}S" } :: any },
		{ id = "publish", text = "Publish", trailing = { type = "Badge", text = "New", variant = BadgeVariant.Success } :: any },
		{ id = "plain", text = "Plain item" },
	}

	return View {
		scope = scope,
		tag = "col gap-xlarge size-full-0 auto-y",
		LayoutOrder = props.layoutOrder,
		children = {
			Hints = Section(scope, "Hint trailing", 1, "auto-xy", {
				Dropdown = DemoDropdown {
					scope = scope,
					label = "Format",
					placeholder = "Pick a style",
					width = SHOWCASE_WIDTH,
					items = hintItems,
				},
			}),
			Badges = Section(scope, "Badge trailing", 2, "auto-xy", {
				Dropdown = DemoDropdown {
					scope = scope,
					label = "Channel",
					placeholder = "Pick a channel",
					width = SHOWCASE_WIDTH,
					items = badgeItems,
				},
			}),
			Mixed = Section(scope, "Mixed trailing", 3, "auto-xy", {
				Dropdown = DemoDropdown {
					scope = scope,
					label = "Action",
					placeholder = "Pick an action",
					width = SHOWCASE_WIDTH,
					items = mixedItems,
				},
			}),
		},
	}
end

-- The selected item gets a checkmark, and every other row reserves the check
-- column slot so titles stay aligned. The two dropdowns below differ only in
-- whether a value is pre-selected, to show the column shifts as a unit.
local function CheckColumnStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	local items: DropdownItems = {
		{ id = "low", text = "Low quality", leading = { iconName = BuilderIcons.Icon.Pencil } :: any },
		{ id = "med", text = "Medium quality", leading = { iconName = BuilderIcons.Icon.PaperAirplane } :: any },
		{ id = "high", text = "High quality", leading = { iconName = BuilderIcons.Icon.ClipboardPencil } :: any },
	}

	return View {
		scope = scope,
		tag = "col gap-xlarge size-full-0 auto-y",
		LayoutOrder = props.layoutOrder,
		children = {
			Selected = Section(scope, "Pre-selected (check + leading both visible)", 1, "auto-xy", {
				Dropdown = Dropdown {
					scope = scope,
					value = "med",
					onItemChanged = function() end,
					items = items,
					label = "Quality",
					width = SHOWCASE_WIDTH,
				},
			}),
			Empty = Section(scope, "Unselected (no check column reserved)", 2, "auto-xy", {
				Dropdown = Dropdown {
					scope = scope,
					onItemChanged = function() end,
					items = items,
					label = "Quality",
					placeholder = "Pick a quality",
					width = SHOWCASE_WIDTH,
				},
			}),
		},
	}
end

return {
	fusion = Fusion,
	summary = "Dropdown",
	controls = {
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(InputSize)[1],
			List = Dash.values(InputSize),
			DefIndex = 1,
		},
		variant = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(InputVariant)[1],
			List = Dash.values(InputVariant),
			DefIndex = 1,
		},
		isDisabled = false,
		hasError = false,
		hasPlaceholder = false,
		hasHint = false,
		label = "Dropdown Label",
		placeholder = "Choose an option",
		hint = "Optional hint text",
		width = 400,
		leading = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = LEADING_CHOICES[1],
			List = LEADING_CHOICES,
			DefIndex = 1,
		},
		trailing = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = TRAILING_CHOICES[1],
			List = TRAILING_CHOICES,
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
				tag = "auto-x size-full padding-x-large padding-top-large col",
				scroll = {
					AutomaticCanvasSize = Enum.AutomaticSize.XY
				},
				children = {
					StorySection {
						scope = innerScope,
						title = "Playground",
						layoutOrder = 1,
						children = {
							PlaygroundStory {
								scope = innerScope,
								controls = controls,
								layoutOrder = 2,
							},
						},
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
						title = "States",
						layoutOrder = 4,
						children = { StatesStory { scope = innerScope, layoutOrder = 2 } },
					},

					StorySection {
						scope = innerScope,
						title = "Widths",
						layoutOrder = 5,
						children = { WidthsStory { scope = innerScope, layoutOrder = 2 } },
					},

					StorySection {
						scope = innerScope,
						title = "Item groups",
						layoutOrder = 6,
						children = { ItemGroupsStory { scope = innerScope, layoutOrder = 2 } },
					},

					StorySection {
						scope = innerScope,
						title = "Overflow",
						layoutOrder = 7,
						children = { OverflowStory { scope = innerScope, layoutOrder = 2 } },
					},

					StorySection {
						scope = innerScope,
						title = "Leading accessories",
						layoutOrder = 8,
						children = { LeadingAccessoriesStory { scope = innerScope, layoutOrder = 2 } },
					},

					StorySection {
						scope = innerScope,
						title = "Trailing accessories",
						layoutOrder = 9,
						children = { TrailingAccessoriesStory { scope = innerScope, layoutOrder = 2 } },
					},

					StorySection {
						scope = innerScope,
						title = "Check column",
						layoutOrder = 10,
						children = { CheckColumnStory { scope = innerScope, layoutOrder = 2 } },
					}
				}
			}
		end)
	end)
}