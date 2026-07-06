local Foundation = script.Parent.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Image = require(Foundation.Components.Image)
local View = require(Foundation.Components.View)

local useFloating = require(script.Parent.Parent.useFloating)

local isPointInGuiObjectBounds = require(Utility.isPointInGuiObjectBounds)
local usePointerPosition = require(Utility.usePointerPosition)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local PopoverAlign = require(Enums.PopoverAlign)
local PopoverSide = require(Enums.PopoverSide)
local Radius = require(Enums.Radius)
local StateLayerAffordance = require(Enums.StateLayerAffordance)
local ElevationLayer = require(Enums.ElevationLayer)
local ControlState = require(Enums.ControlState)

local useElevation = require(Foundation.Providers.ElevationProvider.useElevation)
local OverlayProvider = require(Foundation.Providers.OverlayProvider)
local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local Constants = require(Foundation.Constants)

local defaultProps = {
	side = PopoverSide.Bottom,
	align = PopoverAlign.Center,
	hasArrow = true,
	selection = Constants.MODAL.DISABLE_SELECTION,
	selectionGroup = Constants.MODAL.TRAP_FOCUS,
	radius = Radius.Medium,
}

local radiusToTag = {
	[Radius.Small] = "radius-small",
	[Radius.Medium] = "radius-medium",
	[Radius.Circle] = "radius-circle",
}

local SHADOW_IMAGE = Constants.SHADOW_IMAGE
local SHADOW_SIZE = Constants.SHADOW_SIZE
local SHADOW_VERTICAL_OFFSET = 2

local FoundationPopoverConditionalRender = true

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

type Selection = Types.Selection
type ControlState = ControlState.ControlState

type PopoverSide = PopoverSide.PopoverSide
type PopoverAlign = PopoverAlign.PopoverAlign
type Radius = Radius.Radius
type ElevationLayer = ElevationLayer.ElevationLayer

type SideConfig = useFloating.SideConfig
type AlignConfig = useFloating.AlignConfig

export type PopoverContentProps = {
	-- The scope the component will be created in.
	scope: Scope,
	-- The side the popover should be anchored to.
	side: UsedAs<SideConfig>?,
	-- The alignment of the popover relative to the anchor.
	align: UsedAs<AlignConfig>?,
	-- Whether the popover should have an arrow.
	hasArrow: UsedAs<boolean>?,
	-- Callback for when the backdrop is pressed. Does not swallow the press event.
	onPressedOutside: (() -> ())?,
	-- Selection behavior
	selection: UsedAs<Selection>?,
	selectionGroup: UsedAs<boolean> | UsedAs<Types.SelectionGroup>?,
	radius: UsedAs<(typeof(Radius.Small) | typeof(Radius.Medium) | typeof(Radius.Circle))>?,
	-- Context properties that were flattened into standard props
	isOpen: UsedAs<boolean>?,
	anchor: UsedAs<Instance?>?,
	gui: UsedAs<Instance?>?,
	children: {Child}?,
} & Types.CommonProps

--// Component Implementation

return function(contentProps: PopoverContentProps)
	local scope = contentProps.scope
	assert(scope, "A scope has not been provided for the PopoverContent component.")

	local props = withDefaults(contentProps, defaultProps)
	local theme = ThemeProvider()
	local overlay = OverlayProvider()

	local contentInstance = scope:Value(nil :: GuiObject?)
	local backdropInstance = scope:Value(nil :: GuiObject?)

	local pointerPosition = usePointerPosition(scope, backdropInstance)

	local elevation = useElevation(scope, ElevationLayer.Popover, { stackAboveOwner = true })

	local hasArrowActive = scope:Computed(function(use: Use)
		local currentAnchor = unwrap(props.anchor, use)
		local hasGuiObjectAnchor = typeof(currentAnchor) == "Instance"
		return if hasGuiObjectAnchor then unwrap(props.hasArrow, use) else false
	end)

	local activeArrowHeight = scope:Computed(function(use: Use)
		local tokens = unwrap(theme.Tokens, use)
		local arrowSide = tokens.Size.Size_200
		local arrowWidth = arrowSide * math.sqrt(2)
		local arrowHeight = arrowWidth / 2
		
		return if unwrap(hasArrowActive, use) then arrowHeight else 0
	end)

	local position, isVisible, contentSize, arrowPosition, screenSize, anchorPoint = useFloating(
		scope,
		props.isOpen,
		props.anchor,
		contentInstance,
		overlay,
		props.side,
		props.align,
		activeArrowHeight
	)

	if props.gui then
		scope:Observer(contentInstance):onChange(function()
			local currentView = unwrap(contentInstance)
			if typeof(props.gui) == "table" and (props.gui :: any).set then
				(props.gui :: any):set(currentView)
			end
		end)
	end

	return scope:Computed(function(use: Use, innerScope: Scope)
		local shouldRenderPopover = if FoundationPopoverConditionalRender then unwrap(props.isOpen, use) else true
		if not shouldRenderPopover then return end
		
		local tokens = unwrap(theme.Tokens, use)
		
		local arrowSide = tokens.Size.Size_200
		local arrowWidth = arrowSide * math.sqrt(2)
		local arrowHeight = arrowWidth / 2

		local currentAnchor = unwrap(props.anchor, use)
		local currentRadius = unwrap(props.radius, use)
		local currentVisible = unwrap(isVisible, use)

		local backgroundStyle = unwrap(props.backgroundStyle, use) or tokens.Color.Surface.Surface_100

		local shadowSizeMap = innerScope:Computed(function(use: Use)
			local size = unwrap(contentSize, use)
			return size + UDim2.fromOffset(SHADOW_SIZE, SHADOW_SIZE)
		end)

		local shadowPositionMap = innerScope:Computed(function(use: Use)
			local pos = unwrap(position, use)
			local anchor = unwrap(anchorPoint, use)
			local xShift = if anchor.X == 0 then -1 else 1
			local yShift = if anchor.Y == 0 then -1 else 1
			return UDim2.fromOffset(
				pos.X + SHADOW_SIZE / 2 * xShift,
				pos.Y + SHADOW_SIZE / 2 * yShift + SHADOW_VERTICAL_OFFSET
			)
		end)

		local containerProps = withCommonProps(props, {
			Parent = overlay,
			ZIndex = elevation.zIndex,
			tag = "size-full",
			Visible = currentVisible
		})

		return View {
			scope = innerScope,
			props = containerProps,
			children = {
				Backdrop = if props.onPressedOutside and unwrap(props.isOpen, use)
					then View {
						scope = innerScope,
						props = {
							ZIndex = 1,
							stateLayer = { affordance = StateLayerAffordance.None },
							Size = UDim2.fromScale(2, 2),
							tag = "position-center-center anchor-center-center",
							onStateChanged = function(newState: ControlState)
								if newState ~= ControlState.Pressed then return end
								if currentAnchor and typeof(currentAnchor) == "Instance" then
									local pointerPos = unwrap(pointerPosition)
									if isPointInGuiObjectBounds(currentAnchor, pointerPos) then return end
									if currentAnchor.GuiState ~= Enum.GuiState.Idle then return end
								end
								props.onPressedOutside()
							end
						}
					}
					else nil,

				Shadow = Image {
					scope = innerScope,
					AnchorPoint = anchorPoint,
					Image = SHADOW_IMAGE,
					Size = shadowSizeMap,
					Position = shadowPositionMap,
					ZIndex = 2,
					slice = {
						center = Rect.new(SHADOW_SIZE, SHADOW_SIZE, SHADOW_SIZE + 1, SHADOW_SIZE + 1),
					},
					imageStyle = tokens.Color.Extended.Black.Black_20
				},

				Arrow = if unwrap(hasArrowActive, use)
					then View {
						scope = innerScope,
						props = {
							Size = UDim2.fromOffset(arrowSide, arrowSide),
							Position = innerScope:Computed(function(use: Use)
								local arrowPos = unwrap(arrowPosition, use)
								return UDim2.fromOffset(arrowPos.X, arrowPos.Y)
							end),
							Rotation = 45,
							ZIndex = 3,
							backgroundStyle = backgroundStyle,
							tag = "anchor-center-center"
						}
					}
					else nil,

				Content = View {
					scope = innerScope,
					props = {
						AnchorPoint = anchorPoint,
						Position = innerScope:Computed(function(use: Use)
							local pos = unwrap(position, use)
							return UDim2.fromOffset(pos.X, pos.Y)
						end),
						selection = props.selection,
						selectionGroup = props.selectionGroup,
						sizeConstraint = {
							MaxSize = screenSize,
						},
						stateLayer = {
							affordance = StateLayerAffordance.None,
						},
						ZIndex = 4,
						onActivated = if props.onPressedOutside then function() end else nil,
						backgroundStyle = backgroundStyle,
						tag = `auto-xy {radiusToTag[currentRadius]}`
					},
					children = props.children
				}
			}
		}
	end)
end