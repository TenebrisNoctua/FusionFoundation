local Foundation = script.Parent.Parent.Parent

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local StudioUri = require(Utility.Plugin.StudioUri)

local PopoverSide = require(Enums.PopoverSide)
local PopoverAlign = require(Enums.PopoverAlign)

type StudioUri = StudioUri.StudioUri
type PopoverAlign = PopoverAlign.PopoverAlign
type PopoverSide = PopoverSide.PopoverSide

export type StudioSideConfig = {
	position: PopoverSide,
	offset: number,
} | PopoverSide

export type StudioAlignConfig = {
	position: PopoverAlign,
	offset: number,
} | PopoverAlign

export type PanelPosition = {
	targetAnchorPoint: Vector2,
	subjectAnchorPoint: Vector2,
	offset: Vector2,
}

export type PanelHandle = {
	container: PluginGui,
	popoverId: string,
	close: () -> (),
	setSizeAsync: (size: Vector2) -> (),
	updateAsync: (newConfig: PanelPosition & { targetWidgetUri: StudioUri }) -> (),
}

export type PanelsContext = {
	registerPopoverAsync: (
		anchorUri: StudioUri,
		position: PanelPosition,
		onClose: () -> (),
		depth: number?,
		parentPopoverId: string?
	) -> (PanelHandle, () -> ()),
}

return nil
