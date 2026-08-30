--[[
	An estimate for the "widest" character to check forced
	text wrapping behavior for. There's not a great way to
	derive this value other than GetTextBoundsAsync. This
	is used when checking series of characters with no
	whitespace / wrapping breaks.
]]
local WIDEST_CHAR_HEIGHT_TO_WIDTH_RATIO = 1.4

local function charAt(text: string, position: number): string
	return text:sub(position, position)
end

--[[
	This function is a utility for estimating the position of a cursor
	within a multi-line textbox. To achieve scrolling behavior with a TextBox,
	due to engine limitations we need to manually calculate the CanvasPosition
	of a ScrollingFrame and apply this based on where the CursorPosition is.

	The behavior for line-wrapping in TextBox is not exposed to developers,
	and using :GetTextBoundsAsync only works in full blocks of text. We want
	to determine bounds based on a cursor position in the middle of a block of
	text.
]]
local function truncateTextToCursor(textBox: TextBox): string
	local cursorPosition = textBox.CursorPosition
	if cursorPosition == -1 then
		return ""
	end

	local text = textBox.Text
	local textHeight = textBox.TextSize * textBox.LineHeight

	local largestCharacterWidth = textHeight / WIDEST_CHAR_HEIGHT_TO_WIDTH_RATIO
	local maxLookAhead = textBox.AbsoluteSize.X / largestCharacterWidth

	local maxLookAheadPosition = cursorPosition + maxLookAhead
	local nextNewline = string.find(text, "\n", cursorPosition) or math.huge
	local nextSpace = string.find(text, "[ \t\f\v]", cursorPosition) or math.huge
	local truncateEnd = math.min(nextNewline - 1, nextSpace, #text)
	local isWithinNewlines = charAt(text, cursorPosition):match("\n")
		and (charAt(text, cursorPosition - 1):match("\n") or cursorPosition == 1)

	if isWithinNewlines then
		truncateEnd = cursorPosition - 1
	elseif truncateEnd > maxLookAheadPosition then
		truncateEnd = cursorPosition
	end

	return utf8.char(utf8.codepoint(text, 1, truncateEnd))
end

return truncateTextToCursor