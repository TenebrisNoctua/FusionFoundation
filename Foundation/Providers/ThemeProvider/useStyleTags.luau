local Foundation = script.Parent.Parent.Parent
local Utility = Foundation.Utility

local getFormattedTags = require(Utility.getFormattedTags)
local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types.Types)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Tags = Types.Tags

type AddTags = (string | { string }) -> ()

local FoundationUseStyleSheetRegistry = true

local function useStyleTags(scope: Scope, tags: UsedAs<Tags?>, addTags: AddTags): UsedAs<string?>
	local formattedTags = scope:Computed(function(use: Use | any)
		return getFormattedTags(unwrap(tags, use))
	end)

	local function registerTags()
		local currentFormatted = unwrap(formattedTags)
		if currentFormatted ~= nil then
			if FoundationUseStyleSheetRegistry then
				addTags(string.split(currentFormatted, " "))
			else
				addTags({currentFormatted})
			end
		end
	end
	registerTags()
	
	scope:Observer(formattedTags):onChange(registerTags)
	return formattedTags
end

return useStyleTags