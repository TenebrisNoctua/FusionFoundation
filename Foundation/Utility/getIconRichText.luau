local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local BuilderIcons = PackageManager.getPackage("BuilderIcons")
local Font = BuilderIcons.Font
local IconVariant = BuilderIcons.IconVariant

type IconVariant = typeof(IconVariant)

local function getIconRichText(iconName: string, iconVariant: IconVariant?): string
	local variant = iconVariant or IconVariant.Regular
	local font: Font = (Font :: any)[variant]
	return `<font family="{font.Family}" weight="{font.Weight.Value}">{iconName}</font>`
end

return getIconRichText
