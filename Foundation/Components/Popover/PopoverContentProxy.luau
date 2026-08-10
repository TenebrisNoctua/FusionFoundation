local Foundation = script.Parent.Parent.Parent
local Utility = Foundation.Utility

local Content = require(script.Parent.Content)
local ContentPlugin = require(script.Parent.ContentPlugin)

local Types = require(Utility.Types)

local PluginProvider = require(Foundation.Providers.PluginProvider)
local isPluginSecurity = require(Utility.isPluginSecurity)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Child = Types.Child

type PopoverContentProps = Content.PopoverContentProps

return function(props: PopoverContentProps)
	local scope = props.scope
	assert(scope, "A scope has not been provided for the PopoverContent component.")
	
	local pluginProvider = PluginProvider()
	local isPluginElevated = pluginProvider:isPluginElevated()
	
	if isPluginSecurity() and isPluginElevated then
		return ContentPlugin(props)
	end
	
	return Content(props)
end