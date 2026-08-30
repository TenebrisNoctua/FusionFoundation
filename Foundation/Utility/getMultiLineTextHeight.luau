local Foundation = script.Parent.Parent
local FontScales = require(Foundation.Components.Text.FontScales)

return function(fontSize: number, lineCount: number, lineHeight: number)
	if fontSize <= 0 or lineCount <= 0 then
		return 0
	end

	if lineHeight <= 1 then
		lineHeight = 1
	end

	fontSize = math.floor(fontSize)

	local paddingOffset = 0
	local nominalScale = FontScales[Font.fromEnum(Enum.Font.BuilderSans).Family]
	if nominalScale ~= nil then
		local rawTextSize = fontSize / nominalScale
		local rawLineHeight = lineHeight * nominalScale
		local heightOffset = rawTextSize * rawLineHeight - fontSize
		paddingOffset = heightOffset / 2
	end

	local multiLineHeight = math.ceil(((lineCount - 1) * lineHeight * fontSize))
	local roundedPadding = if paddingOffset >= 1 then math.ceil(paddingOffset) else math.floor(paddingOffset)

	return multiLineHeight + fontSize + roundedPadding
end