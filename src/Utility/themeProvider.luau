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
	Theme = {} :: Value<string>,
	IsDark = {} :: Value<boolean>,
	Scope = {} :: Scope,
	ItemScope = {} :: Scope
}

type State<T> = Types.State<T>
type Value<T> = Types.Value<T>
type Computed<T> = Types.Computed<T>

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

--// Main Functions

function themeProvider.GetColor(self: themeProvider, token: string, category: string, subcategory: string?): Computed<Color3>
	local function evaluate(use: Use): Color3
		local Theme = if unwrap(themeProvider.IsDark, use) then "Dark" else "Light"
		local Colors = RBXDesignFoundations.Tokens[Theme].Color
		
		local FoundColor = if not subcategory then Colors[token][category].Color3 else Colors[token][category][subcategory].Color3
		return FoundColor
	end
	
	return self.ItemScope:Computed(function(use: Use, innerScope: Scope) 
		return unwrap(evaluate(use))
	end)
end

function themeProvider.GetTransparency(self: themeProvider, token: string, category: string, subcategory: string?): Computed<number>
	local function evaluate(use: Use): number
		local Theme = if unwrap(themeProvider.IsDark, use) then "Dark" else "Light"
		local Colors = RBXDesignFoundations.Tokens[Theme].Color

		local FoundColor = if not subcategory then Colors[token][category].Transparency else Colors[token][category][subcategory].Transparency
		return FoundColor
	end

	return self.ItemScope:Computed(function(use: Use, innerScope: Scope) 
		return unwrap(evaluate(use))
	end)
end

function themeProvider.GetStyle(self: themeProvider, token: string, category: string, subcategory: string?): Computed<{Color3: Color3, Transparency: number}>
	local function evaluate(use: Use): number
		local Theme = if unwrap(themeProvider.IsDark, use) then "Dark" else "Light"
		local Colors = RBXDesignFoundations.Tokens[Theme].Color

		local FoundStyle = if not subcategory then Colors[token][category] else Colors[token][category][subcategory]
		return FoundStyle
	end

	return self.ItemScope:Computed(function(use: Use, innerScope: Scope) 
		return unwrap(evaluate(use))
	end)
end

function themeProvider.GetFontData(self: themeProvider, name: string): Computed<{Font: Enum.Font, FontSize: number, LetterSpacing: number, LineHeight: number}>
	local function evaluate(use: Use): {Font: Enum.Font, FontSize: number, LetterSpacing: number, LineHeight: number}
		local Theme = if unwrap(themeProvider.IsDark, use) then "Dark" else "Light"
		local Typography = RBXDesignFoundations.Tokens[Theme].Typography
		
		return Typography[name]
	end
	
	return self.ItemScope:Computed(function(use: Use, innerScope: Scope) 
		return unwrap(evaluate(use))
	end)
end

function themeProvider.GetTokenData(self: themeProvider, token: string, category: string, subcategory: string?): Computed<{[string]: any}>
	local function evaluate(use: Use): Color3
		local Theme = if unwrap(themeProvider.IsDark, use) then "Dark" else "Light"
		local Token = RBXDesignFoundations.Tokens[Theme][token]

		local FoundData = if not subcategory then Token[category] else Token[category][subcategory]
		return FoundData
	end

	return self.ItemScope:Computed(function(use: Use, innerScope: Scope) 
		return unwrap(evaluate(use))
	end)
end

return function(Scope: Scope?): themeProvider
	if not Scope and themeProvider.Scope.New then 
		return themeProvider
	elseif not Scope then
		error("themeProvider must be initialized with a scope before usage.")
	end
	
	themeProvider.Theme = Scope:Value(Studio.Theme.Name)
	themeProvider.IsDark = Scope:Value(false)
	themeProvider.Scope = Scope
	
	themeProvider.ItemScope = Fusion:scoped()
	
	table.insert(Scope, Studio.ThemeChanged:Connect(updateTheme))
	
	updateTheme()

	return themeProvider
end