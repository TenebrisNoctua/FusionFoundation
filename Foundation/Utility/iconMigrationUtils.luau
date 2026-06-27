local Foundation = script.Parent.Parent
local Utility = script.Parent

local PackageManager = require(Foundation.PackageManager)
local isBuilderIcon = require(Utility.isBuilderIcon)

local BuilderIcons = PackageManager.getPackage("BuilderIcons")
local migrationLookup = BuilderIcons.Migration["uiblox"]

local function isMigrated(name: string)
	return migrationLookup[name] ~= nil
end

local function isBuilderOrMigratedIcon(name: string)
	return isBuilderIcon(name) or isMigrated(name)
end

return {
	isMigrated = isMigrated,
	isBuilderOrMigratedIcon = isBuilderOrMigratedIcon,
}
