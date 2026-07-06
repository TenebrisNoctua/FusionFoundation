local Foundation = script.Parent.Parent.Parent
local StudioUri = require(Foundation.Utility.Plugin.StudioUri)

local WidgetManager = require(script.Parent.WidgetManager)

type StudioUri = StudioUri.StudioUri

export type WidgetManager = WidgetManager.WidgetManager

export type WidgetsContext = {
	register: (uri: StudioUri, gui: GuiBase2d) -> (),
	deregister: (uri: StudioUri, gui: GuiBase2d?) -> (),
	nextId: () -> string,
}

export type WidgetsProvider = setmetatable<{
	widgetManager: WidgetManager?,
	register: (uri: StudioUri, gui: GuiBase2d) -> (),
	deregister: (uri: StudioUri, gui: GuiBase2d?) -> (),
	nextId: () -> string	
}, {__index: {}}>

return nil