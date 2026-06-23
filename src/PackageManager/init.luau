--!strict

-- Written by @TenebrisNoctua
-- Handles the initialization and usage of packages.

--// Variables

local Types = require(script.Parent.Utility.Types.Types)
local RBXDesignFoundations = require(script.Packages.RbxDesignFoundations)
local Dash = require(script.Packages.Dash)
local Fusion = require(script.Packages.Fusion)
local BuilderIcons = require(script.Packages.BuilderIcons)
local FoundationCloudAssets = require(script.Packages.FoundationCloudAssets)
local FoundationImages = require(script.Packages.FoundationImages)

local Packages = {
	RBXDesignFoundations = RBXDesignFoundations,
	Dash = Dash,
	Fusion = Fusion,
	BuilderIcons = BuilderIcons,
	FoundationImages = FoundationImages,
	FoundationCloudAssets = FoundationCloudAssets,
} :: {
	RBXDesignFoundations: typeof(RBXDesignFoundations),
	Dash: typeof(Dash),
	Fusion: typeof(Fusion),
	BuilderIcons: typeof(BuilderIcons),
	FoundationImages: typeof(FoundationImages),
	FoundationCloudAssets: typeof(FoundationCloudAssets),
	[string]: any
}

local ChangeablePackages = {"Fusion", "Dash"}

--// Types

type LibraryName = "Fusion" | "RBXDesignFoundations" | "Dash" | "BuilderIcons" | "FoundationImages" | "FoundationCloudAssets" | "Motion" | string

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