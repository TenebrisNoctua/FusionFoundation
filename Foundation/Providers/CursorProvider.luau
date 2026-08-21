-- Written by @TenebrisNoctua
-- Provides cursor management for Foundation components.

local Foundation = script.Parent.Parent

local Utility = Foundation.Utility
local Types = require(Utility.Types)

local CursorType = require(Foundation.Enums.CursorType)

type CursorType = CursorType.CursorType
type Scope = Types.Scope

local cursorProvider = {
	refCache = {},
	mountedCursors = {} :: { [string | CursorType]: boolean }
}

type cursorProvider = typeof(cursorProvider)

--// Main Functions

function cursorProvider.getCursor(self: cursorProvider, cursor: any?): any
	-- This can be converted back to Logger Utility if Lumberyak is added as a package.
	warn("No Cursor Provider found")
	return nil
end

function cursorProvider.setMountedCursors(self: cursorProvider, newSet: { [string | CursorType]: boolean }): { [string | CursorType]: boolean }
	self.mountedCursors = newSet
	return newSet
end

return function(scope: Scope?): (cursorProvider, () -> ()?)
	if cursorProvider.initialized then return cursorProvider end
	cursorProvider.initialized = true

	return cursorProvider, function()
		cursorProvider.initialized = false
		cursorProvider.refCache = {}
		cursorProvider.mountedCursors = {}
	end
end