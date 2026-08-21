local Foundation = script.Parent.Parent

local Enums = Foundation.Enums
local Utility = Foundation.Utility

local Types = require(Utility.Types)
local unwrap = require(Utility.unwrap)

local IconSize = require(Enums.IconSize)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type IconSize = IconSize.IconSize

local function isNumber(value: any): boolean
	return typeof(unwrap(value)) == "number"
end

local function useIconSize(
	size: IconSize | number,
	isBuilderIconBool: boolean,
	isIconButton: boolean?
): UDim2
	local Theme = ThemeProvider()
	local tokens = unwrap(Theme.Tokens)

	local iconSizes = if isBuilderIconBool
		then {
			[IconSize.XSmall :: IconSize] = if isIconButton then tokens.Size.Size_400 else tokens.Size.Size_300,
			[IconSize.Small :: IconSize] = if isIconButton then tokens.Size.Size_500 else tokens.Size.Size_400,
			[IconSize.Medium :: IconSize] = if isIconButton then tokens.Size.Size_600 else tokens.Size.Size_500,
			[IconSize.Large :: IconSize] = if isIconButton then tokens.Size.Size_700 else tokens.Size.Size_600,
			[IconSize.XLarge :: IconSize] = if isIconButton then tokens.Size.Size_800 else tokens.Size.Size_700,
			[IconSize.XXLarge :: IconSize] = if isIconButton then tokens.Size.Size_900 else tokens.Size.Size_800,
		}
		else {
			[IconSize.XSmall :: IconSize] = tokens.Size.Size_200,
			[IconSize.Small :: IconSize] = tokens.Size.Size_400,
			[IconSize.Medium :: IconSize] = tokens.Size.Size_900,
			[IconSize.Large :: IconSize] = tokens.Size.Size_1200,
			[IconSize.XLarge :: IconSize] = tokens.Size.Size_2400,
			[IconSize.XXLarge :: IconSize] = 24 * tokens.Size.Size_200,
		}

	if isNumber(size) then
		if not isBuilderIconBool then
			error("Invalid icon size: " .. tostring(size))
		end
		return UDim2.fromOffset(size, size)
	else
		local resolvedSize = iconSizes[size :: IconSize]
		if resolvedSize == nil then
			error("Invalid icon size: " .. tostring(size))
		end
		return UDim2.fromOffset(resolvedSize, resolvedSize)
	end
end

return useIconSize