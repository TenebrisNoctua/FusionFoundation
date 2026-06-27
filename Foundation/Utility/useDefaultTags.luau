local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Utility = Foundation.Utility
local Types = require(Utility.Types.Types)
local unwrap = require(Utility.unwrap)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Tags = Types.Tags

local function useDefaultTags(scope: Scope, tags: UsedAs<Tags?>, defaults: UsedAs<string>): UsedAs<Tags>
	return scope:Computed(function(use: Use)
		local currentTags = unwrap(tags, use)
		local currentDefaults = unwrap(defaults, use)

		if currentTags == nil then
			return currentDefaults
		end

		if type(currentTags) == "string" then
			return `{currentDefaults} {currentTags}`
		else
			return Dash.join(currentTags, { [currentDefaults] = true })
		end
	end)
end

return useDefaultTags