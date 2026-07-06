--!strict

-- Written by @TenebrisNoctua
-- Handles the initialization and usage of packages.

--// Variables

local PackagesSrc = script.Packages

local RBXDesignFoundations = require(PackagesSrc.RbxDesignFoundations)
local Dash = require(PackagesSrc.Dash)
local Fusion = require(PackagesSrc.Fusion)
local BuilderIcons = require(PackagesSrc.BuilderIcons)
local FoundationCloudAssets = require(PackagesSrc.FoundationCloudAssets)
local FoundationImages = require(PackagesSrc.FoundationImages)
local Signal = require(PackagesSrc.Signal)

local Packages = {
	RBXDesignFoundations = RBXDesignFoundations,
	Dash = Dash,
	Fusion = Fusion,
	BuilderIcons = BuilderIcons,
	FoundationImages = FoundationImages,
	FoundationCloudAssets = FoundationCloudAssets,
	Signal = Signal,
} :: {
	RBXDesignFoundations: typeof(RBXDesignFoundations),
	Dash: typeof(Dash),
	Fusion: typeof(Fusion),
	BuilderIcons: typeof(BuilderIcons),
	FoundationImages: typeof(FoundationImages),
	FoundationCloudAssets: typeof(FoundationCloudAssets),
	Signal: typeof(Signal),
	[string]: any
}

local ChangeablePackages = {"Fusion", "Dash"}

--// Types

type LibraryName = "Fusion" | "RBXDesignFoundations" | "Dash" | "BuilderIcons" | "FoundationImages" | "FoundationCloudAssets" | "Signal" | string

--// Local Functions

local function registerPackage(name: LibraryName, source: any)
	if not table.find(ChangeablePackages, name) then error("Given package cannot be registered.") end
	Packages[name] = (require)(source)
end

local function getPackage<T>(name: T | LibraryName): index<typeof(Packages), T>
	local Package = Packages[name]
	if not Package then error("Cannot find the requested package in the registry.") end
	return Package
end

--// Return Manager

return table.freeze({
	registerPackage = registerPackage,
	getPackage = getPackage
})