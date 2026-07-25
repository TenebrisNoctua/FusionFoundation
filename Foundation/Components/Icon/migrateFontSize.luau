local Foundation = script.Parent.Parent.Parent

local Tokens = require(Foundation.Providers.ThemeProvider.Tokens)
type Tokens = Tokens.Tokens

local function migrateFontSize(size: number, tokens: Tokens): number
	local snapInterval = tokens.Size.Size_100
	local mediumMin = tokens.Size.Size_600
	local mediumMax = tokens.Size.Size_900

	if size >= mediumMin and size <= mediumMax then
		size = mediumMin
	end
	return math.round(size / snapInterval) * snapInterval
end

return migrateFontSize
