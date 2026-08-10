-- Written by @TenebrisNoctua
-- Registers a widget URI with the WidgetsProvider when an instance becomes available.

local Foundation = script.Parent.Parent.Parent
local Utility = Foundation.Utility

local WidgetsProvider = require(script.Parent)

local isState = require(Utility.isState)
local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)
local StudioUri = require(Utility.Plugin.StudioUri)

type Scope = Types.Scope
type UsedAs<T> = Types.UsedAs<T>
type Value<T> = Types.Value<T>

type StudioUri = StudioUri.StudioUri

return function(scope: Scope, uri: StudioUri, gui: UsedAs<GuiBase2d?>?): UsedAs<GuiBase2d?>
	local gui = gui or scope:Value(nil :: GuiBase2d?)
	local widgetsProvider = WidgetsProvider()

	local ancestryConnection: RBXScriptConnection? = nil

	local function cleanupAncestryListener()
		if ancestryConnection then
			ancestryConnection:Disconnect()
			ancestryConnection = nil
		end
	end

	local function tryRegister(instance: GuiBase2d?)
		if typeof(instance) ~= "Instance" or not uri then return end
		cleanupAncestryListener()

		-- Defer registration so the instance has time to be parented.
		task.defer(function()
			if typeof(instance) ~= "Instance" then return end
			if instance:FindFirstAncestorWhichIsA("LayerCollector") then
				widgetsProvider:register(uri, instance)
			else
				-- Instance not yet parented to a LayerCollector.
				-- Listen for ancestry changes and register when parented.
				ancestryConnection = instance.AncestryChanged:Connect(function(_, parent)
					if parent and instance:FindFirstAncestorWhichIsA("LayerCollector") then
						widgetsProvider:register(uri, instance)
						cleanupAncestryListener()
					end
				end)
			end
		end)
	end

	if isState(gui) then
		scope:Observer(gui):onChange(function()
			tryRegister(unwrap(gui))
		end)
	end

	tryRegister(unwrap(gui))

	table.insert(scope, function()
		cleanupAncestryListener()
		local instance = unwrap(gui)
		if instance and uri then
			widgetsProvider:deregister(uri, instance)
		end
	end)

	return gui
end