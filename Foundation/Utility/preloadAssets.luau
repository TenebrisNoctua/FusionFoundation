local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Dash = PackageManager.getPackage("Dash")
local FoundationCloudAssets = PackageManager.getPackage("FoundationCloudAssets")

local Assets = FoundationCloudAssets.Assets
local preloadAsset = FoundationCloudAssets.preloadAsset

return function(assets: string | { string })
	assets = if typeof(assets) == "string" then { assets } else assets
	Dash.forEach(assets :: { string }, function(asset)
		assert(
			(Assets :: any)[asset],
			`preloadAssets should only be used with valid FoundationCloudAssets; {asset} is an invalid name`
		)
		preloadAsset(asset)
	end)
end
