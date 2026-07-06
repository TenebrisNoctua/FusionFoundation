local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local BaseMenuGroup = require(script.Parent.BaseMenuGroup)
local BaseMenuItem = require(script.Parent.BaseMenuItem)

local Utility = Foundation.Utility
local Types = require(Utility.Types)
local unwrap = require(Utility.unwrap)

local FoundationBaseMenuSubmenuSupport = true

type ItemId = Types.ItemId
type OnItemActivated = Types.OnItemActivated
type Scope = Types.Scope
type Use = Types.Use
type UsedAs<T> = Types.UsedAs<T>

export type BaseMenuItemGroup<Item> = {
	title: string?,
	items: { Item },
}

export type BaseMenuItem = {
	id: ItemId,
	icon: string?,
	isDisabled: boolean?,
	isChecked: boolean?,
	text: string,
	onActivated: OnItemActivated?,
	items: { BaseMenuItem | BaseMenuItemGroup<BaseMenuItem> }?,
	ref: any?,
}

export type BaseMenuItems<Item = BaseMenuItem> = { Item } | { BaseMenuItemGroup<Item> }

type DeclarativeBaseMenuContentProps<Item = BaseMenuItem> = {
	scope: Scope,
	items: UsedAs<BaseMenuItems<Item>>,
}

local function DeclarativeBaseMenuContent(props: DeclarativeBaseMenuContentProps)
	local scope = props.scope
	assert(scope, "A scope has not been provided for the DeclarativeBaseMenuContent component.")

	return scope:Computed(function(use: Use, innerScope: Scope)
		local currentItems = unwrap(props.items, use)
		if not currentItems then
			return nil
		end

		-- Distinguish between flat items and grouped items:
		-- BaseMenuItemGroup has `items` but no `id`; BaseMenuItem has `id`
		local firstHasItems = Dash.get(currentItems, { 1, "items" })
		local firstHasId = if FoundationBaseMenuSubmenuSupport then Dash.get(currentItems, { 1, "id" }) else nil

		local groups: { BaseMenuItemGroup<BaseMenuItem> }
		if firstHasItems and not firstHasId then
			groups = currentItems :: { BaseMenuItemGroup<BaseMenuItem> }
		else
			groups = { { items = currentItems :: { BaseMenuItem } } }
		end

		return Dash.map(groups, function(group, groupIndex: number)
			return BaseMenuGroup {
				scope = innerScope,
				LayoutOrder = groupIndex,
				title = group.title,
				children = Dash.map(group.items, function(item, index)
					return BaseMenuItem {
						scope = innerScope,
						LayoutOrder = index,
						icon = item.icon,
						isChecked = item.isChecked,
						isDisabled = item.isDisabled,
						text = item.text,
						onActivated = item.onActivated,
						id = item.id,
						children = if FoundationBaseMenuSubmenuSupport and item.items
							then 
							{DeclarativeBaseMenuContent {
								scope = innerScope,
								items = item.items,
							}}
							else nil,
					}
				end),
			}
		end)
	end)
end

return DeclarativeBaseMenuContent