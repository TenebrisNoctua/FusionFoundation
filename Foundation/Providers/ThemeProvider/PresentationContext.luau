local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Types = require(Utility.Types)
local ColorNamespace = require(Enums.ColorNamespace)

type UsedAs<T> = Types.UsedAs<T>
type ColorNamespace = ColorNamespace.ColorNamespace

export type PresentationContextType = {
	isIconSize: UsedAs<boolean>,
	colorNamespace: UsedAs<ColorNamespace>,
}

local defaultContext: PresentationContextType = {
	isIconSize = false,
	colorNamespace = ColorNamespace.Color,
}

local PresentationContext = Fusion.Contextual(defaultContext)

local function usePresentationContext(): PresentationContextType
	return PresentationContext:now()
end

return {
	Context = PresentationContext,
	usePresentationContext = usePresentationContext
}
