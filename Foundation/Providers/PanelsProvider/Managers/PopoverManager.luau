--[[
	NOTE: This manager is only usable within built-in plugins.
	It is only provided under Fusion Foundation to provide parity between the React and Fusion versions.
	Do not depend on this module. It may be removed or changed at any time.
]]

local HttpService = game:GetService("HttpService")

local Foundation = script.Parent.Parent.Parent.Parent
local StudioUri = require(Foundation.Utility.Plugin.StudioUri)
local Types = require(script.Parent.Parent.Types)

type StudioUri = StudioUri.StudioUri
type PanelPosition = Types.PanelPosition
type PanelHandle = Types.PanelHandle

local MAX_SIZE = 3000

local BASE_ZINDEX = 200

local function bindToClose(panel: PluginGui, onClose: () -> ())
	if panel:IsA("PluginGui") then
		panel:BindToClose(onClose)
	end
end

type Popover = {
	id: string,
	uri: StudioUri,
	panel: PluginGui,
	open: boolean,
	depth: number,
	parentPopoverId: string?,
	onClose: (() -> ())?,
}

local function isStrictDescendantOf(active: { [string]: Popover }, ancestor: Popover, descendant: Popover): boolean
	local pid = descendant.parentPopoverId
	while pid do
		if pid == ancestor.id then
			return true
		end
		local parent = active[pid]
		if not parent then
			break
		end
		pid = parent.parentPopoverId
	end
	return false
end

local PopoverManager = {}
PopoverManager.__index = PopoverManager

function PopoverManager.new(plugin: Plugin, uriScope: string?)
	local self = setmetatable({}, PopoverManager)
	self._uriScope = uriScope

	self._plugin = plugin
	self._panels = plugin:GetPluginComponent("Panels")
	self._pluginUri = StudioUri.wrap(plugin:GetUri())

	self._active = {} :: { [string]: Popover }
	self._pool = {} :: { [number]: { Popover } }

	return self
end

export type PopoverManager = typeof(PopoverManager.new(...))

function PopoverManager.openAtAsync(
	self: PopoverManager,
	config: PanelPosition & { targetWidgetUri: StudioUri },
	onClose: (() -> ())?,
	depth: number?,
	parentPopoverId: string?
): PanelHandle
	local resolvedDepth = if depth == nil then 0 else depth
	local popover = self:_acquirePanelAsync(onClose, resolvedDepth, parentPopoverId)

	popover.panel.Enabled = false

	self._panels:SetAttachmentAsync(popover.uri, {
		TargetWidgetUri = config.targetWidgetUri,
		TargetAnchorPoint = config.targetAnchorPoint,
		SubjectAnchorPoint = config.subjectAnchorPoint,
		Offset = config.offset,
	})
	self._panels:SetSizeAsync(popover.uri, Vector2.new(0, 0))

	popover.panel.Enabled = true
	popover.open = true

	local handle: PanelHandle = {
		container = popover.panel,
		popoverId = popover.id,
		setSizeAsync = function(size: Vector2)
			local width = math.ceil(math.min(MAX_SIZE, size.X))
			local height = math.ceil(math.min(MAX_SIZE, size.Y))
			self._panels:SetSizeAsync(popover.uri, Vector2.new(width, height))
		end,
		updateAsync = function(newConfig: PanelPosition & { targetWidgetUri: StudioUri })
			if not popover.uri then
				return
			end

			self._panels:SetAttachmentAsync(popover.uri, {
				TargetWidgetUri = newConfig.targetWidgetUri,
				TargetAnchorPoint = newConfig.targetAnchorPoint,
				SubjectAnchorPoint = newConfig.subjectAnchorPoint,
				Offset = newConfig.offset,
			})
		end,
		close = function()
			self:_closePopover(popover, true)
		end,
	}

	return handle
end

function PopoverManager._createPanelAsync(self: PopoverManager, id: string, depth: number): (PluginGui, StudioUri)
	local panel = self._plugin:CreateQWidgetPluginGui(id, {
		Id = id,
		InitialEnabled = true,
		Tooltip = true,
		Transparent = true,
		Resizable = true,
		Title = id,
		ZIndex = BASE_ZINDEX + depth,
	})
	panel.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	return panel, StudioUri.join(self._pluginUri, {
		Category = "Panels",
		ItemId = id,
	})
end

function PopoverManager._tryAcquireFromPool(
	self: PopoverManager,
	onClose: (() -> ())?,
	depth: number,
	parentPopoverId: string?
): Popover?
	local depthPool = self._pool[depth]
	local popover = if depthPool then table.remove(depthPool) else nil
	if not popover then
		return nil
	end

	popover.onClose = onClose
	popover.parentPopoverId = parentPopoverId
	popover.open = false
	self._active[popover.id] = popover
	return popover
end

function PopoverManager._acquirePanelAsync(
	self: PopoverManager,
	onClose: (() -> ())?,
	depth: number,
	parentPopoverId: string?
): Popover
	local pooled = self:_tryAcquireFromPool(onClose, depth, parentPopoverId)
	if pooled then
		return pooled
	end

	local uriScopeSegment = if self._uriScope then `/{self._uriScope}` else ""
	local id = `Popovers{uriScopeSegment}/{HttpService:GenerateGUID(false)}`

	local panel, uri = self:_createPanelAsync(id, depth)

	local newPopover: Popover = {
		id = id,
		uri = uri,
		panel = panel,
		open = false,
		depth = depth,
		parentPopoverId = parentPopoverId,
		onClose = onClose,
	}

	bindToClose(panel, function()
		self:_closePopover(newPopover)
	end)

	panel.InputBegan:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and newPopover.open then
			self:_closeChildPopovers(newPopover)
		end
	end)

	self._active[id] = newPopover
	return newPopover
end

function PopoverManager._closeChildPopovers(self: PopoverManager, parentPopover: Popover)
	local toClose = {}
	for _, popover in self._active do
		if popover.open and popover.id ~= parentPopover.id then
			local shouldClose = isStrictDescendantOf(self._active, parentPopover, popover)
			if shouldClose then
				table.insert(toClose, popover)
			end
		end
	end
	for _, popover in toClose do
		self:_closePopover(popover)
	end
end

function PopoverManager._closePopover(self: PopoverManager, popover: Popover, silent: boolean?)
	if not popover.open then
		return
	end

	popover.open = false
	popover.panel.Enabled = false

	if not silent and popover.onClose then
		popover.onClose()
	end

	self._active[popover.id] = nil

	local depth = popover.depth
	if not self._pool[depth] then
		self._pool[depth] = {}
	end
	table.insert(self._pool[depth], popover)
end

function PopoverManager.closeAll(self: PopoverManager)
	local toClose = {}
	for _, popover in self._active do
		table.insert(toClose, popover)
	end
	for _, popover in toClose do
		self:_closePopover(popover)
	end
end

function PopoverManager.destroy(self: PopoverManager)
	self:closeAll()

	for _, depthPool in self._pool do
		for _, popover in depthPool do
			if popover.panel then
				popover.panel:Destroy()
			end
		end
	end
	self._pool = {}
end

return PopoverManager
