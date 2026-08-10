local Foundation = script.Parent.Parent.Parent.Parent
local Utility = Foundation.Utility
local Components = Foundation.Components

local View = require(Components.View)
local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)
local StudioUri = require(Utility.Plugin.StudioUri)

local OverlayProvider = require(Foundation.Providers.OverlayProvider)
local useUniqueWidget = require(Foundation.Providers.WidgetsProvider.useUniqueWidget)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type StudioUri = StudioUri.StudioUri
type PopoverAnchor = Types.PopoverAnchor

export type PluginAnchor = {
	uri: UsedAs<StudioUri>,
	isVirtual: UsedAs<boolean>,
	isReady: UsedAs<boolean>,
}

-- When `uriAnchor` is provided the panel attaches to that widget directly, so
-- there is no instance to measure or register and `anchor` is expected to be nil.
return function(
	scope: Scope,
	anchor: UsedAs<PopoverAnchor?>?,
	uriAnchor: UsedAs<StudioUri?>?
): PluginAnchor
	local overlayProvider = OverlayProvider()

	local isVirtualAnchor = scope:Computed(function(use: Use)
		local currentAnchor = unwrap(anchor, use)
		return currentAnchor ~= nil and typeof(currentAnchor) ~= "Instance"
	end)

	-- For instance anchors, use the anchor directly as the widget gui
	local instanceAnchorGui = scope:Computed(function(use: Use)
		local currentAnchor = unwrap(anchor, use)
		local isVirtual = unwrap(isVirtualAnchor, use)
		if not isVirtual and typeof(currentAnchor) == "Instance" then
			return currentAnchor :: GuiBase2d?
		end
	end)

	-- For virtual anchors, track the View instance that will be created in the overlay
	local virtualAnchorGui = scope:Value(nil :: GuiBase2d?)

	local widgetGui = scope:Computed(function(use: Use)
		local isVirtual = unwrap(isVirtualAnchor, use)
		if isVirtual then
			return unwrap(virtualAnchorGui, use)
		end
		return unwrap(instanceAnchorGui, use)
	end)

	local anchorWidget = useUniqueWidget(scope, {
		gui = widgetGui,
	})

	local anchorPosition = scope:Value(Vector2.zero)
	local anchorSize = scope:Value(Vector2.one)
	local overlayOffset = scope:Value(Vector2.zero)

	local positionConnection: any? = nil
	local sizeConnection: any? = nil
	local offsetConnection: RBXScriptConnection? = nil

	local function setupVirtualAnchorConnections()
		if positionConnection then positionConnection:Disconnect() positionConnection = nil end
		if sizeConnection then sizeConnection:Disconnect() sizeConnection = nil end
		if offsetConnection then offsetConnection:Disconnect() offsetConnection = nil end

		local currentAnchor = unwrap(anchor)
		local isVirtual = unwrap(isVirtualAnchor)
		if not isVirtual or currentAnchor == nil then return end

		local measurableAnchor = currentAnchor :: any
		anchorPosition:set(measurableAnchor.AbsolutePosition)
		anchorSize:set(measurableAnchor.AbsoluteSize)

		positionConnection = measurableAnchor:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
			anchorPosition:set(measurableAnchor.AbsolutePosition)
		end)
		sizeConnection = measurableAnchor:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			anchorSize:set(measurableAnchor.AbsoluteSize)
		end)

		-- Track overlay offset
		local overlay = overlayProvider.instance
		if overlay and overlay:IsA("GuiObject") then
			overlayOffset:set(overlay.AbsolutePosition)
			offsetConnection = overlay:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
				overlayOffset:set(overlay.AbsolutePosition)
			end)
		else
			overlayOffset:set(Vector2.zero)
		end
	end

	scope:Observer(anchor):onChange(setupVirtualAnchorConnections)
	setupVirtualAnchorConnections()

	table.insert(scope, function()
		if positionConnection then positionConnection:Disconnect() end
		if sizeConnection then sizeConnection:Disconnect() end
		if offsetConnection then offsetConnection:Disconnect() end
	end)

	local virtualAnchorParent = scope:Value(nil :: Instance?)

	local function updateVirtualAnchorParent()
		local isVirtual = unwrap(isVirtualAnchor)
		if isVirtual and overlayProvider.instance then
			virtualAnchorParent:set(overlayProvider.instance)
		else
			virtualAnchorParent:set(nil)
		end
	end

	scope:Observer(isVirtualAnchor):onChange(updateVirtualAnchorParent)
	updateVirtualAnchorParent()

	local virtualAnchorView = View {
		Position = scope:Computed(function(use: Use)
			local pos = unwrap(anchorPosition, use)
			local offset = unwrap(overlayOffset, use)
			return UDim2.fromOffset(pos.X - offset.X, pos.Y - offset.Y)
		end),
		Size = scope:Computed(function(use: Use)
			local size = unwrap(anchorSize, use)
			return UDim2.fromOffset(size.X, size.Y)
		end),
		Visible = true,
		scope = scope,
		Parent = virtualAnchorParent,
	}

	virtualAnchorGui:set(unwrap(virtualAnchorView))

	-- If the View was not yet parented (e.g. overlay not ready), re-register
	-- the widget when it eventually gets parented to a LayerCollector.
	local viewInstance = unwrap(virtualAnchorView)
	if typeof(viewInstance) == "Instance" then
		local ancestryConnection
		ancestryConnection = viewInstance.AncestryChanged:Connect(function(_, parent)
			if parent and viewInstance:FindFirstAncestorWhichIsA("LayerCollector") then
				virtualAnchorGui:set(viewInstance :: GuiBase2d?)
				if ancestryConnection then
					ancestryConnection:Disconnect()
					ancestryConnection = nil
				end
			end
			if not parent and ancestryConnection then
				ancestryConnection:Disconnect()
				ancestryConnection = nil
			end
		end)
		table.insert(scope, function()
			if ancestryConnection then ancestryConnection:Disconnect() end
		end)
	end

	-- Determine URI: use uriAnchor if provided, otherwise use widget URI
	local uri = scope:Computed(function(use: Use)
		local uriVal = if uriAnchor then unwrap(uriAnchor, use) else nil
		if uriVal ~= nil then return uriVal end
		return unwrap(anchorWidget.uri, use)
	end)

	-- Determine isReady
	local isReady = scope:Computed(function(use: Use)
		local uriVal = if uriAnchor then unwrap(uriAnchor, use) else nil
		if uriVal ~= nil then return true end
		local currentAnchor = unwrap(anchor, use)
		if not currentAnchor then return false end
		local isVirtual = unwrap(isVirtualAnchor, use)
		if not isVirtual then return true end
		return overlayProvider.instance ~= nil
	end)

	return {
		uri = uri,
		isVirtual = isVirtualAnchor,
		isReady = isReady,
	}
end