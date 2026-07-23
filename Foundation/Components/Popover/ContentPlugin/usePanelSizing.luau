local Foundation = script.Parent.Parent.Parent.Parent

local Enums = Foundation.Enums
local Utility = Foundation.Utility

local positioning = require(script.Parent.Parent.positioning)

local unwrap = require(Utility.unwrap)
local isState = require(Utility.isState)
local Types = require(Utility.Types)

local PopoverSide = require(Enums.PopoverSide)
local PopoverAlign = require(Enums.PopoverAlign)

local ProviderTypes = require(Foundation.Providers.PanelsProvider.Types)
local Constants = require(Foundation.Constants)

local SHADOW_SIZE = Constants.SHADOW_SIZE

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type PopoverSide = PopoverSide.PopoverSide
type PopoverAlign = PopoverAlign.PopoverAlign

type PanelHandle = ProviderTypes.PanelHandle

type SideConfig = {
	position: PopoverSide,
	offset: number,
} | PopoverSide

type AlignConfig = {
	position: PopoverAlign,
	offset: number,
} | PopoverAlign

return function(
	scope: Scope,
	sideConfig: UsedAs<SideConfig>?,
	alignConfig: UsedAs<AlignConfig>?,
	contentState: UsedAs<GuiObject?>,
	arrowSize: UsedAs<number>?,
	panelState: UsedAs<PanelHandle?>?
): (UsedAs<UDim2>, UsedAs<UDim2>)
	local popoverSize = scope:Value(UDim2.new())
	local contentSize = scope:Value(UDim2.new())

	local setSizeTask: thread? = nil
	local currentConnection: RBXScriptConnection? = nil

	local function recalculatePosition()
		local content = unwrap(contentState)
		if not content then return end
		
		local contentAbsSize = content.AbsoluteSize

		local currentSideConfig = unwrap(sideConfig)
		local currentAlignConfig = unwrap(alignConfig)
		local currentArrowSize = unwrap(arrowSize)

		local side: PopoverSide = if type(currentSideConfig) == "table" then currentSideConfig.position else currentSideConfig
		local sideOffset = if type(currentSideConfig) == "table" then currentSideConfig.offset else 0
		local alignOffset: number = 0
		if type(currentAlignConfig) == "table" then
			alignOffset = currentAlignConfig.offset
		end

		local arrowOffset = currentArrowSize or 0

		local popoverBounds =
			positioning.calculatePopoverBounds(side, sideOffset, alignOffset, arrowOffset, contentAbsSize)
		local widgetSize = popoverBounds + Vector2.new(SHADOW_SIZE * 2, SHADOW_SIZE * 2)
		
		local newContentSize = UDim2.fromOffset(contentAbsSize.X, contentAbsSize.Y)
		local newPopoverSize = UDim2.fromOffset(widgetSize.X, widgetSize.Y)
		
		contentSize:set(newContentSize)
		popoverSize:set(newPopoverSize)
		
		-- Force update re-layout for quantum GUI to prevent jello effect
		local _ = content.AbsolutePosition

		local panel = if panelState then unwrap(panelState) else nil
		if panel then
			if setSizeTask then
				task.cancel(setSizeTask)
			end
			setSizeTask = task.spawn(function()
				panel.setSizeAsync(widgetSize)
			end)
		end
	end

	local function connectSignals(content: GuiObject?)
		recalculatePosition()
		if currentConnection then
			currentConnection:Disconnect()
			currentConnection = nil
		end
		if content then
			currentConnection = content:GetPropertyChangedSignal("AbsoluteSize"):Connect(recalculatePosition)
		end
	end

	if isState(contentState) then
		scope:Observer(contentState):onChange(function()
			connectSignals(unwrap(contentState))
		end)
	end

	if isState(panelState) then
		scope:Observer(panelState):onChange(recalculatePosition)
	end

	local configComputed = scope:Computed(function(use: Use)
		unwrap(sideConfig, use)
		unwrap(alignConfig, use)
		unwrap(arrowSize, use)
		return true
	end)
	
	scope:Observer(configComputed):onChange(recalculatePosition)

	connectSignals()
	table.insert(scope, function()
		if setSizeTask then
			task.cancel(setSizeTask)
		end
		if currentConnection then
			currentConnection:Disconnect()
		end
	end)

	return popoverSize, contentSize
end