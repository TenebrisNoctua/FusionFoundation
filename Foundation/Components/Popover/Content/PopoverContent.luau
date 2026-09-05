local Foundation = script.Parent.Parent.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums
local Providers = Foundation.Providers

local useFloating = require(script.Parent.Parent.useFloating)
local PopoverContext = require(script.Parent.Parent.PopoverContext)

local Image = require(Components.Image)
local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local isState = require(Utility.isState)
local withDefaults = require(Utility.withDefaults)
local usePointerPosition = require(Utility.usePointerPosition)
local isPointInGuiObjectBounds = require(Utility.isPointInGuiObjectBounds)
local Types = require(Utility.Types)

local Radius = require(Enums.Radius)
local PopoverSide = require(Enums.PopoverSide)
local PopoverAlign = require(Enums.PopoverAlign)
local ControlState = require(Enums.ControlState)
local ElevationLayer = require(Enums.ElevationLayer)
local StateLayerAffordance = require(Enums.StateLayerAffordance)

local useElevation = require(Providers.ElevationProvider.useElevation)
local OverlayProvider = require(Providers.OverlayProvider)
local ThemeProvider = require(Providers.ThemeProvider)

local Constants = require(Foundation.Constants)

local defaultProps = {
	side = PopoverSide.Bottom,
	align = PopoverAlign.Center,
	hasArrow = true,
	selection = Constants.MODAL.DISABLE_SELECTION,
	selectionGroup = Constants.MODAL.TRAP_FOCUS,
	radius = Radius.Medium
}

local radiusToTag = {
	[Radius.Small] = "radius-small",
	[Radius.Medium] = "radius-medium",
	[Radius.Circle] = "radius-circle",
}

local SHADOW_IMAGE = Constants.SHADOW_IMAGE
local SHADOW_SIZE = Constants.SHADOW_SIZE
local SHADOW_VERTICAL_OFFSET = 2

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
	children: {Child}?,
} & Types.CommonProps

--// Component Implementation

return function(contentProps: PopoverContentProps)
	local scope = contentProps.scope
	assert(scope, "A scope has not been provided for the PopoverContent component.")

	local context = PopoverContext:now()
	assert(context, "PopoverContent must be used within a Popover.Root")

	local props = withDefaults(contentProps, defaultProps)
	local theme = ThemeProvider()
	local overlay = OverlayProvider()

	local anchorState = context.anchor
	local guiState = context.gui
	local isOpenState = context.isOpen

	local contentInstance = scope:Value(nil :: GuiObject?)
	local backdropInstance = scope:Value(nil :: GuiObject?)

	local pointerComputed = usePointerPosition(scope, backdropInstance)

	local elevation = useElevation(scope, ElevationLayer.Popover, { stackAboveOwner = true })

	local hasArrowActive = scope:Computed(function(use: Use)
		local currentAnchor = unwrap(anchorState, use)
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
		isOpenState,
		anchorState,
		contentInstance,
		overlay.instance,
		props.side,
		props.align,
		activeArrowHeight
	)
	
	local backgroundStyleComputed = scope:Computed(function(use: Use)
		local tokens = unwrap(theme.Tokens, use)
		return unwrap(props.backgroundStyle, use) or tokens.Color.Surface.Surface_100
	end)

	local tagComputed = scope:Computed(function(use: Use)
		local currentRadius = unwrap(props.radius, use)
		return `auto-xy {radiusToTag[currentRadius]}`
	end)

	local finalParent = if overlay and overlay.instance then overlay.instance else nil
	local contentParentValue = scope:Value(nil)

	local contentView = View {
		Name = "ContentView",
		scope = scope,
		AnchorPoint = anchorPoint,
		Position = scope:Computed(function(use: Use)
			local pos = unwrap(position, use)
			return UDim2.fromOffset(pos.X, pos.Y)
		end),
		Visible = isVisible,
		Parent = contentParentValue,
		selection = props.selection,
		SelectionGroup = scope:Computed(function(use: Use)
			local sg = unwrap(props.selectionGroup, use)
			if sg == nil then return nil end
			if type(sg) == "boolean" then return sg end
			return true
		end),
		SelectionBehaviorUp = scope:Computed(function(use: Use)
			local sg = unwrap(props.selectionGroup, use)
			if sg == nil or type(sg) == "boolean" then return Enum.SelectionBehavior.Escape end
			return unwrap(sg.SelectionBehaviorUp, use)
		end),
		SelectionBehaviorDown = scope:Computed(function(use: Use)
			local sg = unwrap(props.selectionGroup, use)
			if sg == nil or type(sg) == "boolean" then return Enum.SelectionBehavior.Escape end
			return unwrap(sg.SelectionBehaviorDown, use)
		end),
		SelectionBehaviorLeft = scope:Computed(function(use: Use)
			local sg = unwrap(props.selectionGroup, use)
			if sg == nil or type(sg) == "boolean" then return Enum.SelectionBehavior.Escape end
			return unwrap(sg.SelectionBehaviorLeft, use)
		end),
		SelectionBehaviorRight = scope:Computed(function(use: Use)
			local sg = unwrap(props.selectionGroup, use)
			if sg == nil or type(sg) == "boolean" then return Enum.SelectionBehavior.Escape end
			return unwrap(sg.SelectionBehaviorRight, use)
		end),
		sizeConstraint = {
			MaxSize = screenSize,
		},
		stateLayer = {
			affordance = StateLayerAffordance.None,
		},
		ZIndex = scope:Computed(function(use) 
			local elevationProps = use(elevation)
			return elevationProps.zIndex
		end),
		onActivated = if props.onPressedOutside then function() end else nil,
		backgroundStyle = backgroundStyleComputed,
		tag = tagComputed,
		children = props.children
	}

	contentInstance:set(unwrap(contentView))

	if isState(guiState) then
		scope:Observer(contentInstance):onChange(function()
			local currentView = unwrap(contentInstance)
			guiState:set(currentView)
		end)
	end

	return scope:Computed(function(use: Use, innerScope: Scope)
		local shouldRenderPopover = unwrap(isOpenState, use)
		if not shouldRenderPopover then return end
		
		local tokens = unwrap(theme.Tokens, use)
		local arrowSide = tokens.Size.Size_200

		local currentAnchor = unwrap(anchorState, use)
		local bgStyle = unwrap(backgroundStyleComputed, use)

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
		
		local parentValue = innerScope:Value(nil)
		local content = if shouldRenderPopover then
			View {
				Name = "Content",
				scope = innerScope,
				ZIndex = elevation.zIndex,
				tag = "size-full",
				Visible = isVisible,
				Parent = parentValue,
				children = {
					Backdrop = if props.onPressedOutside and unwrap(isOpenState, use) then
					backdropInstance:set(View {
						Name = "Backdrop",
						scope = innerScope,
						ZIndex = 1,
						stateLayer = { affordance = StateLayerAffordance.None },
						Size = UDim2.fromScale(2, 2),
						tag = "position-center-center anchor-center-center",
						onStateChanged = function(newState: ControlState)
							if newState ~= ControlState.Pressed then return end
							if currentAnchor and typeof(currentAnchor) == "Instance" then
								local pointerPosition = unwrap(pointerComputed)
								local pointerPos = unwrap(pointerPosition)
								if isPointInGuiObjectBounds(currentAnchor, pointerPos) then return end
								if currentAnchor.GuiState ~= Enum.GuiState.Idle then return end
							end
							props.onPressedOutside()
						end
					})
					else nil,
					
					Shadow = Image {
						Name = "Shadow",
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
					
					Arrow = if unwrap(hasArrowActive, use) then 
						View {
							Name = "Arrow",
							scope = innerScope,
							Size = UDim2.fromOffset(arrowSide, arrowSide),
							Position = innerScope:Computed(function(use: Use)
								local arrowPos = unwrap(arrowPosition, use)
								return UDim2.fromOffset(arrowPos.X, arrowPos.Y)
							end),
							Rotation = 45,
							ZIndex = 3,
							backgroundStyle = bgStyle,
							tag = "anchor-center-center"
						}
					else nil,
				}
			}
			else nil
		
		if finalParent then
			task.defer(function()
				parentValue:set(finalParent)	
				contentParentValue:set(finalParent)
			end)
		end
		
		return content	
	end)
end