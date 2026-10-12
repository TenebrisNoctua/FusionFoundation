local Foundation = script.Parent.Parent

local Utility = Foundation.Utility

local unwrap = require(Utility.unwrap)
local isState = require(Utility.isState)
local Types = require(Utility.Types)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local PreferencesProvider = require(Foundation.Providers.PreferencesProvider)

-- tokens.Ease.StandardOut is a cubic-bezier curve, which Fusion's native TweenInfo cannot consume directly
-- (it only accepts Enum.EasingStyle values). Enum.EasingStyle.Quad + Enum.EasingDirection.Out is used here
-- as the closest built-in approximation, the same way the Accordion item does.
local EASE_STYLE = Enum.EasingStyle.Quad
local EASE_DIRECTION = Enum.EasingDirection.Out

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type ItemId = Types.ItemId

export type ItemRefs = { [ItemId]: UsedAs<GuiObject?> }

-- Tracks the position, width and height of the active item relative to its container, and animates changes to them.
local function useAnimatedHighlight(scope: Scope, activeItemId: UsedAs<ItemId?>, containerRef: UsedAs<GuiObject?>, itemRefs: ItemRefs)
	local theme = ThemeProvider()
	local reducedMotion = PreferencesProvider().preferences.reducedMotion

	local tokens = unwrap(theme.Tokens)
	local easeInfo = TweenInfo.new(if reducedMotion then 0 else tokens.Time.Time_200, EASE_STYLE, EASE_DIRECTION)
	local instantInfo = TweenInfo.new(0)

	local tweenInfo = scope:Value(instantInfo)
	local positionGoal = scope:Value(0)
	local widthGoal = scope:Value(0)
	local activeItemHeight = scope:Value(0)

	local highlightPosition = scope:Tween(positionGoal, tweenInfo)
	local highlightWidth = scope:Tween(widthGoal, tweenInfo)

	local previousItemId = unwrap(activeItemId)
	-- Whether the highlight should jump to the item instead of animating to it. The same item being updated
	-- (e.g. its size changed) should not animate the first time around.
	local isSameItem = true
	local connections: { RBXScriptConnection } = {}

	local function disconnectAll()
		for _, connection in connections do
			connection:Disconnect()
		end
		table.clear(connections)
	end
	table.insert(scope, disconnectAll)

	local function getActiveItem(): GuiObject?
		local id = unwrap(activeItemId)
		if id == nil then return nil end
		local ref = itemRefs[id]
		return if ref then unwrap(ref) else nil
	end

	local function updateHighlight()
		local item = getActiveItem()
		local container = unwrap(containerRef)
		if not item or not container then return end

		local positionOffset = item.AbsolutePosition.X - container.AbsolutePosition.X
		local itemSize = item.AbsoluteSize.X

		-- The tween info must be changed before the goals are, so the goals use the right one.
		tweenInfo:set(if isSameItem then instantInfo else easeInfo)
		positionGoal:set(positionOffset)
		widthGoal:set(itemSize)
		activeItemHeight:set(item.AbsoluteSize.Y)
	end

	local function connect()
		disconnectAll()

		local item = getActiveItem()
		local container = unwrap(containerRef)
		if not item or not container then return end

		table.insert(connections, item:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateHighlight))
		table.insert(connections, item:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateHighlight))
		table.insert(connections, container:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateHighlight))
	end

	local function refresh()
		connect()
		updateHighlight()
	end

	local function onActiveItemChanged()
		local id = unwrap(activeItemId)
		isSameItem = id == previousItemId
		refresh()
		if id ~= nil then
			previousItemId = id
		end
	end

	if isState(activeItemId) then
		scope:Observer(activeItemId):onChange(onActiveItemChanged)
	end

	-- The instances may be created (or recreated) after this has been called.
	if isState(containerRef) then
		scope:Observer(containerRef):onChange(refresh)
	end
	for _, ref in itemRefs do
		if isState(ref) then
			scope:Observer(ref):onChange(refresh)
		end
	end

	refresh()

	return {
		activeItemHeight = activeItemHeight,
		highlightPosition = highlightPosition,
		highlightWidth = highlightWidth
	}
end

return useAnimatedHighlight
