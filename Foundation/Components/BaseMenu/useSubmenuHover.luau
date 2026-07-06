--[[
	Centralized hover state management for nested submenus.

	Maintains a single "open path" — an array of item IDs representing the currently
	open submenu chain. For example, {"level1", "level2", "level3"} means:
	  - Level 1's submenu is open
	  - Inside it, Level 2's submenu is open
	  - Inside that, Level 3's submenu is open

	All submenu open/close decisions are centralized here, eliminating cascading
	state updates and stale closure issues.
]]

local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Types = require(Foundation.Utility.Types)
local unwrap = require(Foundation.Utility.unwrap)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type ItemId = Types.ItemId

local function truncatePath(path: { ItemId }, toLength: number): { ItemId }
	local newPath = {}
	for i = 1, toLength do
		if path[i] then
			newPath[i] = path[i]
		end
	end
	return newPath
end

local function buildPath(prev: { ItemId }, depth: number, id: ItemId): { ItemId }
	local newPath = truncatePath(prev, depth - 1)
	newPath[depth] = id
	return newPath
end

export type SubmenuHoverState = {
	-- The full path of currently open submenu IDs, wrapped in a Fusion Value state
	openPath: UsedAs<{ ItemId }>,
	-- Open a submenu at the given depth. Truncates deeper items.
	-- When immediate is true, opens synchronously (used for click/tap).
	openAtDepth: (depth: number, id: ItemId, immediate: boolean?) -> (),
	-- Close all submenus at and below the given depth.
	closeAtDepth: (depth: number) -> (),
	-- Immediately reset all open submenus (e.g. on outside click or item activation).
	reset: () -> (),
}

local function useSubmenuHover(scope: Scope): SubmenuHoverState
	assert(scope, "A scope has not been provided for useSubmenuHover.")

	local Theme = ThemeProvider()

	local openPath = scope:Value({} :: { ItemId })
	local openTimer: thread? = nil
	local closeTimer: thread? = nil

	local function cancelTimers()
		if openTimer then
			task.cancel(openTimer)
			openTimer = nil
		end
		if closeTimer then
			task.cancel(closeTimer)
			closeTimer = nil
		end
	end

	local function openAtDepth(depth: number, id: ItemId, immediate: boolean?)
		cancelTimers()

		local currentPath = unwrap(openPath)
		if currentPath[depth] == id then
			return
		end

		if immediate then
			openPath:set(buildPath(currentPath, depth, id))
			return
		end

		local tokens = unwrap(Theme.Tokens)
		local hoverOpenDelay = tokens.Time.Time_100

		openTimer = task.delay(hoverOpenDelay, function()
			openPath:set(buildPath(unwrap(openPath), depth, id))
			openTimer = nil
		end)
	end

	local function closeAtDepth(depth: number)
		cancelTimers()

		local currentPath = unwrap(openPath)
		if #currentPath < depth then
			return
		end

		local tokens = unwrap(Theme.Tokens)
		local hoverCloseDelay = tokens.Time.Time_300

		closeTimer = task.delay(hoverCloseDelay, function()
			local prev = unwrap(openPath)
			if #prev >= depth then
				openPath:set(truncatePath(prev, depth - 1))
			end
			closeTimer = nil
		end)
	end

	local function reset()
		cancelTimers()
		openPath:set({})
	end

	-- Clean up scheduling threads safely when the component's scope decomposes
	table.insert(scope, function()
		cancelTimers()
	end)

	return {
		openPath = openPath,
		openAtDepth = openAtDepth,
		closeAtDepth = closeAtDepth,
		reset = reset,
	}
end

return useSubmenuHover