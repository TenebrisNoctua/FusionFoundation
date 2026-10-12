local Foundation = script.Parent.Parent

local Utility = Foundation.Utility

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local TextService = game:GetService("TextService")

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type FontStyle = Types.FontStyle

-- Returns a Computed holding the measured size of the given text, or nil if no text was provided.
local function useTextSize(scope: Scope, text: UsedAs<string?>, fontStyle: UsedAs<FontStyle>, frameSize: UsedAs<Vector2?>?): UsedAs<Vector2?>
	return scope:Computed(function(use: Use)
		local textValue = unwrap(text, use)
		if not textValue then return end

		local style = unwrap(fontStyle, use)
		local frame = unwrap(frameSize, use)

		return TextService:GetTextSize(
			textValue,
			style.FontSize :: number,
			style.Font :: Enum.Font,
			if frame then frame else Vector2.new(math.huge, math.huge)
		)
	end)
end

return useTextSize
