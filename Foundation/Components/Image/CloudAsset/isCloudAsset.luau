local Foundation = script.Parent.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local FoundationCloudAssets = PackageManager.getPackage("FoundationCloudAssets").Assets

return function(img: string)
	return FoundationCloudAssets[img] ~= nil
end
