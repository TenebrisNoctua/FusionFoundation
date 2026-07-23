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
	
	local function handleInstanceChange()
		local instance = unwrap(gui)
		if typeof(instance) == "Instance" and uri then
			widgetsProvider:register(uri, instance)
		end
	end

	if isState(gui) then
		scope:Observer(gui):onChange(function()
			local instance = unwrap(gui)
			if typeof(instance) == "Instance" and uri then
				widgetsProvider:register(uri, instance)
			end
		end)
	end

	handleInstanceChange()
	table.insert(scope, function()
		local instance = unwrap(gui)
		if instance and uri then
			widgetsProvider:deregister(uri, instance)
		end
	end)

	return gui
end