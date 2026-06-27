local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Dash = PackageManager.getPackage("Dash")

local Tokens = require(Foundation.Providers.ThemeProvider.Tokens)
local Types = require(script.Parent.Rules.Types)
local formatTokens = require(script.Parent.formatTokens)

type Tokens = Tokens.Tokens
type RulesGenerator = Types.RulesGenerator

local function generateRules(tokens: Tokens, rulesGenerator: RulesGenerator)
	local formattedTokens = formatTokens(tokens)
	local common, size, theme = rulesGenerator(tokens, formattedTokens)
	local rules = Dash.joinArrays(common, size, theme)

	return rules, common, size, theme
end

return generateRules
