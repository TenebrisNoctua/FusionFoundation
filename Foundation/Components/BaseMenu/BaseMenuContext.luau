local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Enums = Foundation.Enums

local Types = require(Foundation.Utility.Types)

local InputSize = require(Enums.InputSize)
type InputSize = InputSize.InputSize

type ItemId = Types.ItemId
type OnItemActivated = Types.OnItemActivated
type UsedAs<T> = Types.UsedAs<T>

export type BaseMenuContextType = {
	onActivated: OnItemActivated?,
	onNestedLeafActivated: (() -> ())?,
	size: UsedAs<InputSize>,
	hasLeading: UsedAs<boolean>,
	-- Centralized submenu state
	hoverOpenPath: UsedAs<{ ItemId }>,
	-- Depth-scoped derived state, prefer this over hoverOpenPath when an
	-- item only cares about whether its own depth is open.
	hoverOpenIdAtDepth: ((depth: number) -> UsedAs<ItemId?>)?,
	hoverOpenAtDepth: ((depth: number, id: ItemId, immediate: boolean?) -> ())?,
	hoverCloseAtDepth: ((depth: number) -> ())?,
	hoverReset: (() -> ())?,
	-- Current nesting depth (1-based, root menu items are at depth 1)
	depth: number,
	-- Maximum height after which submenus start scrolling. Inherited from the root menu.
	maxHeight: UsedAs<number?>?,
	-- Whether any item in the current content has a check mark
	menuHasCheck: UsedAs<boolean>,
	-- Whether the current group has a leading accessory (icon or leading)
	menuHasLeading: UsedAs<boolean>
}

return Fusion.Contextual(nil :: BaseMenuContextType?)
