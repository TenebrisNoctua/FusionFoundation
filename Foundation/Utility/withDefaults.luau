local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Dash = PackageManager.getPackage("Dash")

local isState = require(script.Parent.isState)

local function deepJoin(a: any, b: any)
	local result = table.clone(a)
	for key, value in b do
		if not isState(value) and not isState(result[key]) and typeof(result[key]) == "table" then
			result[key] = deepJoin(result[key], value)
		else
			result[key] = value
		end
	end
	return result
end

local function withDefaults<P, D>(props: P, defaults: D): P & D
	local propsDefaultsOnly = {}

	if type(props) == "table" and type(defaults) == "table" then
		for k, _ in defaults do
			propsDefaultsOnly[k] = props[k]
		end
	end

	local deepJoinDefaults: D = deepJoin(defaults, propsDefaultsOnly)

	return ((Dash.union(props :: any, deepJoinDefaults :: any)) :: unknown) :: P & D
end

return withDefaults