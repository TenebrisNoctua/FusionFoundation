local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Components = Foundation.Components
local Utility = Foundation.Utility

local computeAutomaticSize = require(script.Parent.computeAutomaticSize)

local ScrollView = require(Components.ScrollView)
local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

type SizeConstraint = Types.SizeConstraint
type Tags = Types.Tags
type CommonProps = Types.CommonProps

type ScrollViewProps = {
	sizeConstraint: SizeConstraint?,
	tag: Tags?,
	InputSink: UsedAs<any>?,
}

export type ScrollContainerProps = ScrollViewProps & CommonProps

export type BaseMenuScrollContainerProps = {
	scope: Scope,
	-- Resolved binding of the height after which the container starts scrolling.
	maxHeight: UsedAs<number?>,
	-- Whether the container auto-sizes its width. Defaults to true (content-sized width).
	autoSize: UsedAs<boolean>?,
	-- Fixed width used when `autoSize` is false.
	width: UsedAs<UDim?>?,
	-- Props forwarded to the underlying ScrollView.
	scrollViewProps: ScrollContainerProps,
	children: Child?
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

return function(props: BaseMenuScrollContainerProps)
	local scope = props.scope
	assert(scope, "A scope has not been provided for the BaseMenuScrollContainer component.")

	local canvasSize = scope:Value(UDim2.fromScale(0, 1))

	local function onContentAbsoluteSizeChanged(newSize: Vector2)
		canvasSize:set(UDim2.fromOffset(newSize.X, newSize.Y))
	end

	return scope:Computed(function(use: Use, innerScope: Scope)
		local currentMaxHeight = unwrap(props.maxHeight, use)
		local currentCanvasSize = unwrap(canvasSize, use)
		local currentAutoSize = unwrap(props.autoSize, use)
		if currentAutoSize == nil then currentAutoSize = true end
		local currentWidth = unwrap(props.width, use)

		local isOverMaxHeight = currentMaxHeight ~= nil and currentCanvasSize.Y.Offset > currentMaxHeight

		local automaticSize = computeAutomaticSize({
			autoSize = currentAutoSize,
			isOverMaxHeight = isOverMaxHeight,
		})

		local children = props.children
		if type(children) == "function" then
			children = children(innerScope)
		end

		return ScrollView(withCommonProps(props.scrollViewProps, {
			scope = innerScope,
			tag = props.scrollViewProps.tag,
			sizeConstraint = props.scrollViewProps.sizeConstraint,
			InputSink = props.scrollViewProps.InputSink,
			scroll = {
				AutomaticSize = automaticSize,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				CanvasSize = canvasSize,
			},
			AutomaticSize = automaticSize,
			Size = computeSize({
				autoSize = currentAutoSize,
				width = currentWidth,
				isOverMaxHeight = isOverMaxHeight,
				maxHeight = currentMaxHeight,
			}),
			children = {
				View {
					scope = innerScope,
					tag = "col size-full",
					Size = UDim2.fromScale(1, 0),
					AutomaticSize = if currentAutoSize then Enum.AutomaticSize.XY else Enum.AutomaticSize.Y,
					onAbsoluteSizeChanged = onContentAbsoluteSizeChanged,
					children = children,
				}
			}
		}))
	end)
end