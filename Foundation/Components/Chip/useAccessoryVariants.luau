local Foundation = script.Parent.Parent.Parent

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useVariants = require(Utility.useVariants)
local composeStyleVariant = require(Utility.composeStyleVariant)

local ChipSize = require(Enums.ChipSize)

type ChipSize = ChipSize.ChipSize
type Style = "Circular" | "Default"
type Position = "Leading" | "Trailing"

local function variantsFactory(tokens: {[string]: any})
	-- Every circular accessory should be large, so we collapsed the two values (there were size and isCircular props before)
	local accessorySize: { [Style]: { [ChipSize]: UDim2 } } = {
		["Default"] = {
			[ChipSize.Small :: ChipSize] = UDim2.fromOffset(tokens.Size.Size_300, tokens.Size.Size_300),
			[ChipSize.Medium] = UDim2.fromOffset(tokens.Size.Size_400, tokens.Size.Size_400),
			[ChipSize.Large] = UDim2.fromOffset(tokens.Size.Size_500, tokens.Size.Size_500),
		},
		["Circular"] = {
			[ChipSize.Small :: ChipSize] = UDim2.fromOffset(tokens.Size.Size_400, tokens.Size.Size_400),
			[ChipSize.Medium] = UDim2.fromOffset(tokens.Size.Size_500, tokens.Size.Size_500),
			[ChipSize.Large] = UDim2.fromOffset(tokens.Size.Size_600, tokens.Size.Size_600),
		},
	}

	local accessorySpacing: { [Style]: { [ChipSize]: UDim } } = {
		["Circular"] = {
			[ChipSize.Small :: ChipSize] = UDim.new(0, tokens.Size.Size_150),
			[ChipSize.Medium] = UDim.new(0, tokens.Size.Size_200),
			[ChipSize.Large] = UDim.new(0, tokens.Size.Size_250),
		},
		["Default"] = {
			[ChipSize.Small :: ChipSize] = UDim.new(0, tokens.Padding.Small),
			[ChipSize.Medium] = UDim.new(0, tokens.Padding.Medium),
			[ChipSize.Large] = UDim.new(0, tokens.Padding.Medium),
		},
	}

	local textSpacing: { [Position]: { [ChipSize]: UDim } } = {
		["Leading"] = {
			[ChipSize.Small :: ChipSize] = UDim.new(0, tokens.Padding.XSmall),
			[ChipSize.Medium] = UDim.new(0, tokens.Size.Size_150),
			[ChipSize.Large] = UDim.new(0, tokens.Padding.Small),
		},
		["Trailing"] = {
			[ChipSize.Small :: ChipSize] = UDim.new(0, tokens.Size.Size_150),
			[ChipSize.Medium] = UDim.new(0, tokens.Padding.Small),
			[ChipSize.Large] = UDim.new(0, tokens.Size.Size_250),
		},
	}

	return {
		textSpacing = textSpacing,
		accessorySpacing = accessorySpacing,
		accessorySize = accessorySize,
	}
end

return function(theme: string, tokens: {[string]: any}, size: ChipSize, isLeading: boolean, isCircular: boolean)
	local props = useVariants(theme, tokens, "ChipAccessory", variantsFactory)

	local style: Style = if isCircular then "Circular" else "Default"
	local position: Position = if isLeading then "Leading" else "Trailing"

	return composeStyleVariant({
		accessory = {
			Size = props.accessorySize[style][size],
			padding = if isLeading
				then {
					left = props.accessorySpacing[style][size],
					right = props.textSpacing[position][size],
				}
				else {
					left = props.textSpacing[position][size],
					right = props.accessorySpacing[style][size],
				}
		}
	})
end
