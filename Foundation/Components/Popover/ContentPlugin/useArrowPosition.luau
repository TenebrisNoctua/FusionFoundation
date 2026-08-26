local Foundation = script.Parent.Parent.Parent.Parent

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local Radius = require(Enums.Radius)
local PopoverSide = require(Enums.PopoverSide)

local Constants = require(Foundation.Constants)

local SHADOW_SIZE = Constants.SHADOW_SIZE

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type PopoverSide = PopoverSide.PopoverSide
type Radius = Radius.Radius

return function(
	scope: Scope,
	contentSize: UsedAs<UDim2>,
	sidePosition: UsedAs<PopoverSide>,
	radius: UsedAs<Radius>,
	alignValue: UsedAs<number>,
	anchor: UsedAs<GuiBase2d?>,
	arrowHeight: number,
	tokens: {[string]: any}
): UsedAs<UDim2>
	return scope:Computed(function(use: Use)
		local currentSide = unwrap(sidePosition, use)
		local currentRadius = unwrap(radius, use)
		local currentAlignValue = unwrap(alignValue, use)
		local currentAnchor = unwrap(anchor, use)

		local baseRadiusInset = 0
		if currentRadius == Radius.XSmall then
			baseRadiusInset = tokens.Size.Size_50
		elseif currentRadius == Radius.Small then
			baseRadiusInset = tokens.Size.Size_100
		elseif currentRadius == Radius.Medium then
			baseRadiusInset = tokens.Size.Size_200
		elseif currentRadius == Radius.Large then
			baseRadiusInset = tokens.Size.Size_300
		end

		local value = unwrap(contentSize, use)
		local contentWidth = value.X.Offset
		local contentHeight = value.Y.Offset

		local radiusInset = baseRadiusInset
		if currentRadius == Radius.Circle then
			radiusInset = math.min(contentWidth, contentHeight) / 2
		end

		local cornerInset = radiusInset + arrowHeight
		local isVertical = currentSide == PopoverSide.Top or currentSide == PopoverSide.Bottom

		local contentCrossSize = if isVertical then contentWidth else contentHeight
		local rawPosition: number

		if currentAnchor and typeof(currentAnchor) == "Instance" then
			local anchorSize = currentAnchor.AbsoluteSize
			local anchorCrossSize = if isVertical then anchorSize.X else anchorSize.Y

			local anchorStartInContent: number
			if currentAlignValue == 0 then
				anchorStartInContent = 0
			elseif currentAlignValue == 0.5 then
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
			rawPosition = contentCrossSize * currentAlignValue
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
				SHADOW_SIZE + (if currentSide == PopoverSide.Top then contentHeight else 0)
			)
		else
			return UDim2.fromOffset(
				SHADOW_SIZE + (if currentSide == PopoverSide.Left then contentWidth else 0),
				SHADOW_SIZE + rawPosition
			)
		end
	end)
end