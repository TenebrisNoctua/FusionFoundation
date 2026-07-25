local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")
local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Utility = Foundation.Utility
local Enums = Foundation.Enums
local Components = Foundation.Components

local unwrap = require(Utility.unwrap)
local getRbxThumb = require(Utility.getRbxThumb)
local Types = require(Utility.Types)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local StorySection = require(Utility.Stories.StorySection)

local InputSize = require(Enums.InputSize)
local ThumbnailType = require(Enums.ThumbnailType)

local BaseMenu = require(Components.BaseMenu)
local View = require(Components.View)
local ScrollView = require(Components.ScrollView)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

type Scope = Types.Scope

type ItemId = Types.ItemId
type InputSize = InputSize.InputSize
type BaseMenuItem = BaseMenu.BaseMenuItem
type BaseMenuItemGroup = BaseMenu.BaseMenuItemGroup
type BaseMenuItems = BaseMenu.BaseMenuItems

local exampleIcons = {}
for uibloxIcon, _ in pairs(BuilderIcons.Migration["uiblox"]) do
	table.insert(exampleIcons, uibloxIcon)
end

local function useMultiselect(scope: Scope, items: {BaseMenuItem})
	local state = scope:Value(items)
	local function onActivated(id: ItemId)
		local newState = table.clone(unwrap(state))
		for _, value in newState do
			if value.id ~= id then continue end
			value.isChecked = not value.isChecked
		end
		state:set(newState)
	end
	return state, onActivated
end

local BASE_ITEMS: { BaseMenuItem } = {
	{
		id = "1",
		icon = "icons/common/robux",
		text = "Item",
	},
	{
		id = "2",
		icon = "icons/menu/gem_medium",
		isChecked = true,
		text = "Item",
	},
	{
		id = "3",
		isDisabled = true,
		text = "Item",
	},
}

local EXPERIENCE_DATA: { { name: string, universeId: number } } = {
	{ name = "[💘] RIVALS", universeId = 6035872082 },
	{ name = "[❤️ Event] Blox Fruits", universeId = 994732206 },
	{ name = "Bee Swarm Simulator", universeId = 601130232 },
	{ name = "Murder Mystery 2", universeId = 66654135 },
	{ name = "[❤️‍🔥] Adopt Me!", universeId = 383310974 },
}

local function StoryBasic(props)
	local scope = props.scope
	local controls = props.controls
	
	local selectedItem = scope:Value("1" :: ItemId)
	local icon = scope:Computed(function(use) 
		return if unwrap(controls.hasIcon, use) then unwrap(controls.icon, use) else ""
	end)
	
	return BaseMenu.Root {
		scope = scope,
		size = controls.size,
		onActivated = function(id)
			selectedItem:set(id)
		end,
		items = {
			{
				id = "1",
				icon = icon,
				isChecked = scope:Computed(function(use)
					return unwrap(selectedItem, use) == "1"	
				end),
				isDisabled = false,
				text = "Item 1",
			},
			{
				id = "2",
				icon = icon,
				isChecked = scope:Computed(function(use)
					return unwrap(selectedItem, use) == "2"	
				end),
				isDisabled = false,
				text = "Item 2,000,000,000,000,000,000,000,000",
			},
			{
				id = "3",
				icon = icon,
				isChecked = scope:Computed(function(use)
					return unwrap(selectedItem, use) == "3"	
				end),
				isDisabled = true,
				text = "Item 3",
			},
		},
		LayoutOrder = props.layoutOrder
	}
end

local function StoryMultiSelect(props)
	local scope = props.scope
	local controls = props.controls
	
	local items, onActivated = useMultiselect(scope, {
		{
			id = "1",
			icon = "icons/common/robux",
			text = "Item 1",
		},
		{
			id = "2",
			icon = "icons/common/robux",
			text = "Item 2",
		},
		{
			id = "3",
			icon = "icons/common/robux",
			text = "Item 3",
		},
	})

	return BaseMenu.Root {
		scope = scope,
		size = controls.size,
		onActivated = onActivated,
		items = items,
		LayoutOrder = props.layoutOrder
	}
end

local function StoryActionsMenu(props)
	local scope = props.scope
	local controls = props.controls

	return BaseMenu.Root {
		scope = scope,
		size = controls.size,
		onActivated = function(itemId: ItemId)
			print("Clicked item: " .. tostring(itemId))
		end,
		items = {
			{
				id = "1",
				icon = "icons/common/robux",
				text = "Item 1",
			},
			{
				id = "2",
				icon = "icons/common/robux",
				text = "Item 2",
			},
			{
				id = "3",
				icon = "icons/common/robux",
				text = "Item 3",
			},
		},
		LayoutOrder = props.layoutOrder
	}
end

local function StoryAllSizes(props)
	local scope = props.scope
	local controls = props.controls

	return View {
		scope = scope,
		LayoutOrder = props.layoutOrder,
		tag = "row wrap gap-xxlarge size-full-0 auto-y",
		children = scope:Computed(function(use, innerScope)
			return Dash.map(unwrap(InputSize, use), function(size)
				return BaseMenu.Root {
					scope = innerScope,
					size = size,
					items = BASE_ITEMS,
					onActivated = Dash.noop(),
				}
			end)
		end)
	}
end

local function StoryFixedWidth(props)
	local scope = props.scope
	local controls = props.controls
	
	return BaseMenu.Root {
		scope = scope,
		width = UDim.new(0, 300), 
		items = BASE_ITEMS, 
		onActivated = Dash.noop(),
		LayoutOrder = props.layoutOrder
	}
end

local function StoryFullWidth(props)
	local scope = props.scope
	local controls = props.controls

	return BaseMenu.Root {
		scope = scope,
		width = UDim.new(1, 0), 
		items = BASE_ITEMS, 
		onActivated = Dash.noop(),
		LayoutOrder = props.layoutOrder
	}
end

local function StoryGrouped(props)
	local scope = props.scope
	local controls = props.controls

	return BaseMenu.Root {
		scope = scope,
		items = {
			{
				title = "First Title",
				items = {
					{ id = "a1", icon = "icons/common/robux", text = "Alpha 1" } :: BaseMenuItem,
					{ id = "a2", text = "Alpha 2" },
				},
			} :: BaseMenuItemGroup,
			{
				title = "Second Title",
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
		},
		onActivated = Dash.noop(),
		LayoutOrder = props.layoutOrder
	}
end

local function StoryComposites(props)
	local scope = props.scope
	local controls = props.controls
	
	local onActivated = function(id)
		print(`Clicked {id}`)
	end
	
	local hasLeading = true

	return BaseMenu.Root {
		scope = scope,
		size = props.controls.size,
		LayoutOrder = props.layoutOrder,
		children = {
			BaseMenu.Group {
				scope = scope,
				LayoutOrder = 1, 
				title = "Test title",
				children = {
					BaseMenu.Item {
						scope = scope,
						LayoutOrder = 1, 
						id = "a1", 
						text = "Text 1",
						icon = "icons/common/robux",
						size = props.controls.size,
						onActivated = onActivated,
						hasLeading = hasLeading
					},
					BaseMenu.Item {
						scope = scope,
						LayoutOrder = 2, 
						id = "a2", 
						text = "Text 2",
						size = props.controls.size,
						onActivated = onActivated,
						hasLeading = hasLeading
					},
					BaseMenu.Item {
						scope = scope,
						LayoutOrder = 3, 
						id = "a3", 
						text = "Text 3",
						size = props.controls.size,
						onActivated = onActivated,
						hasLeading = hasLeading
					}
				}
			},
			BaseMenu.Group {
				scope = scope,
				LayoutOrder = 2,
				children = {
					BaseMenu.Item {
						scope = scope,
						LayoutOrder = 1, 
						id = "b1", 
						text = "Text 11",
						size = props.controls.size,
						onActivated = onActivated,
						hasLeading = hasLeading
					},
					BaseMenu.Item {
						scope = scope,
						LayoutOrder = 2, 
						id = "b2", 
						text = "Text 22",
						size = props.controls.size,
						onActivated = onActivated,
						hasLeading = hasLeading
					},
					BaseMenu.Item {
						scope = scope,
						LayoutOrder = 3, 
						id = "b3", 
						text = "Text 33",
						size = props.controls.size,
						onActivated = onActivated,
						hasLeading = hasLeading
					}
				}
			}
		}
	}
end

local function StoryOverflow(props)
	local scope = props.scope
	local controls = props.controls
	
	local items = {}
	for i = 1, 100 do
		table.insert(items, {
			id = tostring(i),
			icon = "icons/common/robux",
			text = "Item " .. tostring(i),
			isChecked = i % 3 == 0,
			isDisabled = i % 7 == 0,
		})
	end

	return BaseMenu.Root {
		scope = scope,
		size = props.controls.size,
		items = items,
		maxHeight = 500,
		onActivated = Dash.noop(),
		LayoutOrder = props.layoutOrder
	}
end

local function StoryExperienceIcons(props)
	local scope = props.scope
	local controls = props.controls
	
	local selectedItem = scope:Value(EXPERIENCE_DATA[1].name)
	
	local items = {}
	for _, experience in EXPERIENCE_DATA do
		table.insert(items, {
			id = experience.name,
			icon = getRbxThumb(ThumbnailType.GameIcon, experience.universeId),
			isChecked = scope:Computed(function(use) 
				return unwrap(selectedItem, use) == experience.name
			end),
			text = experience.name,
		})
	end

	return BaseMenu.Root {
		scope = scope,
		size = props.controls.size,
		onActivated = function(id)
			selectedItem:set(id)
		end,
		items = items,
		LayoutOrder = props.layoutOrder
	}
end

return {
	fusion = Fusion,
	controls = {
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(InputSize)[1],
			List = Dash.values(InputSize),
			DefIndex = 1
		},
		icon = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(exampleIcons)[1],
			List = Dash.values(exampleIcons),
			DefIndex = 1
		},
		hasIcon = true
	},
	story = StoryMiddleware(function(props)
		local scope = props.scope
		local controls = props.controls

		local theme = ThemeProvider()

		return ScrollView {
			scope = scope,
			backgroundStyle = {
				Transparency = 1
			},
			tag = "auto-xy padding-x-large padding-top-large",
			children = {
				scope:New "UIListLayout" {
					Padding = UDim.new(0, 16),
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				
				StorySection {
					scope = scope,
					title = "Base",
					children = {
						StoryBasic {
							scope = scope,
							controls = controls,
							layoutOrder = 2
						}
					}
				},

				StorySection {
					scope = scope,
					title = "Multi select",
					layoutOrder = 2,
					children = {
						StoryMultiSelect {
							scope = scope,
							controls = controls,
							layoutOrder = 2
						}
					}
				},
				
				StorySection {
					scope = scope,
					title = "Actions menu",
					layoutOrder = 3,
					children = {
						StoryActionsMenu {
							scope = scope,
							controls = controls,
							layoutOrder = 2
						}
					}
				},
				
				StorySection {
					scope = scope,
					title = "All Sizes",
					layoutOrder = 4,
					children = {
						StoryAllSizes {
							scope = scope,
							controls = controls,
							layoutOrder = 2
						}
					}
				},
				
				StorySection {
					scope = scope,
					title = "Fixed width",
					layoutOrder = 5,
					children = {
						StoryFixedWidth {
							scope = scope,
							controls = controls,
							layoutOrder = 2
						}
					}
				},
				
				StorySection {
					scope = scope,
					title = "Full width",
					layoutOrder = 6,
					children = {
						StoryFullWidth {
							scope = scope,
							controls = controls,
							layoutOrder = 2
						}
					}
				},
				
				StorySection {
					scope = scope,
					title = "Grouped",
					layoutOrder = 7,
					children = {
						StoryGrouped {
							scope = scope,
							controls = controls,
							layoutOrder = 2
						}
					}
				},
				
				StorySection {
					scope = scope,
					title = "Composites",
					layoutOrder = 8,
					children = {
						StoryComposites {
							scope = scope,
							controls = controls,
							layoutOrder = 2
						}
					}
				},
				
				StorySection {
					scope = scope,
					title = "Overflow",
					layoutOrder = 9,
					children = {
						StoryOverflow {
							scope = scope,
							controls = controls,
							layoutOrder = 2
						}
					}
				},
				
				StorySection {
					scope = scope,
					title = "Experience Icons",
					layoutOrder = 10,
					children = {
						StoryExperienceIcons {
							scope = scope,
							controls = controls,
							layoutOrder = 2
						}
					}
				},
				
				theme.StyleLink
			}
		}
	end)
}