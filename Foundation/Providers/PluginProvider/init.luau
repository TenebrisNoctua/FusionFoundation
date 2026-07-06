-- Written by @TenebrisNoctua
-- Provides the currently registered plugin if it exists.

local isPluginElevated = require(script.isPluginElevated)

local pluginProvider = {
	plugin = nil :: Plugin
}

type pluginProvider = typeof(pluginProvider)

--// Main Functions

function pluginProvider.isPluginElevated(self: pluginProvider): boolean
	if not self.plugin then return false end
	return isPluginElevated(self.plugin)
end

return function(plugin: Plugin?): pluginProvider
	if pluginProvider.plugin then return pluginProvider end
	pluginProvider.plugin = plugin
	return pluginProvider
end