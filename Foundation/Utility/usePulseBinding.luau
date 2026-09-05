local Foundation = script.Parent.Parent
local Utility = Foundation.Utility

local unwrap = require(Utility.unwrap)
local useClock = require(Utility.useClock)
local Types = require(Utility.Types)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

local DEFAULT_RANGE = NumberRange.new(0, 1)

return function(scope: Scope, cycleTime: number?, pulseRange: NumberRange?): UsedAs<number>
	local clock = useClock(scope)
	local period = cycleTime or 1
	local range = pulseRange or DEFAULT_RANGE

	return scope:Computed(function(use: Use)
		local value = unwrap(clock, use)
		return math.map(math.sin(value * math.pi / period) ^ 2, 0, 1, range.Min, range.Max)
	end)
end
