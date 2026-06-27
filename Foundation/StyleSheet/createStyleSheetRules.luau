local StyleSheetRoot = script.Parent
local Foundation = StyleSheetRoot.Parent

local StyleRule = require(StyleSheetRoot.StyleRule)
local RuleTypes = require(StyleSheetRoot.Rules.Types)

local Utility = Foundation.Utility
local unwrap = require(Utility.unwrap)
local scaleValue = require(Utility.scaleValue)
local Types = require(Utility.Types.Types)

local Device = require(Foundation.Enums.Device)
local Theme = require(Foundation.Enums.Theme)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type Theme = Theme.Theme
type Device = Device.Device
type StyleRuleNoTag = RuleTypes.StyleRuleNoTag
type StyleAttribute<T> = RuleTypes.StyleAttribute<T>

export type AttributesCache = { [string]: number }

local FoundationDisableTokenScaling = false

local function insertRule(scope: Scope, ruleNodes: { any }, rule: StyleRuleNoTag, tag: string)
	local properties = rule.properties

	local tagSelector = "." .. tag
	local modifier = if rule.modifier ~= nil then ":" .. rule.modifier else ""
	local pseudo = if rule.pseudo ~= nil then " ::" .. rule.pseudo else ""
	local selector = tagSelector .. modifier .. pseudo

	if rule.pseudo ~= nil then
		selector = selector .. ", " .. tagSelector .. modifier .. " > " .. rule.pseudo
	end

	table.insert(
		ruleNodes,
		StyleRule({
			scope = scope,
			Priority = rule.priority,
			Selector = selector,
			properties = properties,
		})
	)
end

local function updateRuleAttributes(
	sheet: StyleSheet,
	attributes: { StyleAttribute<unknown> }?,
	attributesCache: AttributesCache,
	scale: number?
)
	attributes = attributes or {}
	scale = if FoundationDisableTokenScaling then 1 else scale or 1

	for _, attribute in attributes :: { StyleAttribute<unknown> } do
		if attributesCache[attribute.name] ~= scale then
			local scaledValue = scaleValue(attribute.value, scale)
			sheet:SetAttribute(attribute.name, scaledValue)
			attributesCache[attribute.name] = scale :: number
		end
	end
end

local function createStyleSheetRules(
	scope: Scope,
	rules: UsedAs<{ [string]: StyleRuleNoTag }>,
	tags: UsedAs<{ [string]: boolean }>,
	sheet: StyleSheet?,
	attributesCache: AttributesCache?,
	scale: UsedAs<number?>?
): { any }
	local ruleNodes = {}

	local currentRules = unwrap(rules)
	local currentTags = unwrap(tags)
	local currentScale = unwrap(scale)

	if not currentRules or not currentTags then
		return ruleNodes
	end

	for tag, _ in currentTags do
		local rule = currentRules[tag]

		if rule == nil then
			continue
		end

		if sheet and attributesCache then
			updateRuleAttributes(sheet :: StyleSheet, rule.attributes, attributesCache :: AttributesCache, currentScale)
		end
		insertRule(scope, ruleNodes, rule, tag)

		if rule.children then
			for _, child in rule.children do
				if sheet and attributesCache then
					updateRuleAttributes(
						sheet :: StyleSheet,
						child.attributes,
						attributesCache :: AttributesCache,
						currentScale
					)
				end
				insertRule(scope, ruleNodes, child, child.tag)
			end
		end
	end

	return ruleNodes
end

return createStyleSheetRules