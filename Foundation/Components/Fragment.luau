--[[
	Fragment is a placeholder component that can be used to render children components in the same scope
	as the main component it's been provided to. This is necessary in certain components, due to
	children components' scope outliving the main component's scope.
]]

local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Dash = PackageManager.getPackage("Dash")

local Utility = Foundation.Utility
local Types = require(Utility.Types)

type Scope = Types.Scope
type Child = Types.Child

return function(props: {{(...any) -> (any) | {[string]: any}}}): (scope: Scope) -> Child
	return function(scope: Scope): Child
		local children = {}
		for _, data in props do
			local component: (...any) -> (any) = data[1]
			local componentProps: {[string]: any} = data[2]
			componentProps = Dash.union(componentProps, { scope = scope })
			table.insert(children, component(componentProps))
		end
		return children
	end
end