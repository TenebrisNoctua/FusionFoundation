local Foundation = script.Parent.Parent.Parent

local Enums = Foundation.Enums
local InputSize = require(Enums.InputSize)

type InputSize = InputSize.InputSize

return function(tokens: {[string]: any}, size: InputSize): UDim2
	local knobSizes: { [InputSize]: number } = {
		[InputSize.XSmall] = tokens.Size.Size_300,
		[InputSize.Small] = tokens.Size.Size_400,
		[InputSize.Medium] = tokens.Size.Size_500,
		[InputSize.Large] = tokens.Size.Size_600
	}

	local knobSize = knobSizes[size]
	return UDim2.fromOffset(knobSize, knobSize)
end
