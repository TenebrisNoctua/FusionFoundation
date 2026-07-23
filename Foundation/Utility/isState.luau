local Types = require(script.Parent.Types)

type StateOrAny = Types.State<any> | any
type Scope = Types.Scope

return function(state: StateOrAny): boolean
	local typeOfObject = typeof(state)
	if typeOfObject ~= "table" then return false end
	if not state.type or state.type ~= "State" then return false end
	return true
end
