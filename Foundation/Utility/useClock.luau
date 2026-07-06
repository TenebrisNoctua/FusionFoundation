--!nonstrict

local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Types = require(Foundation.Utility.Types)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope

return function(scope: Scope): UsedAs<number>
	local clockValue = scope:Value(0)

	local thread = task.spawn(function()
		while true do
			local delta = task.wait()
			clockValue:set(Fusion.peek(clockValue) + delta)
		end
	end)
	
	table.insert(scope, function() 
		task.cancel(thread)
	end)

	return clockValue
end
