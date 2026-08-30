--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	A special key for property tables, which allows users to apply a
	space-separated set of CollectionService tags to instances.
	
	This is a custom implementation that supports space-seperated tags.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
-- Memory
local checkLifetime = require(Package.Memory.checkLifetime)
-- Graph
local Observer = require(Package.Graph.Observer)
-- State
local castToState = require(Package.State.castToState)
local peek = require(Package.State.peek)

local function splitWords(tagString: string?): {[string]: boolean}
	local words = {}
	if tagString == nil then
		return words
	end
	for word in tagString:gmatch("%S+") do
		words[word] = true
	end
	return words
end

local Tags: Types.SpecialKey = {
	type = "SpecialKey",
	kind = "Tags",
	stage = "self",
	apply = function(self: Types.SpecialKey, scope: Types.Scope<unknown>, value: unknown, applyTo: Instance)
		if castToState(value) then
			local value = value :: Types.StateObject<string?>
			checkLifetime.bOutlivesA(
				scope,
				applyTo,
				value.scope,
				value.oldestTask,
				checkLifetime.formatters.boundTag,
				"tags"
			)
			
			local previousWords: {[string]: boolean} = {}
			Observer(scope, value :: any):onBind(function()
				local newWords = splitWords(peek(value))
				for word in previousWords do
					if not newWords[word] then
						applyTo:RemoveTag(word)
					end
				end
				for word in newWords do
					if not previousWords[word] then
						applyTo:AddTag(word)
					end
				end
				previousWords = newWords
			end)
		else
			for word in splitWords(value :: string?) do
				applyTo:AddTag(word)
			end
		end
	end
}

return Tags