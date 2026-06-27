local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Utility = Foundation.Utility
local Types = require(Utility.Types.Types)
local unwrap = require(Utility.unwrap)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

type UsedAs<T> = Types.UsedAs<T>
type ColorStyle = Types.ColorStyle

local function getOriginalBackgroundStyle(
	backgroundColor: UsedAs<Color3>?,
	backgroundTransparency: UsedAs<number>?
): ColorStyle
	local Theme = ThemeProvider()
	return {
		Color3 = unwrap(backgroundColor) or unwrap(Theme:GetColor("Content", "Default")),
		Transparency = unwrap(backgroundTransparency) or unwrap(Theme:GetTransparency("Content", "Default"))
	}
end

return getOriginalBackgroundStyle
