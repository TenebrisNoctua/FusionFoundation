local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local getBuilderIconForCurrentPlatform = BuilderIcons.getBuilderIconForCurrentPlatform

return getBuilderIconForCurrentPlatform
