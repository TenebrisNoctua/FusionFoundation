--!strict
local Foundation = script.Parent.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility

local BaseMenu = require(Components.BaseMenu)
local Types = require(Utility.Types)

type BaseMenuItem = BaseMenu.BaseMenuItem
type BaseMenuItems<Item> = BaseMenu.BaseMenuItems<Item>
type BaseMenuItemGroup<Item> = BaseMenu.BaseMenuItemGroup<Item>

local function markSelectedItem<Item>(items: BaseMenuItems<Item>, value: Types.ItemId?): (BaseMenuItems<Item>, Item?)
	if not value then return items, nil end
	
	local newItems: BaseMenuItems<Item> = {}
	local selectedItem: Item?
	for _, item in items do
		if item.id then
			local newItem = item
			if item.id == value then
				newItem = table.clone(item)
				newItem.isChecked = true
				selectedItem = newItem
			end
			table.insert(newItems, newItem)
		elseif item.items then
			local nestedItems, nestedFound = markSelectedItem(item.items, value)
			table.insert(newItems, { title = item.title, items = nestedItems })
			selectedItem = selectedItem or nestedFound
		end
	end
	return newItems, selectedItem
end

return markSelectedItem