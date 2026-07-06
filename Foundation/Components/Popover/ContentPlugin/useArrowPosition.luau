local Foundation = script.Parent.Parent.Parent.Parent

local Enums = Foundation.Enums
local Utility = Foundation.Utility

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local PopoverSide = require(Enums.PopoverSide)
local Radius = require(Enums.Radius)

local Constants = require(Foundation.Constants)
local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local SHADOW_SIZE = Constants.SHADOW_SIZE

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type PopoverSide = PopoverSide.PopoverSide
type Radius = Radius.Radius

return function(
	scope: Scope,
	contentSize: UsedAs<UDim2>,
	sidePosition: PopoverSide,
	radius: Radius,
	alignValue: number,
	arrowHeight: number,
	anchor: GuiBase2d?
): UsedAs<UDim2>
	local themeProvider = ThemeProvider()
	return scope:Computed(function(use: Use)
		local currentTokens = unwrap(themeProvider.Tokens, use)

		local baseRadiusInset = 0
		if radius == Radius.XSmall then
			baseRadiusInset = currentTokens.Size.Size_50
		elseif radius == Radius.Small then
			baseRadiusInset = currentTokens.Size.Size_100
		elseif radius == Radius.Medium then
			baseRadiusInset = currentTokens.Size.Size_200
		elseif radius == Radius.Large then
			baseRadiusInset = currentTokens.Size.Size_300
		end

		local value = unwrap(contentSize, use)
		local contentWidth = value.X.Offset
		local contentHeight = value.Y.Offset

		local radiusInset = baseRadiusInset
		if radius == Radius.Circle then
			radiusInset = math.min(contentWidth, contentHeight) / 2
		end

		local cornerInset = radiusInset + arrowHeight
		local isVertical = sidePosition == PopoverSide.Top or sidePosition == PopoverSide.Bottom

		local contentCrossSize = if isVertical then contentWidth else contentHeight
		local rawPosition: number

		if anchor and typeof(anchor) == "Instance" then
			local anchorSize = anchor.AbsoluteSize
			local anchorCrossSize = if isVertical then anchorSize.X else anchorSize.Y

			local anchorStartInContent: number
			if alignValue == 0 then
				anchorStartInContent = 0
			elseif alignValue == 0.5 then
				anchorStartInContent = (contentCrossSize - anchorCrossSize) / 2
			else
				anchorStartInContent = contentCrossSize - anchorCrossSize
			end

			local intersectionStart = math.max(0, anchorStartInContent)
			local intersectionEnd = math.min(contentCrossSize, anchorStartInContent + anchorCrossSize)

			if intersectionStart <= intersectionEnd then
				rawPosition = (intersectionStart + intersectionEnd) / 2
			else
				if contentCrossSize < anchorStartInContent then
					rawPosition = contentCrossSize - arrowHeight
				else
					rawPosition = arrowHeight
				end
			end
		else
			rawPosition = contentCrossSize * alignValue
		end

		local minPosition = cornerInset
		local maxPosition = contentCrossSize - cornerInset
		if maxPosition >= minPosition then
			rawPosition = math.clamp(rawPosition, minPosition, maxPosition)
		else
			rawPosition = contentCrossSize / 2
		end

		if isVertical then
			return UDim2.fromOffset(
				SHADOW_SIZE + rawPosition,
				SHADOW_SIZE + (if sidePosition == PopoverSide.Top then contentHeight else 0)
			)
		else
			return UDim2.fromOffset(
				SHADOW_SIZE + (if sidePosition == PopoverSide.Left then contentWidth else 0),
				SHADOW_SIZE + rawPosition
			)
		end
	end)
end