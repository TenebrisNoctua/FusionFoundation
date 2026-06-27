local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local endAlignedIcons: { [string]: true } = {
	[BuilderIcons.Icon.ArrowUpRightFromSquare] = true,
}

return endAlignedIcons
