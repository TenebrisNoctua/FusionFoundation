local Foundation = script.Parent.Parent.Parent
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local IconSize = require(Enums.IconSize)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

type Scope = Types.Scope
type UsedAs<T> = Types.UsedAs<T>
type Use = Types.Use

type IconSize = IconSize.IconSize

local function useIconButtonPadding(
	Scope: Scope,
	size: UsedAs<IconSize>,
	isBuilderIconBool: boolean
): UsedAs<number>
	local Theme = ThemeProvider()

	return Scope:Computed(function(use: Use)
		local tokens = unwrap(Theme.Tokens, use)
		local sizeValue = unwrap(size, use)

		local iconButtonPaddings = if isBuilderIconBool
			then {
				[IconSize.XSmall :: IconSize] = tokens.Size.Size_150,
				[IconSize.Small :: IconSize] = tokens.Size.Size_200,
				[IconSize.Medium :: IconSize] = tokens.Size.Size_250,
				[IconSize.Large :: IconSize] = tokens.Size.Size_350,
			}
			else {
				[IconSize.XSmall :: IconSize] = tokens.Size.Size_50,
				[IconSize.Small :: IconSize] = tokens.Size.Size_50,
				[IconSize.Medium :: IconSize] = tokens.Size.Size_100,
				[IconSize.Large :: IconSize] = tokens.Size.Size_150,
				[IconSize.XLarge :: IconSize] = tokens.Size.Size_200,
				[IconSize.XXLarge :: IconSize] = tokens.Size.Size_250,
			}

		local padding = iconButtonPaddings[sizeValue]
		if padding == nil then
			error("Invalid icon button size: " .. tostring(sizeValue))
		end
		return padding
	end)
end

return useIconButtonPadding
