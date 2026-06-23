-- Written by @TenebrisNoctua
-- Handles the theme that will be applied to the components.

local Studio = settings().Studio

local Foundation = script.Parent.Parent

local PackageManager = require(Foundation.PackageManager)
local Fusion = PackageManager.getPackage("Fusion")
local RBXDesignFoundations = PackageManager.getPackage("RBXDesignFoundations")

local TypesSource = script.Parent.Types
local Types = require(TypesSource.Types)

local unwrap = require(script.Parent.unwrap)

local themeProvider = {
	Theme = nil :: Value<string>,
	IsDark = nil :: Value<boolean>,
	Scope = nil :: Scope,
	Cache = {
		Dark = {},
		Light = {}
	}
}

type State<T> = Types.State<T>
type Value<T> = Types.Value<T>
type UsedAs<T> = Types.UsedAs<T>

type Scope = Types.Scope
type Use = Types.Use
type Fusion = Types.Fusion

type themeProvider = typeof(themeProvider)

--// Local Functions

local function updateTheme()
	local _, _, v = Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground):ToHSV()
	themeProvider.IsDark:set(v <= 0.6)
	themeProvider.Theme:set(Studio.Theme.Name)
end

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
	local theme = if unwrap(themeProvider.IsDark) then "Dark" else "Light"
	local cachedResult = getFromCache(self, theme, token, category, subcategory, "Color3")
	if cachedResult then return cachedResult end
	
	local function evaluate(use: Use): Color3
		local theme = if unwrap(themeProvider.IsDark, use) then "Dark" else "Light"
		local colors = RBXDesignFoundations.Tokens[theme].Color
		
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
	local theme = if unwrap(themeProvider.IsDark) then "Dark" else "Light"
	local cachedResult = getFromCache(self, theme, token, category, subcategory, "Transparency")
	if cachedResult then return cachedResult end
	
	local function evaluate(use: Use): number
		local theme = if unwrap(themeProvider.IsDark, use) then "Dark" else "Light"
		local colors = RBXDesignFoundations.Tokens[theme].Color

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
	local theme = if unwrap(themeProvider.IsDark) then "Dark" else "Light"
	local cachedResult = getFromCache(self, theme, token, category, subcategory, "Style")
	if cachedResult then return cachedResult end
	
	local function evaluate(use: Use): number
		local theme = if unwrap(themeProvider.IsDark, use) then "Dark" else "Light"
		local colors = RBXDesignFoundations.Tokens[theme].Color

		local foundStyle = if not subcategory then colors[token][category] else colors[token][category][subcategory]
		return foundStyle
	end
	
	local computed = self.Scope:Computed(function(use: Use, innerScope: Scope) 
		return unwrap(evaluate(use))
	end)
	
	createOrSetCache(self, theme, token, category, subcategory, "Style", computed)
	return computed
end

function themeProvider.GetFontData(self: themeProvider, name: string): UsedAs<{Font: Enum.Font, FontSize: number, LetterSpacing: number, LineHeight: number}>
	local function evaluate(use: Use): {Font: Enum.Font, FontSize: number, LetterSpacing: number, LineHeight: number}
		local theme = if unwrap(themeProvider.IsDark, use) then "Dark" else "Light"
		local typography = RBXDesignFoundations.Tokens[theme].Typography
		
		return typography[name]
	end
	
	return self.Scope:Computed(function(use: Use, innerScope: Scope) 
		return unwrap(evaluate(use))
	end)
end

function themeProvider.GetTokenData(self: themeProvider, token: string, category: string, subcategory: string?): UsedAs<{[string]: any}>
	local function evaluate(use: Use): Color3
		local Theme = if unwrap(themeProvider.IsDark, use) then "Dark" else "Light"
		local Token = RBXDesignFoundations.Tokens[Theme][token]

		local FoundData = if not subcategory then Token[category] else Token[category][subcategory]
		return FoundData
	end

	return self.Scope:Computed(function(use: Use, innerScope: Scope) 
		return unwrap(evaluate(use))
	end)
end

return function(): (themeProvider, () -> ()?)
	if themeProvider.Scope then return themeProvider end
	local ThemeScope = Fusion:scoped()
	
	themeProvider.Theme = ThemeScope:Value(Studio.Theme.Name)
	themeProvider.IsDark = ThemeScope:Value(false)
	themeProvider.Scope = ThemeScope
	
	table.insert(ThemeScope, Studio.ThemeChanged:Connect(updateTheme))
	
	updateTheme()

	return themeProvider, function()
		Fusion.doCleanup(ThemeScope)
		table.clear(themeProvider.Cache)
		
		themeProvider.Theme = nil
		themeProvider.IsDark = nil
		themeProvider.Scope = nil
	end
end