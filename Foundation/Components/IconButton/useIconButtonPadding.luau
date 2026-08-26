local Foundation = script.Parent.Parent.Parent
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local IconSize = require(Enums.IconSize)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type IconSize = IconSize.IconSize

local function useIconButtonPadding(
	size: IconSize,
	isBuilderIcon: boolean,
	tokens: {[string]: any}
): number
	local iconButtonPaddings = if isBuilderIcon
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
 	  	
	local padding = iconButtonPaddings[size]
	if padding == nil then
		error("[FusionFoundation]: Invalid icon button size: " .. tostring(size))
	end
	return padding
end

return useIconButtonPadding
