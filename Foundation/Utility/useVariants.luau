local Foundation = script.Parent.Parent
local Utility = Foundation.Utility

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

type Use = Types.Use
type ValueFactory<Result, Args...> = (Use, Args...) -> Result

local cache = {}
local currentTheme = nil

local function useVariants<Result, Args...>(componentName: string, variantsFactory: ValueFactory<Result, Args...>, ...: Args...): Result
	local themeProvider = ThemeProvider()
	local theme = unwrap(themeProvider.Theme)

	-- Invalidate the cache if the theme swaps (e.g., Light -> Dark)
	if currentTheme ~= theme then
		table.clear(cache)
		currentTheme = theme
	end

	local value = cache[componentName]
	if not value then
		value = variantsFactory(...)
		cache[componentName] = value
	end

	return value
end

return useVariants