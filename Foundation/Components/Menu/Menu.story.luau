local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Menu = require(script.Parent)

local View = require(Components.View)
local Text = require(Components.Text)
local Button = require(Components.Button)
local Fragment = require(Components.Fragment)
local IconButton = require(Components.IconButton)
local ScrollView = require(Components.ScrollView)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StorySection = require(Utility.Stories.StorySection)
local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local CommonControls = require(Utility.Stories.CommonControls)

local InputSize = require(Enums.InputSize)
local PopoverAlign = require(Enums.PopoverAlign)
local PopoverSide = require(Enums.PopoverSide)

type Scope = Types.Scope
type Use = Types.Use

type InputSize = InputSize.InputSize
type PopoverSide = PopoverSide.PopoverSide
type PopoverAlign = PopoverAlign.PopoverAlign
type MenuItem = Menu.MenuItem
type MenuItems = Menu.MenuItems
type ItemId = Types.ItemId

local SAMPLE_MENU_ITEMS: { MenuItem } = {
	{ id = "new", icon = "icons/actions/edit/add", text = "New" },
	{ id = "edit", icon = "icons/actions/edit/edit", text = "Edit" },
	{ id = "copy", icon = "icons/actions/edit/copy", text = "Copy" },
	{ id = "delete", icon = "icons/actions/edit/delete", text = "Delete", isDisabled = true },
}

local SELECTION_MENU_ITEMS: { MenuItem } = {
	{ id = "r15", text = "R15 Only" },
	{ id = "r6", text = "R6 Only" },
	{ id = "choice", text = "Player Choice" },
}

local LONG_MENU_POOL: { { icon: string, text: string } } = {
	{ icon = "icons/actions/edit/add", text = "New" },
	{ icon = "icons/actions/edit/edit", text = "Open" },
	{ icon = "icons/actions/edit/edit", text = "Save" },
	{ icon = "icons/actions/edit/edit", text = "Save As..." },
	{ icon = "icons/actions/edit/edit", text = "Rename" },
	{ icon = "icons/actions/edit/copy", text = "Duplicate" },
	{ icon = "icons/actions/edit/copy", text = "Copy" },
	{ icon = "icons/actions/edit/copy", text = "Cut" },
	{ icon = "icons/actions/edit/copy", text = "Paste" },
	{ icon = "icons/actions/edit/edit", text = "Export" },
	{ icon = "icons/actions/edit/edit", text = "Import" },
	{ icon = "icons/actions/edit/delete", text = "Delete" },
}

local function makeNestedSubmenuItems(): MenuItems
	local obbyVersions: { MenuItem } = {
		{ id = "obby-v3", icon = "check-large", text = "v3.0 (Live)" },
		{ id = "obby-v2", text = "v2.5 (Draft)" },
		{ id = "obby-v1", text = "v1.0 (Archived)" },
		{ id = "obby-restore", icon = "arrow-rotate-right", text = "Restore Backup" },
	}
	local myPlaces: { MenuItems } = {
		{ id = "place-obby", icon = "globe-simplified", text = "Obby World", items = obbyVersions },
		{ id = "place-racing", icon = "globe-simplified", text = "Racing Game" },
		{ id = "place-rpg", icon = "globe-simplified", text = "RPG Quest" },
		{ id = "place-tycoon", icon = "globe-simplified", text = "Tycoon Builder" },
	}
	local openRecent: { MenuItems } = {
		{ id = "recent-places", icon = "folder", text = "My Places", items = myPlaces },
		{ id = "recent-team", icon = "folder", text = "Team Projects" },
		{ id = "recent-templates", text = "Templates" },
		{ id = "recent-clear", icon = "trash-can", text = "Clear History", isDisabled = true },
	}
	local exportItems: { MenuItems } = {
		{ id = "export-rbxl", text = "Place File (.rbxl)" },
		{ id = "export-rbxm", text = "Model File (.rbxm)" },
		{ id = "export-png", icon = "photo-camera", text = "Screenshot (.png)" },
		{ id = "export-json", icon = "code", text = "Selection as JSON" },
	}
	local fileItems: { MenuItems } = {
		{ id = "file-new", icon = "plus-small", text = "New Place" },
		{ id = "file-open-recent", icon = "clock", text = "Open Recent", items = openRecent },
		{ id = "file-save", icon = "floppy-disk", text = "Save" },
		{ id = "file-save-as", text = "Save As...", isDisabled = true },
		{ id = "file-export", icon = "arrow-large-right", text = "Export", items = exportItems },
		{ id = "file-publish", icon = "globe-simplified", text = "Publish to Roblox" },
		{ id = "file-close", icon = "x-large", text = "Close Place" },
	}
	local alignItems: { MenuItems } = {
		{ id = "align-left", icon = "arrow-large-left", text = "Align Left" },
		{ id = "align-center", text = "Align Center" },
		{ id = "align-right", icon = "arrow-large-right", text = "Align Right" },
		{ id = "align-top", icon = "arrow-large-up", text = "Align Top" },
		{ id = "align-middle", text = "Align Middle" },
		{ id = "align-bottom", icon = "arrow-large-down", text = "Align Bottom" },
	}
	local transformItems: { MenuItems } = {
		{ id = "transform-align", icon = "two-arrows-left-right", text = "Align", items = alignItems },
		{ id = "transform-rotate-cw", icon = "arrow-spin-clockwise", text = "Rotate 90\u{00B0} CW" },
		{ id = "transform-rotate-ccw", text = "Rotate 90\u{00B0} CCW" },
		{ id = "transform-flip-h", icon = "two-arrows-left-right", text = "Flip Horizontal" },
		{ id = "transform-flip-v", text = "Flip Vertical" },
		{ id = "transform-reset", text = "Reset Transform", isDisabled = true },
	}
	local editItems: { MenuItems } = {
		{ id = "edit-undo", icon = "arrow-large-left", text = "Undo" },
		{ id = "edit-redo", icon = "arrow-large-right", text = "Redo" },
		{ id = "edit-cut", text = "Cut" },
		{ id = "edit-copy", text = "Copy" },
		{ id = "edit-paste", text = "Paste" },
		{ id = "edit-duplicate", text = "Duplicate", isDisabled = true },
		{ id = "edit-transform", icon = "arrow-spin-clockwise", text = "Transform", items = transformItems },
	}
	local viewItems: { MenuItems } = {
		{ id = "view-explorer", icon = "folder", text = "Explorer" },
		{ id = "view-properties", icon = "rectangle-list", text = "Properties" },
		{ id = "view-output", text = "Output" },
		{ id = "view-cmd-bar", text = "Command Bar" },
		{ id = "view-toolbox", text = "Toolbox" },
		{ id = "view-terrain", text = "Terrain Editor" },
	}
	local insertItems: { MenuItems } = {
		{ id = "insert-script", icon = "code", text = "Script" },
		{ id = "insert-local-script", text = "Local Script" },
		{ id = "insert-module", text = "Module Script" },
		{ id = "insert-folder", icon = "folder", text = "Folder" },
	}
	return {
		{
			title = "Document",
			items = {
				{ id = "file", icon = "page", text = "File", items = fileItems },
				{ id = "edit", icon = "pencil-square", text = "Edit", items = editItems },
			},
		},
		{
			title = "Workspace",
			items = {
				{ id = "view", icon = "eye", text = "View", items = viewItems },
				{ id = "insert", icon = "plus-large", text = "Insert", items = insertItems },
			},
		},
		{
			title = "Quick Actions",
			items = {
				{ id = "select-all", icon = "check-large", text = "Select All" },
				{ id = "preferences", icon = "gear", text = "Preferences" },
			},
		},
	} :: { MenuItems }
end

local function StoryPlayground(props)
	local scope = props.scope
	local controls = props.controls

	local isOpen = scope:Value(false)
	local selectedId = scope:Value(nil :: string?)

	local items = scope:Computed(function(use)
		local selected = unwrap(selectedId, use)
		local result = {}
		for i = 1, 6 do
			local poolItem = LONG_MENU_POOL[((i - 1) % #LONG_MENU_POOL) + 1]
			table.insert(result, {
				id = `item-{i}`,
				icon = poolItem.icon,
				text = poolItem.text,
				isChecked = selected == `item-{i}`,
			})
		end
		return result
	end)

	return View {
		scope = scope,
		Size = UDim2.new(1, 0, 0, 200),
		tag = "row align-x-center align-y-center",
		LayoutOrder = props.layoutOrder,
		children = {
			Menu {
				scope = scope,
				isOpen = isOpen,
				items = items,
				size = controls.size,
				side = controls.side,
				align = controls.align,
				maxHeight = if unwrap(controls.maxHeight) > 0 then controls.maxHeight else nil,
				onPressedOutside = function()
					isOpen:set(false)
				end,
				onActivated = function(id: ItemId)
					print(`Menu: "{id}" activated`)
					selectedId:set(tostring(id))
					isOpen:set(false)
				end,
				children = Fragment {
					{Button, {
						text = "Open Playground",
						size = InputSize.Medium,
						onActivated = function()
							isOpen:set(not unwrap(isOpen))
						end
					}}
				}
			},
		}
	}
end

local function StoryAlwaysOpen(props)
	local scope = props.scope
	local controls = props.controls

	return View {
		scope = scope,
		Size = UDim2.new(1, 0, 0, 300),
		tag = "row align-x-center align-y-center",
		LayoutOrder = props.layoutOrder,
		children = {
			Menu {
				scope = scope,
				isOpen = true,
				items = SAMPLE_MENU_ITEMS,
				size = controls.size,
				side = controls.side,
				align = controls.align,
				onActivated = function(id: ItemId)
					print("Always open menu item activated:", id)
				end,
				children = Fragment {
					{Button, {
						text = "Always Open Menu",
						size = InputSize.Medium,
						onActivated = function()
							print("Button clicked but menu stays open")
						end
					}}
				}
			}
		}
	}
end

local function StoryBasicMenu(props)
	local scope = props.scope
	local controls = props.controls

	local isOpen = scope:Value(false)

	return View {
		scope = scope,
		Size = UDim2.new(1, 0, 0, 100),
		tag = "row align-x-center align-y-center",
		LayoutOrder = props.layoutOrder,
		children = {
			Menu {
				scope = scope,
				isOpen = isOpen,
				items = SAMPLE_MENU_ITEMS,
				size = controls.size,
				side = controls.side,
				align = controls.align,
				onPressedOutside = function()
					isOpen:set(false)
				end,
				onActivated = function(id: ItemId)
					print("Menu item activated:", id)
					isOpen:set(false)
				end,
				children = Fragment {
					{Button, {
						text = "Open Menu",
						size = InputSize.Medium,
						onActivated = function()
							isOpen:set(not unwrap(isOpen))
						end
					}}
				}
			}
		}
	}
end

local function StorySelectionMenu(props)
	local scope = props.scope
	local controls = props.controls

	local isOpen = scope:Value(false)
	local selectedItemId = scope:Value(SELECTION_MENU_ITEMS[1].id)

	local items = scope:Computed(function(use)
		local selected = unwrap(selectedItemId, use)
		return Dash.map(SELECTION_MENU_ITEMS, function(item)
			return {
				id = item.id,
				text = item.text,
				isChecked = selected == item.id,
			}
		end)
	end)

	return View {
		scope = scope,
		Size = UDim2.new(1, 0, 0, 300),
		tag = "row align-x-center align-y-center",
		LayoutOrder = props.layoutOrder,
		children = {
			Menu {
				scope = scope,
				isOpen = isOpen,
				items = items,
				size = controls.size,
				side = controls.side,
				align = controls.align,
				onPressedOutside = function()
					isOpen:set(false)
				end,
				onActivated = function(id: ItemId)
					selectedItemId:set(tostring(id))
				end,
				children = Fragment {
					{Button, {
						text = "Selection Menu",
						size = InputSize.Medium,
						onActivated = function()
							isOpen:set(not unwrap(isOpen))
						end
					}}
				}
			}
		}
	}
end

local function StoryDifferentAnchors(props)
	local scope = props.scope
	local controls = props.controls

	local isOpen1 = scope:Value(false)
	local isOpen2 = scope:Value(false)

	return View {
		scope = scope,
		Size = UDim2.new(1, 0, 0, 300),
		tag = "row align-x-center align-y-center gap-large",
		LayoutOrder = props.layoutOrder,
		children = {
			Menu {
				scope = scope,
				isOpen = isOpen1,
				items = SAMPLE_MENU_ITEMS,
				size = controls.size,
				side = controls.side,
				align = controls.align,
				onPressedOutside = function()
					isOpen1:set(false)
				end,
				onActivated = function(id: ItemId)
					print("IconButton menu item activated:", id)
					isOpen1:set(false)
				end,
				children = Fragment {
					{IconButton, {
						icon = "icons/common/more",
						size = InputSize.Medium,
						onActivated = function()
							isOpen1:set(not unwrap(isOpen1))
						end
					}}
				}
			},
			Menu {
				scope = scope,
				isOpen = isOpen2,
				items = SAMPLE_MENU_ITEMS,
				size = controls.size,
				side = controls.side,
				align = controls.align,
				onPressedOutside = function()
					isOpen2:set(false)
				end,
				onActivated = function(id: ItemId)
					print("Card menu item activated:", id)
					isOpen2:set(false)
				end,
				children = Fragment {
					{View, {
						tag = "col gap-medium auto-xy padding-large stroke-neutral radius-medium bg-surface-100",
						onActivated = function()
							isOpen2:set(not unwrap(isOpen2))
						end,
						children = Fragment {
							{Text, {
								Text = "Card with Menu",
								tag = "auto-xy text-heading-medium"
							}},
							{Text, {
								Text = "Click me to open menu",
								tag = "auto-xy text-body-small"
							}}
						}
					}}
				}
			}
		}
	}
end

local function StoryReferenceAnchor(props)
	local scope = props.scope
	local controls = props.controls

	local isOpen = scope:Value(false)

	local anchorButton = unwrap(Button {
		scope = scope,
		text = "Anchor outside of the menu component",
		size = InputSize.Medium,
		onActivated = function()
			isOpen:set(true)
		end,
	})

	return View {
		scope = scope,
		Size = UDim2.new(1, 0, 0, 300),
		tag = "row align-x-center align-y-center gap-large",
		LayoutOrder = props.layoutOrder,
		children = {
			anchorButton,
			Menu {
				scope = scope,
				isOpen = isOpen,
				items = SAMPLE_MENU_ITEMS,
				size = controls.size,
				side = controls.side,
				align = controls.align,
				anchorInstance = anchorButton,
				onPressedOutside = function()
					isOpen:set(false)
				end,
				onActivated = function(id: ItemId)
					print("Reference anchor menu item activated:", id)
				end
			}
		}
	}
end

local function StoryGrouped(props)
	local scope = props.scope
	local controls = props.controls

	local isOpen = scope:Value(false)
	local selectedItemId = scope:Value("a1")

	local items = scope:Computed(function(use)
		local selected = unwrap(selectedItemId, use)
		return {
			{
				title = "First title",
				items = {
					{ id = "a1", icon = "icons/common/robux", text = "Alpha 1", isChecked = selected == "a1" } :: MenuItem,
					{ id = "a2", text = "Alpha 2", isChecked = selected == "a2" },
				},
			},
			{
				items = {
					{ id = "b1", text = "Beta 1", isChecked = selected == "b1" },
					{ id = "b2", isDisabled = true, text = "Beta 2 (disabled)", isChecked = selected == "b2" },
				},
			},
			{
				items = {
					{ id = "c1", text = "Untitled group item", isChecked = selected == "c1" },
				},
			},
		}
	end)

	return View {
		scope = scope,
		Size = UDim2.new(1, 0, 0, 100),
		tag = "row align-x-center align-y-center",
		LayoutOrder = props.layoutOrder,
		children = {
			Menu {
				scope = scope,
				isOpen = isOpen,
				items = items,
				size = controls.size,
				side = controls.side,
				align = controls.align,
				onPressedOutside = function()
					isOpen:set(false)
				end,
				onActivated = function(id: ItemId)
					isOpen:set(false)
					selectedItemId:set(tostring(id))
				end,
				children = Fragment {
					{Button, {
						text = "Open Menu",
						size = InputSize.Medium,
						onActivated = function()
							isOpen:set(not unwrap(isOpen))
						end
					}}
				}
			}
		}
	}
end

local function StoryNestedSubmenus(props)
	local scope = props.scope
	local controls = props.controls

	local isOpen = scope:Value(false)
	local items = makeNestedSubmenuItems()

	return View {
		scope = scope,
		Size = UDim2.new(1, 0, 0, 600),
		tag = "row align-x-center align-y-center",
		LayoutOrder = props.layoutOrder,
		children = {
			Menu {
				scope = scope,
				isOpen = isOpen,
				items = items,
				size = controls.size,
				side = controls.side,
				align = controls.align,
				onPressedOutside = function()
					isOpen:set(false)
				end,
				onActivated = function(id: ItemId)
					print("Menu item activated by parent:", id)
					isOpen:set(false)
				end,
				children = Fragment {
					{Button, {
						text = "Open Menu",
						size = InputSize.Medium,
						onActivated = function()
							isOpen:set(not unwrap(isOpen))
						end
					}}
				}
			}
		}
	}
end

local function StoryOverflow(props)
	local scope = props.scope
	local controls = props.controls

	local isOpen = scope:Value(false)

	local items = {}
	for i = 1, 50 do
		table.insert(items, {
			id = tostring(i),
			icon = "icons/common/robux",
			text = "Item " .. tostring(i),
			isChecked = i % 3 == 0,
			isDisabled = i % 7 == 0,
		})
	end

	return View {
		scope = scope,
		Size = UDim2.new(1, 0, 0, 200),
		tag = "row align-x-center align-y-center",
		LayoutOrder = props.layoutOrder,
		children = {
			Menu {
				scope = scope,
				isOpen = isOpen,
				items = items,
				size = controls.size,
				side = controls.side,
				align = controls.align,
				maxHeight = if unwrap(controls.maxHeight) > 0 then controls.maxHeight else 240,
				onPressedOutside = function()
					isOpen:set(false)
				end,
				onActivated = function(id: ItemId)
					print("Overflow menu item activated:", id)
					isOpen:set(false)
				end,
				children = Fragment {
					{Button, {
						text = "Open Overflow Menu",
						size = InputSize.Medium,
						onActivated = function()
							isOpen:set(not unwrap(isOpen))
						end
					}}
				}
			}
		}
	}
end

return {
	fusion = Fusion,
	summary = "Menu",
	controls = {
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = InputSize.Medium,
			List = { InputSize.Medium, InputSize.Small, InputSize.XSmall },
			DefIndex = 1,
		},
		side = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = PopoverSide.Bottom,
			List = Dash.values(PopoverSide),
			DefIndex = 1,
		},
		align = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = PopoverAlign.Start,
			List = Dash.values(PopoverAlign),
			DefIndex = 1,
		},
		maxHeight = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = 0,
			List = { 0, 180, 240, 360 },
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
					title = "Playground",
					description = "Interactive menu with configurable size, side, align, and maxHeight controls.",
					layoutOrder = 1,
					children = {
						StoryPlayground {
							scope = scope,
							controls = controls,
							layoutOrder = 3,
						}
					}
				},

				StorySection {
					scope = scope,
					title = "Always Open",
					description = "Menu that stays open regardless of button clicks.",
					layoutOrder = 2,
					children = {
						StoryAlwaysOpen {
							scope = scope,
							controls = controls,
							layoutOrder = 3,
						}
					}
				},

				StorySection {
					scope = scope,
					title = "Basic Menu",
					description = "Simple open/close menu with a button anchor.",
					layoutOrder = 3,
					children = {
						StoryBasicMenu {
							scope = scope,
							controls = controls,
							layoutOrder = 3,
						}
					}
				},

				StorySection {
					scope = scope,
					title = "Selection Menu",
					description = "Radio-style menu with checked state tracking.",
					layoutOrder = 4,
					children = {
						StorySelectionMenu {
							scope = scope,
							controls = controls,
							layoutOrder = 3,
						}
					}
				},

				StorySection {
					scope = scope,
					title = "Different Anchors",
					description = "Menu anchored to an IconButton and a Card View.",
					layoutOrder = 5,
					children = {
						StoryDifferentAnchors {
							scope = scope,
							controls = controls,
							layoutOrder = 3,
						}
					}
				},

				StorySection {
					scope = scope,
					title = "Reference Anchor",
					description = "Menu using an external anchorInstance (button rendered outside the Menu component).",
					layoutOrder = 6,
					children = {
						StoryReferenceAnchor {
							scope = scope,
							controls = controls,
							layoutOrder = 3,
						}
					}
				},

				StorySection {
					scope = scope,
					title = "Grouped",
					description = "Menu with grouped items and group titles.",
					layoutOrder = 7,
					children = {
						StoryGrouped {
							scope = scope,
							controls = controls,
							layoutOrder = 3,
						}
					}
				},

				StorySection {
					scope = scope,
					title = "Nested Submenus",
					description = "Deep nested menu structure with multiple levels of submenus.",
					layoutOrder = 8,
					children = {
						StoryNestedSubmenus {
							scope = scope,
							controls = controls,
							layoutOrder = 3,
						}
					}
				},

				StorySection {
					scope = scope,
					title = "Overflow",
					description = "Menu with 50 items demonstrating maxHeight scrolling behavior.",
					layoutOrder = 9,
					children = {
						StoryOverflow {
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