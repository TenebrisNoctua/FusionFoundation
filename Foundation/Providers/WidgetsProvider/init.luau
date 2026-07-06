-- Written by @TenebrisNoctua
-- Provides widget registration for plugins via the Studio Widgets API.

local Foundation = script.Parent.Parent

local WidgetManager = require(script.WidgetManager)
local Types = require(script.Types)

local StudioUri = require(Foundation.Utility.Plugin.StudioUri)

local PluginProvider = require(Foundation.Providers.PluginProvider)

local widgetsProvider = {
	widgetManager = nil :: WidgetManager.WidgetManager,
}

type StudioUri = StudioUri.StudioUri
type WidgetsContext = Types.WidgetsContext
type widgetsProvider = typeof(widgetsProvider)

type WidgetsProviderProps = {
	uriScope: string?,
}

--// Main Functions

function widgetsProvider.register(self: widgetsProvider, uri: StudioUri, gui: GuiBase2d)
	assert(self.widgetManager, "WidgetsProvider has not been initialized!")
	self.widgetManager:register(uri, gui)
end

function widgetsProvider.deregister(self: widgetsProvider, uri: StudioUri, gui: GuiBase2d?)
	assert(self.widgetManager, "WidgetsProvider has not been initialized!")
	self.widgetManager:deregister(uri, gui)
end

function widgetsProvider.nextId(self: widgetsProvider): string
	assert(self.widgetManager, "WidgetsProvider has not been initialized!")
	return self.widgetManager:nextId()
end

return function(props: WidgetsProviderProps?): (widgetsProvider, () -> ()?)
	if widgetsProvider.widgetManager then return widgetsProvider end

	local pluginProvider = PluginProvider()
	if not pluginProvider or not pluginProvider.plugin then
		error("[FusionFoundation]: WidgetsProvider must be used after initializing PluginProvider!")
	end

	local widgetsApi = pluginProvider.plugin:GetPluginComponent("Widgets")
	local newWidgetManager = WidgetManager.new(widgetsApi)
	widgetsProvider.widgetManager = newWidgetManager

	return widgetsProvider, function()
		newWidgetManager:destroy()
		widgetsProvider.widgetManager = nil
	end
end