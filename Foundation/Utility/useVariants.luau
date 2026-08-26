local Foundation = script.Parent.Parent
local Utility = Foundation.Utility

local Types = require(Utility.Types)

type Use = Types.Use
type ValueFactory<Result, Args...> = (Use, Args...) -> Result

local cache = {}
local currentTheme = nil

local function useVariants<Result, Args...>(theme: string, tokens: {[string]: any}, componentName: string, variantsFactory: ValueFactory<Result, Args...>, ...: Args...): Result
	-- Invalidate the cache if the theme swaps (e.g., Light -> Dark)
	if currentTheme ~= theme then
		table.clear(cache)
		currentTheme = theme
	end

	local value = cache[componentName]
	if not value then
		value = variantsFactory(tokens, ...)
		cache[componentName] = value
	end

	return value
end

return useVariants