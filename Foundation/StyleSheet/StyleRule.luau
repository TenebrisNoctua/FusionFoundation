local Foundation = script.Parent.Parent
local Utility = Foundation.Utility
local Types = require(Utility.Types.Types)
local unwrap = require(Utility.unwrap)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type StyleRuleProps = {
	scope: Scope,
	Priority: UsedAs<number?>?,
	Selector: UsedAs<string>,
	properties: UsedAs<{
		[string]: any,
	}>,
}

local function StyleRule(props: StyleRuleProps)
	local scope = props.scope
	
	local ruleNode: StyleRule = scope:New "StyleRule" {
		Priority = scope:Computed(function(use: Use)
			return use(props.Priority) or 1 -- 0 reserved for default styles
		end),
		Selector = props.Selector,
	}

	local propertyTracker = scope:Computed(function(use: Use)
		return unwrap(props.properties, use)
	end)

	local function applyProperties()
		local currentProperties = unwrap(propertyTracker)
		if currentProperties then
			ruleNode:SetProperties(currentProperties)
		end
	end
	applyProperties()

	scope:Observer(propertyTracker):onChange(applyProperties)
	return ruleNode
end

return StyleRule