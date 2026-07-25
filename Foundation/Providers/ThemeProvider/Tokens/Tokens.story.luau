local Foundation = script.Parent.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)
local StoryMiddleware = require(Utility.Stories.StoryMiddleware)

local Device = require(Enums.Device)

local View = require(Foundation.Components.View)
local Text = require(Foundation.Components.Text)
local ScrollView = require(Foundation.Components.ScrollView)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local TokenProcessingUtilities = require(script.Parent.TokenProcessingUtilities)

type Scope = Types.Scope
type Use = Types.Use

local orderedTokenCategories = TokenProcessingUtilities.orderedTokenCategories
local formatTokenValue = TokenProcessingUtilities.formatTokenValue
local isColorStyle = TokenProcessingUtilities.isColorStyle
local collectTokens = TokenProcessingUtilities.collectTokens
local collectTokensWithSubcategories = TokenProcessingUtilities.collectTokensWithSubcategories
local hasSubcategories = TokenProcessingUtilities.hasSubcategories
local sortTokens = TokenProcessingUtilities.sortTokens

local function filterAndSortTokens(tokens, searchText: string, category: string)
	local result = {}

	for _, token in tokens do
		local searchLower = string.lower(searchText)
		local fullSearchPath = category .. "." .. token.fullPath
		local keyLower = string.lower(fullSearchPath)

		if searchText == "" or string.find(keyLower, searchLower, 1, true) then
			table.insert(result, token)
		end
	end

	local notExclusivelyNumbers = Dash.some(result, function(token)
		return typeof(token.value) ~= "number"
	end)
	local allNumeric = not notExclusivelyNumbers

	table.sort(result, function(a, b)
		return sortTokens(
			a.fullPath .. if allNumeric then `| {a.value} |` else "",
			b.fullPath .. if allNumeric then `| {b.value} |` else "",
			allNumeric
		)
	end)

	return result
end

local function createTokenItem(scope, token, category, layoutOrder, isOdd, alternateRowBackgrounds)
	local isColor = typeof(token.value) == "Color3"
	local isColorStyleValue = isColorStyle(token.value)

	local tag = "size-full-0 auto-y row gap-small align-center"
	if isOdd and alternateRowBackgrounds then
		tag = tag .. " bg-surface-100"
	end

	local children = {
		Text {
			scope = scope,
			tag = "auto-y text-body-medium text-align-x-left",
			Size = UDim2.fromScale(0.5, 0),
			Text = `{category}.{token.fullPath}`,
			LayoutOrder = 1,
		},
	}

	if isColor or isColorStyleValue then
		table.insert(children, View {
			scope = scope,
			tag = "size-500-500 radius-small",
			backgroundStyle = if isColor
				then { Color3 = token.value, Transparency = 0 }
				else if isColorStyleValue then token.value else nil,
			LayoutOrder = 2,
		})
	end

	table.insert(children, Text {
		scope = scope,
		tag = "size-0-0 auto-xy text-caption-large text-align-x-left",
		Text = formatTokenValue(token.value),
		LayoutOrder = 3,
	})

	return View {
		scope = scope,
		tag = tag,
		LayoutOrder = layoutOrder,
		children = children,
	}
end

local function createTokenSubsection(scope, subcategory, tokens, searchText, category, layoutOrder, alternateRowBackgrounds)
	local filteredTokens = filterAndSortTokens(tokens, searchText, category)
	if #filteredTokens == 0 then
		return nil
	end

	local children = {
		Text {
			scope = scope,
			Text = subcategory,
			tag = "size-full-0 auto-y padding-top-medium text-title-medium text-align-x-left",
			LayoutOrder = 1,
		},
	}

	for index, token in ipairs(filteredTokens) do
		table.insert(children, createTokenItem(
			scope, token, category, index, index % 2 == 1, alternateRowBackgrounds
		))
	end

	return View {
		scope = scope,
		tag = "col gap-small size-full-0 auto-y",
		LayoutOrder = layoutOrder,
		children = children,
	}
end

local function createTokenSection(scope, category, tokens, searchText, hasSubs, layoutOrder, alternateRowBackgrounds)
	local children = {
		Text {
			scope = scope,
			Text = category,
			tag = "size-full-0 auto-y text-heading-small text-align-x-left",
			LayoutOrder = 1,
		},
	}

	local contentChildren = {}

	if hasSubs and type(tokens) == "table" then
		local subcategoryKeys = {}
		for subcategory in tokens do
			table.insert(subcategoryKeys, subcategory)
		end
		table.sort(subcategoryKeys, sortTokens)

		local hasVisible = false

		for index, subcategory in ipairs(subcategoryKeys) do
			local subTokens = tokens[subcategory]
			if subTokens and #subTokens > 0 then
				local anyMatch = false
				for _, token in subTokens do
					local searchLower = string.lower(searchText)
					local fullSearchPath = `{category}.{token.fullPath}`
					local keyLower = string.lower(fullSearchPath)
					if searchText == "" or string.find(keyLower, searchLower, 1, true) then
						anyMatch = true
						break
					end
				end
				if anyMatch then
					hasVisible = true
					local subsection = createTokenSubsection(
						scope, subcategory, subTokens, searchText, category, 2 + index, alternateRowBackgrounds
					)
					if subsection then
						table.insert(contentChildren, subsection)
					end
				end
			end
		end

		if not hasVisible then
			return nil
		end
	else
		local filteredTokens = filterAndSortTokens(tokens, searchText, category)
		if #filteredTokens == 0 then
			return nil
		end

		for index, token in ipairs(filteredTokens) do
			table.insert(contentChildren, createTokenItem(
				scope, token, category, 2 + index, index % 2 == 1, alternateRowBackgrounds
			))
		end
	end

	table.insert(children, View {
		scope = scope,
		tag = "col gap-small size-full-0 auto-y",
		LayoutOrder = 2,
		children = contentChildren,
	})

	return View {
		scope = scope,
		tag = "col gap-medium size-full-0 auto-y",
		LayoutOrder = layoutOrder,
		children = children,
	}
end

return {
	fusion = Fusion,
	summary = "Tokens",
	controls = {
		theme = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = "Dark",
			List = { "Dark", "Light" },
			DefIndex = 1,
		},
		device = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = "Desktop",
			List = Dash.values(Device),
			DefIndex = 1,
		},
		searchText = "",
		flattenColors = true,
		alternateRowBackgrounds = false,
	},
	story = StoryMiddleware(function(props)
		local scope = props.scope
		local controls = props.controls

		local theme = ThemeProvider()

		local allTokens = scope:Computed(function(use)
			local tokens = unwrap(theme.Tokens, use)
			local flatten = unwrap(controls.flattenColors, use)

			local collected = {}
			for _, category in orderedTokenCategories do
				if tokens[category] then
					local categoryTokens = tokens[category]
					if hasSubcategories(categoryTokens) then
						collected[category] = collectTokensWithSubcategories(categoryTokens, category, nil, flatten)
					else
						collected[category] = collectTokens(categoryTokens, category, nil, flatten)
					end
				end
			end

			return collected
		end)

		return ScrollView {
			scope = scope,
			backgroundStyle = { Transparency = 1 },
			tag = "auto-xy padding-large",
			children = scope:Computed(function(use, innerScope)
				local tokens = unwrap(allTokens, use)
				local searchText = unwrap(controls.searchText, use)
				local alternateRowBackgrounds = unwrap(controls.alternateRowBackgrounds, use)

				local sortedCategories = {}
				for _, category in orderedTokenCategories do
					if tokens[category] then
						table.insert(sortedCategories, category)
					end
				end

				local children = { theme.StyleLink }

				for index, category in ipairs(sortedCategories) do
					local categoryTokens = tokens[category]
					local categoryHasSubcategories = false

					if categoryTokens and type(categoryTokens) == "table" then
						for key, value in categoryTokens do
							if type(value) == "table" and type(key) == "string" then
								categoryHasSubcategories = true
								break
							end
						end
					end

					local section = createTokenSection(
						innerScope, category, categoryTokens, searchText, categoryHasSubcategories, index, alternateRowBackgrounds
					)
					if section then
						table.insert(children, section)
					end
				end

				return children
			end)
		}
	end)
}