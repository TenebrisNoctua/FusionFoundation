-- Allows you to create a state out of a certain given object, with the ability to force the output to be of a certain kind.

local TypesSource = script.Parent.Types

local Types = require(TypesSource.Types)
local unwrap = require(script.Parent.unwrap)

type StateOrAny = Types.State<any> | any
type Scope = Types.Scope

return function(Scope: Scope, inputValue: StateOrAny, defaultValue: StateOrAny, mustBeKind: string?): StateOrAny
	local stateKind: any = mustBeKind or "Value"
	local isInputAState: boolean = unwrap(inputValue) ~= inputValue
	local isDefaultAState: boolean = unwrap(defaultValue) ~= defaultValue
	
	if isInputAState and (mustBeKind == nil or inputValue.kind == mustBeKind) then
		return inputValue
	elseif inputValue ~= nil then
		return Scope[stateKind](Scope, unwrap(inputValue))
	end
	
	return if isDefaultAState then defaultValue else Scope[stateKind](Scope, defaultValue)
end
