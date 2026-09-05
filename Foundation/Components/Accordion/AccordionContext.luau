local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Types = require(Utility.Types)
local InputSize = require(Enums.InputSize)

type UsedAs<T> = Types.UsedAs<T>
type InputSize = InputSize.InputSize
type ItemId = Types.ItemId

export type onAccordionItemActivated = (id: ItemId, isExpanded: boolean?) -> (() -> ())?

export type AccordionContextType = {
	onAccordionItemActivated: onAccordionItemActivated?,
	itemSize: UsedAs<InputSize>,
}

local defaultContext: AccordionContextType = {
	onAccordionItemActivated = nil,
	itemSize = InputSize.Medium
}

return Fusion.Contextual(defaultContext)
