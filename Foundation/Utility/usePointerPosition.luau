--!nonstrict

local Foundation = script.Parent.Parent
local Utility = Foundation.Utility

local unwrap = require(Utility.unwrap)
local Wrappers = require(Utility.Wrappers)
local Types = require(Utility.Types)

local Signal = Wrappers.Signal
local Connection = Wrappers.Connection

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

return function(scope: Scope, guiObject: UsedAs<GuiObject?>): UsedAs<Vector2>
	return scope:Computed(function(use: Use, innerScope: Scope) 
		local guiObject = unwrap(guiObject, use)
		if not guiObject then return end
		
		local position = innerScope:Value(Vector2.zero)
		
		local function setPositionFromInput(input: InputObject)
			if input.Position.X > 0 or input.Position.Y > 0 then
				position:set(Vector2.new(input.Position.X, input.Position.Y))
			end
		end
		
		local connections: { RBXScriptConnection } = {
			Signal.Connect(guiObject.InputBegan, setPositionFromInput),
			Signal.Connect(guiObject.InputChanged, setPositionFromInput),
			Signal.Connect(guiObject.InputEnded, setPositionFromInput),
		}
		
		table.insert(innerScope, function() 
			for _, connection in connections do
				Connection.Disconnect(connection)
			end
		end)
		
		return position
	end)
end