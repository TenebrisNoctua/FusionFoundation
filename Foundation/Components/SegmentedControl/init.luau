local Foundation = script.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Segment = require(script.Segment)
local useSegmentedControlVariants = require(script.useSegmentedControlVariants)

local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local useAnimatedHighlight = require(Utility.useAnimatedHighlight)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local defaultProps = {
	size = InputSize.Medium,
	isCircular = false,
	ZIndex = 1
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type InputSize = InputSize.InputSize
type Segment = Segment.Segment

export type SegmentedControlProps = {
	-- The scope the component will be created in.
	scope: Scope,
	segments: UsedAs<{ Segment }>,
	-- The current selected segment.
	value: UsedAs<Types.ItemId>,
	onActivated: (id: Types.ItemId) -> (),
	size: UsedAs<InputSize>?,
	-- When true, the container and segments use a fully circular radius
	isCircular: UsedAs<boolean>?,
} & Types.CommonProps

return function(segmentedControlProps: SegmentedControlProps)
	local scope = segmentedControlProps.scope
	assert(scope, "A scope has not been provided for the SegmentedControl component.")

	local theme = ThemeProvider()
	local props = withDefaults(segmentedControlProps, defaultProps)

	local hiddenContainerSize = scope:Value(Vector2.new(0, 0))

	local variantProps = scope:Computed(function(use: Use)
		return useSegmentedControlVariants(unwrap(theme.Theme, use), unwrap(theme.Tokens, use), unwrap(props.size, use), unwrap(props.isCircular, use))
	end)

	local function onAbsoluteSizeChanged(newSize: Vector2)
		if props.onAbsoluteSizeChanged then
			props.onAbsoluteSizeChanged(newSize)
		end
		hiddenContainerSize:set(newSize)
	end

	return scope:Computed(function(use: Use, innerScope: Scope)
		local segments = unwrap(props.segments, use)

		-- Each Segment returns a state holding its GuiObject, used in place of the React refs.
		local segmentRefs: { [Types.ItemId]: UsedAs<GuiObject?> } = {}
		local segmentChildren = {}

		for index, segment in segments do
			local segmentOrder = (index - 1) * 2 + 1
			local segmentView = Segment {
				scope = innerScope,
				id = segment.id,
				size = props.size,
				isCircular = props.isCircular,
				text = segment.text,
				icon = segment.icon,
				ref = segment.ref,
				isActive = innerScope:Computed(function(use: Use)
					return segment.id == unwrap(props.value, use)
				end),
				onActivated = props.onActivated,
				LayoutOrder = segmentOrder
			}

			segmentRefs[segment.id] = segmentView
			segmentChildren[tostring(segment.id)] = segmentView
		end

		local segmentsContainer = View {
			scope = innerScope,
			tag = innerScope:Computed(function(use: Use)
				return unwrap(variantProps, use).container.tag
			end),
			onAbsoluteSizeChanged = onAbsoluteSizeChanged,
			children = segmentChildren
		}

		local overlayData = useAnimatedHighlight(innerScope, props.value, segmentsContainer, segmentRefs)

		-- Segments are slightly inset from the container; this value is needed to properly position the
		-- animated overlay.
		local function computeSegmentYInset(): number
			local container = unwrap(segmentsContainer)
			local activeTab = segmentRefs[unwrap(props.value)]
			local activeTabInstance = if activeTab then unwrap(activeTab) else nil
			if container and activeTabInstance then
				return activeTabInstance.AbsolutePosition.Y - container.AbsolutePosition.Y
			end
			return 0
		end

		local overlay = View {
			scope = innerScope,
			backgroundStyle = innerScope:Computed(function(use: Use)
				return unwrap(theme.Tokens, use).Color.Shift.Shift_400
			end),
			tag = innerScope:Computed(function(use: Use)
				return unwrap(variantProps, use).segment.tag
			end),
			Size = innerScope:Computed(function(use: Use)
				return UDim2.fromOffset(unwrap(overlayData.highlightWidth, use), unwrap(overlayData.activeItemHeight, use))
			end),
			Position = innerScope:Computed(function(use: Use)
				return UDim2.fromOffset(unwrap(overlayData.highlightPosition, use), computeSegmentYInset())
			end),
			ZIndex = innerScope:Computed(function(use: Use)
				return (unwrap(props.ZIndex, use) or 1) + 1
			end)
		}

		local viewProps = withCommonProps(props, {
			scope = innerScope,
			Size = innerScope:Computed(function(use: Use)
				local size = unwrap(hiddenContainerSize, use)
				return UDim2.fromOffset(size.X, size.Y)
			end),
			children = {
				SegmentsContainer = segmentsContainer,
				Overlay = overlay
			}
		})

		return View(viewProps)
	end)
end
