local Foundation = script.Parent
local PackageManager = require(Foundation.PackageManager)
local Fusion = PackageManager.getPackage("Fusion")

local RuleTypes = require(script.Rules.Types)
local createStyleSheetRules = require(script.createStyleSheetRules)

local useGeneratedRules = require(Foundation.Utility.useGeneratedRules)
local unwrap = require(Foundation.Utility.unwrap)
local Types = require(Foundation.Utility.Types.Types)

local Device = require(Foundation.Enums.Device)
local Theme = require(Foundation.Enums.Theme)

local Children = Fusion.Children

type Theme = Theme.Theme
type Device = Device.Device

type StyleAttribute<T> = RuleTypes.StyleAttribute<T>
type StyleRule = RuleTypes.StyleRule
type AttributesCache = createStyleSheetRules.AttributesCache

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type StyleSheetProps = {
	scope: Scope,
	theme: UsedAs<Theme>,
	device: UsedAs<Device>,
	scale: UsedAs<number?>,
	tags: UsedAs<{ [string]: boolean }>,
	derives: UsedAs<{ StyleSheet }?>?,
	setStyleSheetRef: { current: ((StyleSheet?) -> ()) | nil }?,
}

local FoundationDisableStyleProviderDerives = false

local function StyleSheet(props: StyleSheetProps)
	local scope = props.scope

	local sheet = scope:Value(nil :: StyleSheet?)
	local attributesCache = {} :: AttributesCache

	local rules = useGeneratedRules(scope, props.theme, props.device)

	scope:Observer(sheet):onChange(function()
		local currentSheet = unwrap(sheet)
		if props.setStyleSheetRef and props.setStyleSheetRef.current then
			props.setStyleSheetRef.current(currentSheet)
		end
	end)

	local derivesTracker = scope:Computed(function(use: Use)
		return {unwrap(sheet, use), unwrap(props.derives, use)}
	end)

	scope:Observer(derivesTracker):onChange(function()
		local currentSheet = unwrap(sheet)
		if currentSheet and not FoundationDisableStyleProviderDerives then
			local currentDerives = unwrap(props.derives)
			currentSheet:SetDerives((currentDerives or {}) :: { Instance })
		end
	end)

	local styleRules = scope:Computed(function(use: Use)
		local currentSheet = unwrap(sheet, use)
		if currentSheet then
			return createStyleSheetRules(
				unwrap(rules, use),
				unwrap(props.tags, use),
				currentSheet,
				attributesCache,
				unwrap(props.scale, use)
			)
		else
			return nil
		end
	end)

	local foundationStyleSheet = sheet:set(scope:New "StyleSheet" {
		[Children] = styleRules,
	})

	local foundationStyleLink = scope:New "StyleLink" {
		StyleSheet = sheet,
	}

	return {
		FoundationStyleSheet = foundationStyleSheet,
		FoundationStyleLink = foundationStyleLink,
	}
end

return StyleSheet