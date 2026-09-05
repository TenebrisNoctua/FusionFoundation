local Foundation = script.Parent.Parent.Parent
local Utility = Foundation.Utility

local InputMode = require(script.Parent.InputMode)
local getInputMode = require(script.Parent.getInputMode)

local Types = require(Utility.Types)
local Wrappers = require(Utility.Wrappers)

local UserInputService = Wrappers.Services.UserInputService

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope

type InputMode = InputMode.InputMode

local function getLastInputMode(): InputMode?
	return getInputMode(UserInputService:GetLastInputType())
end

return function(scope: Scope): UsedAs<InputMode?>
	local lastInputMode = scope:Value(getLastInputMode())

	local connection = UserInputService.LastInputTypeChanged:Connect(function()
		lastInputMode:set(getLastInputMode())
	end)
	table.insert(scope, function()
		connection:Disconnect()
	end)

	return lastInputMode
end
