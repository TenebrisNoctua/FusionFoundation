local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
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

-- Distinguish between flat items and grouped items:
-- BaseMenuItemGroup has `items` but no `id`; BaseMenuItem has `id`
local function getGroups(currentItems)
	if not currentItems then return nil end
	local firstHasItems = Dash.get(currentItems, { 1, "items" })
	local firstHasId = Dash.get(currentItems, { 1, "id" })
	if firstHasItems and not firstHasId then
		return currentItems
	end
	return { { items = currentItems } }
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
	local currentDepth = parentContext.depth

	local menuHasCheckComputed = scope:Computed(function(use: Use)
		local groups = getGroups(unwrap(props.items, use))
		if not groups then return false end
		for _, group in groups do
			for _, item in group.items do
				if unwrap(item.isChecked, use) == true then
					return true
				end
			end
		end
		return false
	end)

	local groupHasLeadingComputed = scope:Computed(function(use: Use)
		local groups = getGroups(unwrap(props.items, use))
		if not groups then return {} end
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

	local contentContext = extendContext(parentContext, {
		depth = currentDepth,
		menuHasCheck = menuHasCheckComputed
	})

	-- We create caches for items and groups which contain those items.
	local itemCache: {[any]: any} = {}
	local groupCache: {[any]: any} = {}

	-- Cleanup for the cache.
	table.insert(scope, function()
		for _, cached in itemCache do
			Fusion.doCleanup(cached.itemScope)
		end
		for _, cached in groupCache do
			Fusion.doCleanup(cached.groupScope)
		end
		table.clear(itemCache)
		table.clear(groupCache)
	end)
	
	--[[
		We construct an item with the given data here, and save it to the cache.
		If it exsits in the cache, we just update the item data in the cache, and return it.
	]]
	local function buildItem(item, index: number)
		local id = item.id
		local hasSubmenu = item.items ~= nil
		local cached = itemCache[id]

		-- If a cached item exists but its submenu-ness changed, we rebuild it since it's structure has changed meaningfully.
		if cached and cached.hasSubmenu ~= hasSubmenu then
			Fusion.doCleanup(cached.itemScope)
			itemCache[id] = nil
			cached = nil
		end

		if cached then
			cached.icon:set(item.icon)
			cached.leading:set(item.leading)
			cached.trailing:set(item.trailing)
			cached.isChecked:set(item.isChecked)
			cached.isDisabled:set(item.isDisabled)
			cached.text:set(item.text)
			cached.layoutOrder:set(index)
			cached.onActivatedRef.current = item.onActivated
			return cached.instance
		end
		
		-- Construct a new scope here manually, because creating an innerScope from the given scope will cause
		-- the values here to be cleaned up eariler due to innerScopes being automatically cleaned up after their parents.
		local itemScope = Fusion:scoped()

		local iconValue = itemScope:Value(item.icon)
		local leadingValue = itemScope:Value(item.leading)
		local trailingValue = itemScope:Value(item.trailing)
		local isCheckedValue = itemScope:Value(item.isChecked)
		local isDisabledValue = itemScope:Value(item.isDisabled)
		local textValue = itemScope:Value(item.text)
		local layoutOrderValue = itemScope:Value(index)
		
		local onActivatedRef = { current = item.onActivated }

		local isOpenComputed
		if hasSubmenu then
			-- We depend on the depth-scoped derived callback here, instead of the normal
			-- hoverOpenPath callback, because the normal one re-evaluates at every depth,
			-- rather than the current depth.
			isOpenComputed = itemScope:Computed(function(use: Use)
				local currentDepthOpenId = if parentContext.hoverOpenIdAtDepth
					then unwrap(parentContext.hoverOpenIdAtDepth(currentDepth), use)
					else (unwrap(parentContext.hoverOpenPath, use) or {})[currentDepth]
				return currentDepthOpenId == id
			end)
		else
			isOpenComputed = false
		end

		local submenuChildren
		if hasSubmenu then
			submenuChildren = function(submenuScope)
				local nestedContext = extendContext(contentContext, {
					depth = currentDepth + 1,
					hasLeading = submenuScope:Value(false)
				})
				return BaseMenuContext:is(nestedContext):during(function()
					return {DeclarativeBaseMenuContent {
						scope = submenuScope,
						items = item.items
					}}
				end)
			end
		end

		local instance = BaseMenuItem {
			scope = itemScope,
			LayoutOrder = layoutOrderValue,
			icon = iconValue,
			leading = leadingValue,
			trailing = trailingValue,
			isChecked = isCheckedValue,
			isDisabled = isDisabledValue,
			text = textValue,
			onActivated = function() -- This is a wrapper on top of props.onActivated to ensure that onActivated is non-nil for the cache.
				local callback = onActivatedRef.current or parentContext.onActivated
				if not callback then return warn("[FusionFoundation]: Menu should have either onActivated on itself or on all of its children") end 
				callback(id)
			end,
			id = id,
			isOpen = isOpenComputed,
			children = submenuChildren
		}

		itemCache[id] = {
			itemScope = itemScope,
			instance = instance,
			icon = iconValue,
			leading = leadingValue,
			trailing = trailingValue,
			isChecked = isCheckedValue,
			isDisabled = isDisabledValue,
			text = textValue,
			layoutOrder = layoutOrderValue,
			onActivatedRef = onActivatedRef,
			hasSubmenu = hasSubmenu
		}

		return instance
	end
	
	--[[
		We construct a group with the given data here, and save it to the cache.
		If it exists in the cache, we just update its data, and return it.
	]]
	local function getOrCreateGroup(groupIndex: number, groupTitle: string?)
		local cached = groupCache[groupIndex]
		if cached then
			cached.titleValue:set(groupTitle)
			return cached
		end
		
		-- Same reason as the item, we want these scopes to persist.
		local groupScope = Fusion:scoped()
		local titleValue = groupScope:Value(groupTitle) -- The group title
		local itemsValue = groupScope:Value({} :: {[any]: any}) -- The items on the group, we need to set them later so this is a value.

		local groupLeadingComputed = groupScope:Computed(function(use: Use)
			local leadingTable = unwrap(groupHasLeadingComputed, use)
			return leadingTable and leadingTable[groupIndex] or false
		end)

		local groupContext = extendContext(contentContext, {
			menuHasLeading = groupLeadingComputed
		})

		local instance = BaseMenuContext:is(groupContext):during(function()
			return BaseMenuGroup {
				scope = groupScope,
				LayoutOrder = groupIndex,
				title = titleValue,
				children = itemsValue
			}
		end)

		local entry = {
			groupScope = groupScope,
			instance = instance,
			titleValue = titleValue,
			itemsValue = itemsValue,
			groupContext = groupContext
		}
		
		groupCache[groupIndex] = entry -- Save the group entry to the cache.
		return entry
	end

	return scope:Computed(function(use: Use, innerScope: Scope)
		local currentItems = unwrap(props.items, use)
		if not currentItems then return end

		local groups = getGroups(currentItems)

		local result = {} -- The resulting component
		local seenIds = {} -- The seen items
		local seenGroupIndices = {} -- The seen groups
		
		--[[
			If we see a group or an item, we save it to the seen groups/items cache.
			This is done so we don't have to re-build the ones that already exist 
			and only delete the ones that no longer exist.
		]]
		
		for groupIndex, group in groups do
			seenGroupIndices[groupIndex] = true
			local groupEntry = getOrCreateGroup(groupIndex, group.title)
			local itemsDict = {}
			
			BaseMenuContext:is(groupEntry.groupContext):during(function()
				for index, item in group.items do
					seenIds[item.id] = true
					itemsDict[item.id] = buildItem(item, index)
				end
			end)
			
			groupEntry.itemsValue:set(itemsDict)
			result[groupIndex] = groupEntry.instance
		end

		-- Clear cached groups no longer present.
		for groupIndex, cached in groupCache do
			if seenGroupIndices[groupIndex] then continue end
			Fusion.doCleanup(cached.groupScope)
			table.clear(cached)
			groupCache[groupIndex] = nil
		end

		-- Clear cached items no longer present in any group.
		for id, cached in itemCache do
			if seenIds[id] then continue end
			Fusion.doCleanup(cached.itemScope)
			table.clear(cached)
			itemCache[id] = nil
		end

		return result
	end)
end

return DeclarativeBaseMenuContent