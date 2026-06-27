local Foundation = script.Parent.Parent
local Utility = Foundation.Utility

local PackageManager = require(Foundation.PackageManager)
local Fusion = PackageManager.getPackage("Fusion")

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types.Types)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)()

type Use = Types.Use
type ValueFactory<Result, Args...> = (Use, Args...) -> Result

local cache = {}
local currentTheme = nil

local function useVariants<Result, Args...>(use: Use, componentName: string, variantsFactory: ValueFactory<Result, Args...>, ...: Args...): Result
	local theme = unwrap(ThemeProvider.Theme, use)

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