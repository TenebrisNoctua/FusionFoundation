local Foundation = script.Parent.Parent.Parent

local Utility = Foundation.Utility
local Enums = Foundation.Enums
local Components = Foundation.Components

local useSubmenuHover = require(script.Parent.useSubmenuHover)
local computeAutomaticSize = require(script.Parent.computeAutomaticSize)

local BaseMenuContext = require(script.Parent.BaseMenuContext)
local DeclarativeBaseMenuContent = require(script.Parent.DeclarativeBaseMenuContent)

local View = require(Components.View)
local ScrollView = require(Components.ScrollView)

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)

local Radius = require(Enums.Radius)
local InputSize = require(Enums.InputSize)
local ControlState = require(Enums.ControlState)

local defaultProps = {
	size = InputSize.Medium
}

local radiusToTag: { [Radius]: string } = {
	[Radius.Small] = "radius-small",
	[Radius.Medium] = "radius-medium"
}

local function computeSize(values: {
	autoSize: boolean,
	isOverMaxHeight: boolean,
	maxHeight: number?,
	width: UDim?,
}): UDim2?
	local y = if values.isOverMaxHeight and values.maxHeight then UDim.new(0, values.maxHeight) else UDim.new()
	return if values.autoSize then UDim2.new(UDim.new(), y) else UDim2.new(values.width or UDim.new(), y)
end

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

type ControlState = ControlState.ControlState
type Radius = Radius.Radius

type ItemId = Types.ItemId
type OnItemActivated = Types.OnItemActivated
type InputSize = InputSize.InputSize

export type BaseMenuItem = DeclarativeBaseMenuContent.BaseMenuItem
export type BaseMenuItems<Item = BaseMenuItem> = DeclarativeBaseMenuContent.BaseMenuItems<Item>
export type BaseMenuItemGroup<Item = BaseMenuItem> = DeclarativeBaseMenuContent.BaseMenuItemGroup<Item>

export type BaseMenuProps<Item = BaseMenuItem> = {
	-- The scope the BaseMenu component will be created in
	scope: Scope,
	-- List of items to display in the menu
	items: BaseMenuItems<Item>?,
	-- Size of the menu and its items
	size: UsedAs<InputSize>?,
	-- Width of the component. If not specified, the menu is sized based on the content.
	width: UsedAs<UDim?>,
	onActivated: OnItemActivated?,
	onNestedLeafActivated: (() -> ())?,
	-- Makes menu to use the provided width as a minimum width and use autosize instead to grow until the max width.
	-- If the provided width is bigger than the max width of the menu menu will have the width provided.
	-- If used with relative width, e.g. UDim.new(0.5, 0), the constraints always kick in.
	couldGrow: boolean?,
	children: Child?,
	-- Maximum height after which the menu starts scrolling
	maxHeight: UsedAs<number?>,
	-- Radius of the menu
	radius: UsedAs<Radius>?,
} & Types.CommonProps

local function BaseMenu(baseMenuProps: BaseMenuProps)
	local scope = baseMenuProps.scope
	assert(scope, "A scope has not been provided for the BaseMenu component.")

	local isVisible = scope:Value(true)

	local defaultWithVisible = table.clone(defaultProps)
	defaultWithVisible.Visible = isVisible

	local props = withDefaults(baseMenuProps, defaultWithVisible)
	local canvasSize = scope:Value(UDim2.fromScale(0, 1))
	local hasLeading = scope:Value(false)
	local submenuHover = useSubmenuHover(scope)

	local contextValue = {
		onActivated = props.onActivated,
		onNestedLeafActivated = props.onNestedLeafActivated,
		size = props.size,
		hasLeading = hasLeading,
		hoverOpenPath = submenuHover.openPath,
		hoverOpenIdAtDepth = submenuHover.openIdAtDepth,
		hoverOpenAtDepth = submenuHover.openAtDepth,
		hoverCloseAtDepth = submenuHover.closeAtDepth,
		hoverReset = submenuHover.reset,
		maxHeight = props.maxHeight,
		depth = 1
	}

	local function onContentAbsoluteSizeChanged(newSize: Vector2)
		canvasSize:set(UDim2.fromOffset(newSize.X, newSize.Y))
	end

	local useScrollView = scope:Computed(function(use)
		return unwrap(props.maxHeight, use) ~= nil
	end)

	local autoSizeValue = scope:Computed(function(use)
		local currentWidth = unwrap(props.width, use)
		local currentCouldGrow = unwrap(props.couldGrow, use)
		return not currentWidth or (currentCouldGrow == true)
	end)

	local sizeConstraint = scope:Computed(function(use)
		local currentWidth = unwrap(props.width, use)
		local autoSize = unwrap(autoSizeValue, use)
		if not autoSize then return nil end
		local minWidthValue = if currentWidth then currentWidth.Offset else 0
		if minWidthValue == 0 then return nil end
		return {
			MinSize = Vector2.new(minWidthValue, 0),
		}
	end)

	local contentAutomaticSize = scope:Computed(function(use)
		return if unwrap(autoSizeValue, use) then Enum.AutomaticSize.XY else Enum.AutomaticSize.Y
	end)

	local scrollAutomaticSize = scope:Computed(function(use)
		local autoSize = unwrap(autoSizeValue, use)
		local currentMaxHeight = unwrap(props.maxHeight, use)
		local currentCanvasSize = unwrap(canvasSize, use)
		local isOverMaxHeight = currentMaxHeight ~= nil and currentCanvasSize.Y.Offset > currentMaxHeight
		return computeAutomaticSize({
			autoSize = autoSize,
			isOverMaxHeight = isOverMaxHeight,
		})
	end)

	local scrollSize = scope:Computed(function(use)
		local autoSize = unwrap(autoSizeValue, use)
		local currentWidth = unwrap(props.width, use)
		local currentMaxHeight = unwrap(props.maxHeight, use)
		local currentCanvasSize = unwrap(canvasSize, use)
		local isOverMaxHeight = currentMaxHeight ~= nil and currentCanvasSize.Y.Offset > currentMaxHeight
		return computeSize {
			autoSize = autoSize,
			width = currentWidth,
			isOverMaxHeight = isOverMaxHeight,
			maxHeight = currentMaxHeight,
		}
	end)

	local viewSize = scope:Computed(function(use)
		local autoSize = unwrap(autoSizeValue, use)
		if autoSize then return UDim2.new() end
		local currentWidth = unwrap(props.width, use)
		return UDim2.new(currentWidth, UDim.new())
	end)

	return scope:Computed(function(use: Use, innerScope: Scope)
		local shouldUseScrollView = unwrap(useScrollView, use)
		local currentSizeConstraint = unwrap(sizeConstraint, use)
		local radius = unwrap(props.radius, use)
		local radiusTag = if radius ~= nil then radiusToTag[radius] or "" else ""

		local menuChildren = unwrap(props.children, use)

		if not menuChildren and props.items then
			menuChildren = {
				BaseMenuContext:is(contextValue):during(function()
					return DeclarativeBaseMenuContent {
						scope = innerScope,
						items = props.items,
					}
				end)
			}
		end

		if type(menuChildren) == "function" then
			menuChildren = BaseMenuContext:is(contextValue):during(function()
				return menuChildren(innerScope)
			end)
		end

		if shouldUseScrollView then
			return ScrollView(withCommonProps(props, {
				scope = innerScope,
				scroll = {
					AutomaticSize = scrollAutomaticSize,
					ScrollingDirection = Enum.ScrollingDirection.Y,
					CanvasSize = canvasSize,
				},
				AutomaticSize = scrollAutomaticSize,
				Size = scrollSize,
				sizeConstraint = currentSizeConstraint,
				tag = `stroke-standard stroke-default {radiusTag}`,
				children = {
					View {
						scope = innerScope,
						tag = "col size-full",
						Size = UDim2.fromScale(1, 0),
						AutomaticSize = contentAutomaticSize,
						onAbsoluteSizeChanged = onContentAbsoluteSizeChanged,
						children = menuChildren,
					}
				},
			}))
		else
			return View(withCommonProps(props, {
				scope = innerScope,
				tag = `col stroke-standard stroke-default {radiusTag}`,
				AutomaticSize = contentAutomaticSize,
				Size = viewSize,
				sizeConstraint = currentSizeConstraint,
				children = menuChildren
			}))
		end
	end)
end

return BaseMenu