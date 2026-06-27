--!nonstrict

local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local useClock = require(script.Parent.useClock)

local TypesSource = Foundation.Utility.Types
local Types = require(TypesSource.Types)

local NUM_DEGREES = 360

-- Returns a computed representing a rotation based on the current clock time
local function useRotation(speed: number?, scope: Types.Scope): Types.Computed<number>
	local clockValue = useClock(scope)
	return scope:Computed(function(use: Types.Use) 
		local value = use(clockValue)
		return value * NUM_DEGREES * (speed or 1)
	end)
end

return useRotation
