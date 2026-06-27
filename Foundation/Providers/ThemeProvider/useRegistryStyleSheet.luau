local Foundation = script.Parent.Parent.Parent
local Device = require(Foundation.Enums.Device)
local Theme = require(Foundation.Enums.Theme)
local StyleSheetRegistry = require(Foundation.StyleSheet.StyleSheetRegistry)

local Utility = Foundation.Utility
local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types.Types)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type Theme = Theme.Theme
type Device = Device.Device

local function useRegistryStyleSheet(
	scope: Scope,
	theme: UsedAs<Theme>,
	device: UsedAs<Device>,
	scale: UsedAs<number>
): (UsedAs<StyleSheet>, ({ string }) -> ())
	local requestedRegistryTags = {} :: { [string]: boolean }

	local registryStyleSheet = scope:Computed(function(use: Use)
		local currentTheme: Theme = unwrap(theme, use)
		local currentDevice: Device = unwrap(device, use)
		local currentScale: number = unwrap(scale, use)

		return StyleSheetRegistry.getStyleSheet(currentTheme, currentDevice, currentScale)
	end)

	local function addStyleTags(tags: {string})
		for _, tag in tags do
			requestedRegistryTags[tag] = true
		end

		local currentSheet = unwrap(registryStyleSheet)
		if currentSheet then
			StyleSheetRegistry.addStyleTags(currentSheet, tags)
		end
	end

	local function syncHistoricalTags()
		local currentSheet = unwrap(registryStyleSheet)
		if not currentSheet then return end

		local requestedTags = {}
		for tag in requestedRegistryTags do
			table.insert(requestedTags, tag)
		end

		if #requestedTags > 0 then
			StyleSheetRegistry.addStyleTags(currentSheet, requestedTags)
		end
	end

	syncHistoricalTags()
	scope:Observer(registryStyleSheet):onChange(syncHistoricalTags)
	
	table.insert(scope, function() 
		StyleSheetRegistry.removeRegistryFolder()
	end)

	return registryStyleSheet, addStyleTags
end

return useRegistryStyleSheet