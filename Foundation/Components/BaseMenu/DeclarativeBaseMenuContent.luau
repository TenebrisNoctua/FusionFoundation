local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Dash = PackageManager.getPackage("Dash")

local BaseMenuGroup = require(script.Parent.BaseMenuGroup)
local BaseMenuItem = require(script.Parent.BaseMenuItem)
local BaseMenuContext = require(script.Parent.BaseMenuContext)

local Utility = Foundation.Utility
local Enums = Foundation.Enums
local Types = require(Utility.Types)
local unwrap = require(Utility.unwrap)

local InputSize = require(Enums.InputSize)

local function extendContext(parent, overrides)
	local result = table.clone(parent or {})
	for key, value in overrides do
		result[key] = value
	end
	return result
end

type ItemId = Types.ItemId
type OnItemActivated = Types.OnItemActivated
type Scope = Types.Scope
type Use = Types.Use
type UsedAs<T> = Types.UsedAs<T>
type InputSize = InputSize.InputSize

export type LeadingAccessory = BaseMenuItem.LeadingAccessory
export type TrailingAccessory = BaseMenuItem.TrailingAccessory

export type BaseMenuItemGroup<Item> = {
	title: string?,
	items: { Item },
}

export type BaseMenuItem = {
	id: ItemId,
	icon: string?,
	leading: (string | LeadingAccessory)?,
	trailing: TrailingAccessory?,
	isDisabled: boolean?,
	isChecked: boolean?,
	text: string,
	onActivated: OnItemActivated?,
	items: { BaseMenuItem | BaseMenuItemGroup<BaseMenuItem> }?,
}

export type BaseMenuItems<Item = BaseMenuItem> = { Item } | { BaseMenuItemGroup<Item> }

type DeclarativeBaseMenuContentProps<Item = BaseMenuItem> = {
	scope: Scope,
	items: UsedAs<BaseMenuItems<Item>>,
}

local function DeclarativeBaseMenuContent(props: DeclarativeBaseMenuContentProps)
	local scope = props.scope
	assert(scope, "A scope has not been provided for the DeclarativeBaseMenuContent component.")

	local parentContext = BaseMenuContext:now()

	local menuHasCheckComputed = scope:Computed(function(use: Use)
		local currentItems = unwrap(props.items, use)
		if not currentItems then return false end

		local firstHasItems = Dash.get(currentItems, { 1, "items" })
		local firstHasId = Dash.get(currentItems, { 1, "id" })

		local groups
		if firstHasItems and not firstHasId then
			groups = currentItems
		else
			groups = { { items = currentItems } }
		end

		local hasCheck = false
		for _, group in groups do
			for _, item in group.items do
				if not hasCheck and unwrap(item.isChecked, use) == true then
					hasCheck = true
				end
			end
		end
		return hasCheck
	end)

	local groupHasLeadingComputed = scope:Computed(function(use: Use)
		local currentItems = unwrap(props.items, use)
		if not currentItems then return {} end

		local firstHasItems = Dash.get(currentItems, { 1, "items" })
		local firstHasId = Dash.get(currentItems, { 1, "id" })

		local groups
		if firstHasItems and not firstHasId then
			groups = currentItems
		else
			groups = { { items = currentItems } }
		end

		local result = {}
		for groupIndex, group in groups do
			local groupLeading = false
			for _, item in group.items do
				if not groupLeading and (unwrap(item.leading, use) ~= nil or unwrap(item.icon, use) ~= nil) then
					groupLeading = true
				end
			end
			result[groupIndex] = groupLeading
		end
		return result
	end)

	return scope:Computed(function(use: Use, innerScope: Scope)
		local currentItems = unwrap(props.items, use)
		if not currentItems then return end

		-- Distinguish between flat items and grouped items:
		-- BaseMenuItemGroup has `items` but no `id`; BaseMenuItem has `id`
		local firstHasItems = Dash.get(currentItems, { 1, "items" })
		local firstHasId = Dash.get(currentItems, { 1, "id" })

		local groups: { BaseMenuItemGroup<BaseMenuItem> }
		if firstHasItems and not firstHasId then
			groups = currentItems :: { BaseMenuItemGroup<BaseMenuItem> }
		else
			groups = { { items = currentItems :: { BaseMenuItem } } }
		end

		local currentDepth = parentContext.depth
		local contentContext = extendContext(parentContext, {
			depth = currentDepth,
			menuHasCheck = menuHasCheckComputed,
		})

		return Dash.map(groups, function(group, groupIndex: number)
			local groupLeadingComputed = innerScope:Computed(function(use: Use)
				local leadingTable = unwrap(groupHasLeadingComputed, use)
				return leadingTable and leadingTable[groupIndex] or false
			end)

			local groupContext = extendContext(contentContext, {
				menuHasLeading = groupLeadingComputed,
			})

			return BaseMenuContext:is(groupContext):during(function()
				return BaseMenuGroup {
					scope = innerScope,
					LayoutOrder = groupIndex,
					title = group.title,
					children = function(groupInnerScope)
						return Dash.map(group.items, function(item, index)
							local isOpenComputed
							if item.items ~= nil then
								isOpenComputed = groupInnerScope:Computed(function(use: Use)
									local hoverPath = unwrap(parentContext.hoverOpenPath, use) or {}
									local itemId = unwrap(item.id, use)
									return hoverPath[currentDepth] == itemId
								end)
							else
								isOpenComputed = false
							end

							local submenuChildren
							if item.items then
								submenuChildren = function(submenuScope)
									local nestedContext = extendContext(contentContext, {
										depth = currentDepth + 1,
										hasLeading = submenuScope:Value(false),
									})
									return BaseMenuContext:is(nestedContext):during(function()
										return { DeclarativeBaseMenuContent {
											scope = submenuScope,
											items = item.items,
										} }
									end)
								end
							end

							return BaseMenuItem {
								scope = groupInnerScope,
								LayoutOrder = index,
								icon = item.icon,
								leading = item.leading,
								trailing = item.trailing,
								isChecked = item.isChecked,
								isDisabled = item.isDisabled,
								text = item.text,
								onActivated = item.onActivated,
								id = item.id,
								isOpen = isOpenComputed,
								children = submenuChildren,
							}
						end)
					end
				}
			end)
		end)
	end)
end

return DeclarativeBaseMenuContent