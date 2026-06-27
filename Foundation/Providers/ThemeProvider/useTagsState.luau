local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Utility = Foundation.Utility
local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types.Types)

type UsedAs<T> = Types.UsedAs<T>
type Value<T> = Types.Value<T>
type Scope = Types.Scope

local function useTagsState(scope: Scope): (Value<{[string]: boolean}>, (...string) -> ())
	local tags = scope:Value({} :: { [string]: boolean })

	local function addTags(tags: {string})
		local newTags: { string } = {}

		for _, arg in tags do
			local parsedTags = string.split(arg, " ")
			for _, tag in parsedTags do
				table.insert(newTags, tag)
			end
		end

		local oldTagSet = unwrap(tags)
		local update = false

		for _, tag in newTags do
			if oldTagSet[tag] ~= true then
				update = true
				break
			end
		end

		if update then
			local newTagSet = table.clone(oldTagSet)
			for _, tag in newTags do
				newTagSet[tag] = true
			end
			tags:set(newTagSet)
		end
	end

	return tags, addTags
end

return useTagsState