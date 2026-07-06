local Foundation = script.Parent.Parent.Parent

local Utility = Foundation.Utility

local Content = require(script.Parent.Content)
local ContentPlugin = require(script.Parent.ContentPlugin)

local Types = require(Utility.Types)

local PluginProvider = require(Foundation.Providers.PluginProvider)

local FoundationPopoverPluginSupport = true
local FoundationFixUserLevelPlugins = true

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Child = Types.Child

type PopoverContentProps = Content.PopoverContentProps

return function(props: PopoverContentProps)
	local scope = props.scope
	assert(scope, "A scope has not been provided for the PopoverContentProxy component.")

	if not FoundationPopoverPluginSupport then return end
	local pluginProvider = PluginProvider()
	local plugin = pluginProvider.plugin
	local isPluginElevated = pluginProvider:isPluginElevated()
	
	local isPluginSupported = if FoundationFixUserLevelPlugins 
		then nil
		else (function() 
			if not plugin then return false end
			--[[
				Our plugin path requires the Panels component to be available.
				Currently, this is only available to internal plugins.
			]]
			local success, _ = pcall(function()
				return plugin:GetPluginComponent("Panels")
			end)
			return success
		end)()
	
	if FoundationFixUserLevelPlugins and FoundationPopoverPluginSupport and isPluginElevated then
		return ContentPlugin(props)
	elseif FoundationPopoverPluginSupport and isPluginSupported then
		return ContentPlugin(props)
	end

	return Content(props)
end