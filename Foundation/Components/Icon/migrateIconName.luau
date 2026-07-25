local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local BuilderIcons = PackageManager.getPackage("BuilderIcons")
type IconVariant = BuilderIcons.IconVariant
local migrationLookUp = BuilderIcons.Migration

local function migrateIconName(name: string): { name: string, variant: IconVariant? } | nil
	return migrationLookUp["uiblox"][name]
end

return migrateIconName
