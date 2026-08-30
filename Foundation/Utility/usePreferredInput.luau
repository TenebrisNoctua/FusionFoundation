local Foundation = script.Parent.Parent
local Types = require(Foundation.Utility.Types)

local UserInputService = game:GetService("UserInputService")

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope

return function(scope: Scope): UsedAs<Enum.PreferredInput>
	local preferredInput = scope:Value(UserInputService.PreferredInput)
	table.insert(scope, UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function() 
		preferredInput:set(UserInputService.PreferredInput)
	end))

	preferredInput:set(UserInputService.PreferredInput)

	return preferredInput
end