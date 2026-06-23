local Foundation = script.Parent.Parent
local Utility = Foundation.Utility

local PackageManager = require(Foundation.PackageManager)
local Fusion = PackageManager.getPackage("Fusion")

local Types = require(Utility.Types.Types)
local themeProvider = require(Utility.themeProvider)()

type Use = Types.Use
type ValueFactory<Result, Args...> = (Use, Args...) -> Result

local cache = {}
local currentTheme = nil

local function useVariants<Result, Args...>(use: Use, componentName: string, variantsFactory: ValueFactory<Result, Args...>, ...: Args...): Result
	-- Passing the themeProvider's state through 'use' ensures that any Computed 
	-- calling this function will re-evaluate when the theme changes.
	local theme = use(themeProvider.Theme)

	-- Invalidate the cache if the theme swaps (e.g., Light -> Dark)
	if currentTheme ~= theme then
		table.clear(cache)
		currentTheme = theme
	end

	local value = cache[componentName]
	if not value then
		value = variantsFactory(use, ...)
		cache[componentName] = value
	end

	return value
end

return useVariants