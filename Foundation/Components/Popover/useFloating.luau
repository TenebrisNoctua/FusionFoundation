local Foundation = script.Parent.Parent.Parent
local Utility = Foundation.Utility

local positioning = require(script.Parent.positioning)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local PopoverAlign = require(Foundation.Enums.PopoverAlign)
local PopoverSide = require(Foundation.Enums.PopoverSide)

type Scope = Types.Scope
type UsedAs<T> = Types.UsedAs<T>
type Use = Types.Use

type PopoverSide = PopoverSide.PopoverSide
type PopoverAlign = PopoverAlign.PopoverAlign
type PopoverAnchor = Types.PopoverAnchor

export type SideConfig = {
	position: PopoverSide,
	offset: number,
} | PopoverSide

export type AlignConfig = {
	position: PopoverAlign,
	offset: number,
} | PopoverAlign

-- Binds native Roblox signal property observers using Fusion scope tracking
local function connectSignals(
	scope: Scope,
	instanceState: UsedAs<Instance?>,
	signalNames: { string },
	callback: () -> ()
)
	local connections = {}

	local function cleanup()
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end
		table.clear(connections)
	end

	local function setup()
		cleanup()
		local instance = unwrap(instanceState)
		if typeof(instance) == "Instance" then
			for _, signalName in ipairs(signalNames) do
				local signal = instance:GetPropertyChangedSignal(signalName)
				table.insert(connections, signal:Connect(callback))
			end
		end
	end

	if unwrap(instanceState) ~= instanceState then
		scope:Observer(instanceState):onChange(setup)
	end

	setup()
	table.insert(scope, cleanup)
end

local function useFloating(
	scope: Scope,
	isOpen: UsedAs<boolean>,
	anchor: UsedAs<PopoverAnchor?>,
	content: UsedAs<GuiObject?>,
	overlay: UsedAs<GuiBase2d?>,
	sideConfig: UsedAs<SideConfig>,
	alignConfig: UsedAs<AlignConfig>,
	arrowSize: UsedAs<number?>
)
	local position = scope:Value(Vector2.new())
	local isVisible = scope:Value(true)
	local contentSize = scope:Value(UDim2.new())
	local screenSize = scope:Value(Vector2.new())
	local arrowPosition = scope:Value(Vector2.new())
	local anchorPoint = scope:Value(Vector2.new(0, 0))

	local function recalculatePosition()
		local currentIsOpen = unwrap(isOpen)
		local currentAnchor = unwrap(anchor)
		local currentContent = unwrap(content)
		local currentOverlay = unwrap(overlay)

		if not currentIsOpen or not currentAnchor or not currentContent or not currentOverlay then
			isVisible:set(false)
			return
		end

		local currentSideConfig = unwrap(sideConfig)
		local currentAlignConfig = unwrap(alignConfig)
		local currentArrowSize = unwrap(arrowSize)

		local anchorPosition = currentAnchor.AbsolutePosition
		local anchorSize = currentAnchor.AbsoluteSize
		local internalContentSize = currentContent.AbsoluteSize
		local internalScreenSize = currentOverlay.AbsoluteSize
		local screenPosition = currentOverlay.AbsolutePosition

		local anchorRect = Rect.new(anchorPosition, anchorPosition + anchorSize)
		local screenRect = Rect.new(screenPosition, screenPosition + internalScreenSize)

		if not positioning.isOnScreen(anchorRect, screenRect) then
			isVisible:set(false)
			return
		end

		local side: PopoverSide = if type(currentSideConfig) == "table" then currentSideConfig.position else currentSideConfig
		local sideOffset = if type(currentSideConfig) == "table" then currentSideConfig.offset else 0
		local align: PopoverAlign = currentAlignConfig :: PopoverAlign
		local flipAlign: boolean = false
		local alignOffset: number = 0

		if type(currentAlignConfig) == "table" then
			align = currentAlignConfig.position
			alignOffset = currentAlignConfig.offset
		end

		local arrowOffset = currentArrowSize or 0
		local popoverSize = positioning.calculatePopoverBounds(side, sideOffset, alignOffset, arrowOffset, internalContentSize)

		side = positioning.calculateSide(side, anchorRect, screenRect, popoverSize)
		if flipAlign then
			align = positioning.calculateAlign(side, align, anchorRect, screenRect, popoverSize)
		end

		local calculatedPosition, calculatedArrowPosition, calculatedAnchorPoint = positioning.calculatePositions(
			side,
			sideOffset,
			align,
			alignOffset,
			anchorRect,
			screenRect,
			arrowOffset,
			internalContentSize
		)

		contentSize:set(UDim2.fromOffset(internalContentSize.X, internalContentSize.Y))
		screenSize:set(internalScreenSize)
		arrowPosition:set(calculatedArrowPosition + calculatedPosition)
		position:set(calculatedPosition)
		anchorPoint:set(calculatedAnchorPoint)
		isVisible:set(true)
		
		-- Force update re-layout for quantum GUI to prevent jello effect
		local _ = currentContent.AbsolutePosition
	end

	connectSignals(scope, anchor, { "AbsolutePosition", "AbsoluteSize" }, recalculatePosition)
	connectSignals(scope, content, { "AbsoluteSize" }, recalculatePosition)
	connectSignals(scope, overlay, { "AbsoluteSize" }, recalculatePosition)

	local configDependencies = scope:Computed(function(use: Use)
		return {
			isOpen = unwrap(isOpen, use),
			sideConfig = unwrap(sideConfig, use),
			alignConfig = unwrap(alignConfig, use),
			arrowSize = unwrap(arrowSize, use),
		}
	end)

	scope:Observer(configDependencies):onChange(recalculatePosition)

	recalculatePosition()
	return position, isVisible, contentSize, arrowPosition, screenSize, anchorPoint
end

return useFloating