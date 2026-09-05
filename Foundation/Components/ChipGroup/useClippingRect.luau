local Foundation = script.Parent.Parent.Parent

local Utility = Foundation.Utility

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope

return function(scope: Scope, guiObject: UsedAs<GuiObject>): UsedAs<Rect>
	local rect = scope:Value(Rect.new(Vector2.zero, Vector2.zero))

	local function setup()
		local instance = unwrap(guiObject)
		if not instance then return end

		local ancestor: GuiObject | LayerCollector | nil = nil
		local current = instance.Parent
		while current do
			if current:IsA("GuiObject") and (current :: GuiObject).ClipsDescendants then
				ancestor = current :: GuiObject
				break
			end
			current = current.Parent
		end

		if not ancestor then
			local layerCollector = instance:FindFirstAncestorWhichIsA("LayerCollector")
			if layerCollector and layerCollector:IsA("GuiBase2d") then
				ancestor = layerCollector :: any
			end
		end

		if not ancestor then
			return
		end

		local resolvedAncestor = ancestor :: GuiBase2d

		local function update()
			rect:set(Rect.new(resolvedAncestor.AbsolutePosition, resolvedAncestor.AbsolutePosition + resolvedAncestor.AbsoluteSize))
		end

		table.insert(scope, resolvedAncestor:GetPropertyChangedSignal("AbsolutePosition"):Connect(update))
		table.insert(scope, resolvedAncestor:GetPropertyChangedSignal("AbsoluteSize"):Connect(update))

		update()
	end

	-- Defer setup until after the current Computed finishes so that GUI
	-- instances are parented before we search for clipping ancestors.
	task.defer(setup)

	return rect
end
