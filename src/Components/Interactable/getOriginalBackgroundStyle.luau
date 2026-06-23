local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Utility = Foundation.Utility
local Types = require(Utility.Types.Types)
local themeProvider = require(Utility.themeProvider)
local unwrap = require(Utility.unwrap)

type Value<T> = Types.Value<T>
type CanBeValue<T> = Value<T> | T

type ColorStyle = Types.ColorStyle

local function getOriginalBackgroundStyle(
	backgroundColor: CanBeValue<Color3>?,
	backgroundTransparency: CanBeValue<number>?
): ColorStyle
	local Theme = themeProvider()
	return {
		Color3 = unwrap(backgroundColor) or unwrap(Theme:GetColor("Content", "Default")),
		Transparency = unwrap(backgroundTransparency) or unwrap(Theme:GetTransparency("Content", "Default"))
	}
end

return getOriginalBackgroundStyle
