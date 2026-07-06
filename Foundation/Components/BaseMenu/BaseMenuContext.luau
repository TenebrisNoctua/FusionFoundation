local Foundation = script.Parent.Parent.Parent

local Types = require(Foundation.Utility.Types)
local InputSize = require(Foundation.Enums.InputSize)

type UsedAs<T> = Types.UsedAs<T>
type ItemId = Types.ItemId
type OnItemActivated = Types.OnItemActivated
type InputSize = InputSize.InputSize

export type BaseMenuContextType = {
	onActivated: OnItemActivated?,
	onNestedLeafActivated: (() -> ())?,
	size: UsedAs<InputSize>,
	hasLeading: UsedAs<boolean>?,
	setHasLeading: (() -> ())?,
	hoverOpenPath: UsedAs<{ ItemId }>,
	hoverOpenAtDepth: ((depth: number, id: ItemId, immediate: boolean?) -> ())?,
	hoverCloseAtDepth: ((depth: number) -> ())?,
	hoverReset: (() -> ())?,
	depth: number,
}

return nil