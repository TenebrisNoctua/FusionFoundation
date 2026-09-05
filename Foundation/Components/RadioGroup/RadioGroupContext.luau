local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Utility = Foundation.Utility
local Types = require(Utility.Types)

type UsedAs<T> = Types.UsedAs<T>

export type RadioGroupContextType = {
	value: UsedAs<string?>,
	onValueChanged: (newValue: string) -> (),
	Selectable: UsedAs<boolean>,
}

local defaultContext: RadioGroupContextType = {
	value = nil,
	onValueChanged = function(_newValue: string)
		warn("No RadioGroup found for RadioGroupItem")
	end,
	Selectable = true
}

return Fusion.Contextual(defaultContext)
