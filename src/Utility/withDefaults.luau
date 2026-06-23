local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Dash = PackageManager.getPackage("Dash")
local unwrap = require(script.Parent.unwrap)

local function deepJoin(a: any, b: any)
	local result = table.clone(a)
	for key, value in b do
		if type(value) == "table" and unwrap(value) == value then
			result[key] = deepJoin(result[key], value)
		else
			result[key] = value
		end
	end
	return result
end

-- Internal intersect<> type function is not compatible with generics. This results in a type-error at a table operation.
-- So we use Generic | any.

local function withDefaults<P, D>(props: P | any, defaults: D | any): P & D
	local propsDefaultsOnly = {}

	if type(props) == "table" and type(defaults) == "table" then
		for k, _ in defaults do
			propsDefaultsOnly[k] = props[k]
		end
	end

	local deepJoinDefaults: D = deepJoin(defaults, propsDefaultsOnly)
	return Dash.union(props, deepJoinDefaults)
end

return withDefaults
