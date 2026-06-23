--!nonstrict

local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local TypesSource = Foundation.Utility.Types
local Types = require(TypesSource.Types)

return function(scope: Types.Scope): Types.Value<number>
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
