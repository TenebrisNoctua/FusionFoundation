-- Written by @TenebrisNoctua
-- Handles the theme that will be applied to the components.

local Studio = settings().Studio

local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)
local StyleSheet = require(Foundation.StyleSheet)

local Fusion = PackageManager.getPackage("Fusion")

local Utility = Foundation.Utility
local unwrap = require(Utility.unwrap)
local withDefaults = require(Foundation.Utility.withDefaults)
local Types = require(Utility.Types.Types)

local Tokens = require(script.Tokens)
local useTagsState = require(script.useTagsState)

local Theme = require(Foundation.Enums.Theme)
local Device = require(Foundation.Enums.Device)

local getTokens = Tokens.getTokens

local FoundationUseStyleSheetRegistry = true

local useRegistryStyleSheet = if FoundationUseStyleSheetRegistry
	then require(script.useRegistryStyleSheet)
	else nil :: never

-- After join, there are no optional values
local defaultStyle = {
	theme = Theme.Dark :: Theme,
	device = Device.Desktop :: Device,
	scale = 1,
}

local themeProvider = {
	Theme = nil :: UsedAs<Theme>,
	Tokens = nil :: Tokens,
	Tags = nil :: UsedAs<{[string]: boolean}>?,
	RegistryStyleSheet = nil :: UsedAs<StyleSheet>,
	StyleLink = nil :: StyleLink,
	Scope = nil :: Scope,
	Cache = {
		Dark = {},
		Light = {}
	},
	AddTags = function(tags: {string})
		error("ThemeProvider has not been initialized!")
	end
}

type State<T> = Types.State<T>
type UsedAs<T> = Types.UsedAs<T>

type Scope = Types.Scope
type Use = Types.Use
type Fusion = Types.Fusion

type Theme = Theme.Theme
type Device = Device.Device
type Tokens = Tokens.Tokens

type ThemeProviderProps = {
	scope: Scope,
	theme: UsedAs<Theme>,
	device: UsedAs<Device>,
	scale: UsedAs<number?>,
	tags: UsedAs<{[string]: boolean}>,
	derives: UsedAs<{StyleSheet}?>?,
	setStyleSheetRef: { current: ((StyleSheet?) -> ()) | nil }?
}

type themeProvider = typeof(themeProvider)

--// Local Functions

local function createOrSetCache(self: themeProvider, theme: string, token: string, category: string, subcategory: string?, propType: "Color3" | "Transparency" | "Style", value: UsedAs<Color3>)
	local themeCache = self.Cache[theme]
	assert(themeCache, "Cannot find the cache table for the given theme!")
	
	local cwdTable
	if not themeCache[token] then
		themeCache[token] = {}
	end
	
	local categoryTable = themeCache[token][category]
	if not categoryTable then
		themeCache[token][category] = {}
		cwdTable = themeCache[token][category]
	else
		cwdTable = categoryTable
	end
	
	local subcategoryTable = cwdTable[subcategory]
	if subcategory and not subcategoryTable then
		themeCache[token][category][subcategory] = {}
		cwdTable = themeCache[token][category][subcategory]
	elseif subcategory then
		cwdTable = subcategoryTable
	end
	
	cwdTable[propType] = value
end

local function getFromCache(self: themeProvider, theme: string, token: string, category: string, subcategory: string?, propType: "Color3" | "Transparency" | "Style"): UsedAs<Color3 | number>?
	local themeCache = self.Cache[theme]
	assert(themeCache, "Cannot find the cache table for the given theme!")
	
	if not themeCache[token] then return end
	
	local categoryTable = themeCache[token][category]
	if categoryTable then
		if not subcategory then return categoryTable[propType] end
		local subcategoryTable = categoryTable[subcategory]
		if not subcategoryTable then return end
		return subcategoryTable[propType]
	end	
end

--// Main Functions

function themeProvider.GetColor(self: themeProvider, token: string, category: string, subcategory: string?): UsedAs<Color3>
	local theme: Theme = unwrap(self.Theme)
	local cachedResult = getFromCache(self, theme, token, category, subcategory, "Color3")
	if cachedResult then return cachedResult end
	
	local function evaluate(use: Use): Color3
		local colors = unwrap(self.Tokens, use).Color
		local foundColor = if not subcategory then colors[token][category].Color3 else colors[token][category][subcategory].Color3
		return foundColor
	end
	
	local computed = self.Scope:Computed(function(use: Use, innerScope: Scope) 
		return unwrap(evaluate(use))
	end)
	
	createOrSetCache(self, theme, token, category, subcategory, "Color3", computed)
	return computed
end

function themeProvider.GetTransparency(self: themeProvider, token: string, category: string, subcategory: string?): UsedAs<number>
	local theme = unwrap(self.Theme)
	local cachedResult = getFromCache(self, theme, token, category, subcategory, "Transparency")
	if cachedResult then return cachedResult end
	
	local function evaluate(use: Use): number
		local colors = unwrap(self.Tokens, use).Color
		local foundColor = if not subcategory then colors[token][category].Transparency else colors[token][category][subcategory].Transparency
		return foundColor
	end

	local computed = self.Scope:Computed(function(use: Use, innerScope: Scope) 
		return unwrap(evaluate(use))
	end)
	
	createOrSetCache(self, theme, token, category, subcategory, "Transparency", computed)
	return computed
end

function themeProvider.GetStyle(self: themeProvider, token: string, category: string, subcategory: string?): UsedAs<{Color3: Color3, Transparency: number}>
	local theme = unwrap(self.Theme)
	local cachedResult = getFromCache(self, theme, token, category, subcategory, "Style")
	if cachedResult then return cachedResult end
	
	local function evaluate(use: Use): number
		local colors = unwrap(self.Tokens, use).Color
		local foundStyle = if not subcategory then colors[token][category] else colors[token][category][subcategory]
		return foundStyle
	end
	
	local computed = self.Scope:Computed(function(use: Use, innerScope: Scope) 
		return unwrap(evaluate(use))
	end)
	
	createOrSetCache(self, theme, token, category, subcategory, "Style", computed)
	return computed
end

return function(themeProviderProps: ThemeProviderProps?): (themeProvider, () -> ()?)
	if themeProvider.Scope then return themeProvider end
	local themeScope = Fusion:scoped()
	local themeProviderProps = themeProviderProps or {}
	
	local props = withDefaults({
		theme = themeProviderProps.theme,
		device = themeProviderProps.device,
		scale = themeProviderProps.scale,
	}, defaultStyle)
	
	local tokens = themeScope:Computed(function(use: Use) 
		return getTokens(unwrap(props.theme, use), unwrap(props.device, use), unwrap(props.scale, use))
	end)
	
	if not FoundationUseStyleSheetRegistry then
		local tags, addTags = useTagsState(themeScope)
		themeProvider.Tags = tags
		themeProvider.AddTags = addTags
		
		local styleSheetInstances = StyleSheet {
			scope = themeScope,
			theme = props.theme,
			device = props.device,
			scale = props.scale,
			tags = tags,
			derives = props.derives,
			setStyleSheetRef = props.setStyleSheetRef
		}

		if styleSheetInstances.FoundationStyleSheet then
			themeProvider.RegistryStyleSheet = styleSheetInstances.FoundationStyleSheet
		end
		if styleSheetInstances.FoundationStyleLink then
			themeProvider.StyleLink = styleSheetInstances.FoundationStyleLink
		end
	end
	
	if FoundationUseStyleSheetRegistry then
		local registryStyleSheet, addStyleTags = useRegistryStyleSheet(themeScope, props.theme, props.device, props.scale)
		themeProvider.RegistryStyleSheet = registryStyleSheet
		themeProvider.AddTags = addStyleTags
		
		local styleLinkNode = themeScope:New "StyleLink" {
			StyleSheet = registryStyleSheet
		}
		
		themeProvider.StyleLink = styleLinkNode
	end
	
	themeProvider.Theme = props.theme
	themeProvider.Scope = themeScope
	themeProvider.Tokens = tokens

	return themeProvider, function()
		Fusion.doCleanup(themeScope)
		table.clear(themeProvider.Cache)
		
		local RegistryStyleSheet = unwrap(themeProvider.RegistryStyleSheet)
		local StyleLink = unwrap(themeProvider.StyleLink)
		
		if RegistryStyleSheet then
			RegistryStyleSheet:Destroy()
		end
		
		if StyleLink then
			StyleLink:Destroy()
		end
		
		themeProvider.Theme = nil
		themeProvider.Scope = nil
		themeProvider.Tags = nil
		themeProvider.RegistryStyleSheet = nil
		themeProvider.StyleLink = nil
		themeProvider.AddTags = function()
			error("ThemeProvider has not been initialized!")
		end
	end
end