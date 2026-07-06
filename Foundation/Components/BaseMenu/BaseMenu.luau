local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Utility = Foundation.Utility
local Enums = Foundation.Enums
local Components = Foundation.Components

local DeclarativeBaseMenuContent = require(script.Parent.DeclarativeBaseMenuContent)
local useSubmenuHover = require(script.Parent.useSubmenuHover)
local computeAutomaticSize = require(script.Parent.computeAutomaticSize)
local BaseMenuContext = require(script.Parent.BaseMenuContext)

local ScrollView = require(Components.ScrollView)
local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local useScaledValue = require(Utility.useScaledValue)
local withCommonProps = require(Utility.withCommonProps)
local withDefaults = require(Utility.withDefaults)
local Types = require(Utility.Types)

local ControlState = require(Enums.ControlState)
local Radius = require(Enums.Radius)
local InputSize = require(Enums.InputSize)

local COMPONENT_ONLY_PROPERTIES = {
	"size",
	"width",
	"scale",
	"isDisabled",
	"isLoading",
	"onActivated",
	"fillBehavior",
	"inputDelay",
	"isIconSize",
	"colorMode",
}

local defaultProps = {
	size = InputSize.Medium,
}

local radiusToTag: { [Radius]: string } = {
	[Radius.Small] = "radius-small",
	[Radius.Medium] = "radius-medium",
}

local MIN_WIDTH = 260
local MAX_WIDTH = 320

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
	size: InputSize?,
	-- Width of the component. If not specified, the menu is sized based on the content.
	width: UsedAs<UDim?>,
	onActivated: OnItemActivated?,
	onNestedLeafActivated: (() -> ())?,
	-- Makes menu to use the provided width as a minimum width and use autosize instead to grow until the max width.
	-- If the provided width is bigger than the max width of the menu menu will have the width provided.
	-- If used with relative width, e.g. UDim.new(0.5, 0), the constraints always kick in.
	couldGrow: boolean?,
	children: {Child},
	-- Maximum height after which the menu starts scrolling
	maxHeight: UsedAs<number?>,
	-- Radius of the menu
	radius: Radius?,
} & Types.CommonProps

local function BaseMenu(baseMenuProps: BaseMenuProps)
	local scope = baseMenuProps.scope
	assert(scope, "A scope has not been provided for the BaseMenu component.")

	local isVisible = scope:Value(false)
	task.delay(0, function()
		isVisible:set(true)
	end)

	local defaultWithVisible = table.clone(defaultProps)
	defaultWithVisible.Visible = isVisible

	local props = withDefaults(baseMenuProps, defaultWithVisible)
	local canvasSize = scope:Value(UDim2.fromScale(0, 1))
	local hasLeading = scope:Value(false)
	local submenuHover = useSubmenuHover(scope)

	local function setHasLeading()
		hasLeading:set(true)
	end

	local function onContentAbsoluteSizeChanged(frame: GuiObject)
		canvasSize:set(UDim2.fromOffset(frame.AbsoluteSize.X, frame.AbsoluteSize.Y))
	end

	return scope:Computed(function(use: Use, innerScope: Scope)
		local currentWidth = unwrap(props.width, use)
		local currentMaxHeight = unwrap(props.maxHeight, use)
		local currentCanvasSize = unwrap(canvasSize, use)
		local currentCouldGrow = unwrap(props.couldGrow, use)

		local scaledMinWidth = useScaledValue(MIN_WIDTH, use)
		local scaledMaxWidth = useScaledValue(MAX_WIDTH, use)

		local minWidthValue = if currentWidth then currentWidth.Offset else scaledMinWidth
		local autoSizeValue = not currentWidth or (currentCouldGrow and currentWidth.Offset < scaledMaxWidth)

		local sizeConstraint = {
			MinSize = if autoSizeValue then Vector2.new(minWidthValue, 0) else nil,
			MaxSize = if autoSizeValue then Vector2.new(scaledMaxWidth, math.huge) else nil,
		}

		local isOverMaxHeight = currentMaxHeight ~= nil and currentCanvasSize.Y.Offset > currentMaxHeight

		local menuChildren = props.children
		if not menuChildren and unwrap(props.items, use) then
			menuChildren = {
				DeclarativeBaseMenuContent {
					scope = innerScope,
					items = props.items,
				},
			}
		end

		local radiusTag = if props.radius ~= nil then radiusToTag[props.radius] or "" else ""

		local contextValue = {
			onActivated = props.onActivated,
			onNestedLeafActivated = props.onNestedLeafActivated,
			size = props.size,
			hasLeading = hasLeading,
			setHasLeading = setHasLeading,
			hoverOpenPath = submenuHover.openPath,
			hoverOpenAtDepth = submenuHover.openAtDepth,
			hoverCloseAtDepth = submenuHover.closeAtDepth,
			hoverReset = submenuHover.reset,
			depth = 1,
		}

		local wrappedChildren = {
			BaseMenuContext {
				scope = innerScope,
				value = contextValue,
				children = menuChildren,
			},
		}

		if currentMaxHeight then
			local automaticSize = computeAutomaticSize({
				autoSize = autoSizeValue,
				isOverMaxHeight = isOverMaxHeight,
			})

			return ScrollView(withCommonProps(props, {
				scope = innerScope,
				scroll = {
					AutomaticSize = automaticSize,
					ScrollingDirection = Enum.ScrollingDirection.Y,
					CanvasSize = canvasSize,
				},
				AutomaticSize = automaticSize,
				Size = computeSize {
					autoSize = autoSizeValue,
					width = currentWidth,
					isOverMaxHeight = isOverMaxHeight,
					maxHeight = currentMaxHeight,
				},
				sizeConstraint = sizeConstraint,
				tag = `stroke-standard stroke-default {radiusTag}`,
				children = {
					View {
						scope = innerScope,
						tag = "col size-full",
						onAbsoluteSizeChanged = onContentAbsoluteSizeChanged,
						children = wrappedChildren,
					}
				},
			}))
		else
			return View(withCommonProps(props, {
				scope = innerScope,
				tag = `col stroke-standard stroke-default {radiusTag}`,
				AutomaticSize = if autoSizeValue then Enum.AutomaticSize.XY else Enum.AutomaticSize.Y,
				Size = if autoSizeValue then nil else UDim2.new(currentWidth, UDim.new()),
				sizeConstraint = sizeConstraint,
				children = wrappedChildren,
			}))
		end
	end)
end

return BaseMenu