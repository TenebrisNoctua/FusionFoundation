--!nonstrict

local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local useClock = require(script.Parent.useClock)

local Utility = Foundation.Utility

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local NUM_DEGREES = 360

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

-- Returns a computed representing a rotation based on the current clock time
local function useRotation(speed: number?, scope: Scope): UsedAs<number>
	local clockValue = useClock(scope)
	return scope:Computed(function(use: Use) 
		local value = unwrap(clockValue, use)
		return value * NUM_DEGREES * (speed or 1)
	end)
end

return useRotation
