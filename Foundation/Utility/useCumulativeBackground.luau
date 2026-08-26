local Foundation = script.Parent.Parent
local Utility = Foundation.Utility

local unwrap = require(Utility.unwrap)
local isState = require(Utility.isState)
local Types = require(Utility.Types)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type ColorStyle = Types.ColorStyle

--[[
	Computes a cumulative background by blending two color styles.
	The element background is blended over the base background,
	taking into account the transparency of the element background.
]]
local function useCumulativeBackground(
	scope: Scope,
	background: UsedAs<ColorStyle>,
	elementBackground: UsedAs<ColorStyle>
): UsedAs<ColorStyle>
	if isState(background) or isState(elementBackground) then
		return scope:Computed(function(use: Use)
			local bg = unwrap(background, use)
			local elemBg = unwrap(elementBackground, use)
			return {
				Color3 = elemBg.Color3:Lerp(bg.Color3, elemBg.Transparency),
				Transparency = 0
			}
		end)
	else
		return {
			Color3 = elementBackground.Color3:Lerp(background.Color3, elementBackground.Transparency),
			Transparency = 0
		}
	end
end

return useCumulativeBackground