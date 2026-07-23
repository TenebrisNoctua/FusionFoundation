-- Written by @TenebrisNoctua
-- Returns a gui value and unique URI for a widget.
-- The gui should be passed to the element you want to associate the URI with.
-- Unique URIs are generated with an ID scoped to the WidgetsProvider.

local Foundation = script.Parent.Parent.Parent
local Utility = Foundation.Utility

local WidgetsProvider = require(script.Parent)
local useWidgetRef = require(script.Parent.useWidgetRef)

local Types = require(Utility.Types)
local StudioUri = require(Utility.Plugin.StudioUri)

local PluginProvider = require(Foundation.Providers.PluginProvider)

type Scope = Types.Scope
type UsedAs<T> = Types.UsedAs<T>
type Value<T> = Types.Value<T>

type StudioUri = StudioUri.StudioUri

export type UseUniqueWidgetOptions = {
	id: string?,
	gui: UsedAs<GuiBase2d?>?,
}

export type UniqueWidgetResult = {
	gui: UsedAs<GuiBase2d?>,
	uri: StudioUri,
}

return function(scope: Scope, options: UseUniqueWidgetOptions?): UniqueWidgetResult
	local pluginProvider = PluginProvider()
	if not pluginProvider or not pluginProvider.plugin then
		error("[FusionFoundation]: useUniqueWidget must be used within a Plugin context")
	end

	local plugin = pluginProvider.plugin
	local widgetsProvider = WidgetsProvider()

	local pluginUri = StudioUri.wrap(plugin:GetUri())

	-- Generate or use provided ID
	local id = options and options.id
	if not id then
		id = widgetsProvider:nextId()
	end

	local uri = StudioUri.join(pluginUri, {
		Category = "Actions",
		ItemId = id
	})

	local gui = useWidgetRef(scope, uri, options and options.gui)
	return {
		gui = gui,
		uri = uri
	}
end