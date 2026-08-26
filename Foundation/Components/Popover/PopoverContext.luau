local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Utility = Foundation.Utility
local Types = require(Utility.Types)
local StudioUri = require(Utility.Plugin.StudioUri)

type UsedAs<T> = Types.UsedAs<T>
type PopoverAnchor = Types.PopoverAnchor
type StudioUri = StudioUri.StudioUri

export type PopoverContextType = {
	anchor: UsedAs<PopoverAnchor?>,
	anchorUri: UsedAs<StudioUri?>,
	isOpen: UsedAs<boolean>,
	gui: UsedAs<Instance?>
}

return Fusion.Contextual(nil :: PopoverContextType?)
