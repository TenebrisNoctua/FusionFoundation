local Foundation = script.Parent.Parent
local Providers = script.Parent

--local CursorProvider = require(Providers.CursorProvider)
local OverlayProvider = require(Providers.OverlayProvider)
local PanelsProvider = require(Providers.PanelsProvider)
local PluginProvider = require(Providers.PluginProvider)
--local PreferencesProvider = require(Providers.PreferencesProvider)
--local ResponsiveProvider = require(Providers.ResponsiveProvider)
local ThemeProvider = require(Providers.ThemeProvider)
local WidgetsProvider = require(Providers.WidgetsProvider)
local ElevationProvider = require(Providers.ElevationProvider)

local isPluginElevated = require(Providers.PluginProvider.isPluginElevated)
local Types = require(Foundation.Utility.Types)

local FoundationOverlayDisplayOrder = true
local FoundationFixUserLevelPlugins = true
local FoundationPopoverPluginSupport = true

type OverlayConfig = Types.OverlayConfig
type ThemeProviderProps = ThemeProvider.ThemeProviderProps
--type Preferences = PreferencesProvider.PreferencesProps
--type ResponsiveConfig = ResponsiveProvider.ResponsiveConfig

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope

export type FoundationProviderProps = {
	-- All providers will be initialized from the same main scope
	scope: Scope,
	-- Plugins must provide overlay since they can't use the default PlayerGui
	overlayGui: (OverlayConfig | GuiBase2d)?,
	--preferences: Preferences?,
	--responsiveConfig: ResponsiveConfig?,
	uriScope: string?,
	plugin: Plugin?,
} & ThemeProviderProps

local function FoundationProvider(props: FoundationProviderProps)
	--local preferences = if props.preferences then props.preferences else {}
	--local responsiveConfig = if props.responsiveConfig then props.responsiveConfig else {} :: ResponsiveConfig
	local scope = props.scope
	
	-- Initialize providers from props
	local themeProvider, themeProviderCleanup = ThemeProvider({
		scope = scope,
		theme = props.theme,
		device = props.device,
		derives = props.derives,
		scale = props.scale, -- TODO: Change to preferences.scale when PreferencesProvider is implemented.
		tags = props.tags
	})
	
	local pluginProvider = PluginProvider(props.plugin)
	local elevationProvider, elevationProviderCleanup = ElevationProvider()
	
	local overlayProvider , overlayProviderCleanup = OverlayProvider(
		if FoundationOverlayDisplayOrder and typeof(props.overlayGui) == "table" 
			then { scope = scope, DisplayOrder = props.overlayGui.DisplayOrder }
			else { scope = scope, gui = props.overlayGui }
	)
	
	local widgetsProvider, widgetsProviderCleanup
	local panelsProvider, panelsProviderCleanup
	
	if FoundationFixUserLevelPlugins then
		if props.plugin and isPluginElevated(props.plugin) and FoundationPopoverPluginSupport then
			widgetsProvider, widgetsProviderCleanup = WidgetsProvider()
			panelsProvider, panelsProviderCleanup = PanelsProvider({ uriScope = props.uriScope })
		end
	elseif props.plugin and FoundationPopoverPluginSupport then
		widgetsProvider, widgetsProviderCleanup = WidgetsProvider()
		panelsProvider, panelsProviderCleanup = PanelsProvider({ uriScope = props.uriScope })
	end
	
	table.insert(scope, themeProviderCleanup)
	table.insert(scope, elevationProviderCleanup)
	table.insert(scope, overlayProviderCleanup)
	table.insert(scope, widgetsProviderCleanup)
	table.insert(scope, panelsProviderCleanup)
	
	return {
		themeProvider = themeProvider,
		pluginProvider = pluginProvider,
		elevationProvider = elevationProvider,
		overlayProvider = overlayProvider,
		widgetsProvider = widgetsProvider,
		panelsProvider = panelsProvider
	}
end

return FoundationProvider
