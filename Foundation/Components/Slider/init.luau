local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useSliderVariants = require(script.useSliderVariants)
local calculateSliderStepValue = require(script.calculateSliderStepValue)
local calculateSliderValueFromPosition = require(script.calculateSliderValueFromPosition)

local View = require(Components.View)
local Knob = require(Components.Knob)

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)

local Types = require(Utility.Types)
local InputMode = require(Utility.Input.InputMode)
local useLastInputMode = require(Utility.Input.useLastInputMode)

local InputSize = require(Enums.InputSize)
local Visibility = require(Enums.Visibility)
local ControlState = require(Enums.ControlState)
local SliderVariant = require(Enums.SliderVariant)
local ColorNamespace = require(Enums.ColorNamespace)
local StateLayerAffordance = require(Enums.StateLayerAffordance)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local PresentationContext = require(Foundation.Providers.ThemeProvider.PresentationContext)
local Constants = require(Foundation.Constants)

local OnEvent = Fusion.OnEvent

-- When observing the drag deltas this was a reasonably large value that would only
-- realistically be reached from directional input jumping back to the center. The
-- actual deltas are much smaller on average.
local MAX_DIRECTIONAL_INPUT_DRAG_DELTA = 0.01

local IS_INVERSE = { colorNamespace = ColorNamespace.Inverse, isIconSize = false }

local defaultProps = {
	range = NumberRange.new(0, 1),
	size = InputSize.Medium,
	width = UDim.new(1, 0),
	variant = SliderVariant.Standard,
	isDisabled = false,
	isContained = false,
	knobVisibility = Visibility.Auto
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

type InputSize = InputSize.InputSize
type Visibility = Visibility.Visibility
type SliderVariant = SliderVariant.SliderVariant
type ControlState = ControlState.ControlState

export type SliderProps = {
	-- The scope the component will be created in.
	scope: Scope,
	value: UsedAs<number>,
	range: UsedAs<NumberRange>?,

	size: UsedAs<InputSize>?,
	width: UsedAs<UDim>?,
	variant: UsedAs<SliderVariant>?,
	isDisabled: UsedAs<boolean>?,
	isContained: UsedAs<boolean>?,
	knobVisibility: UsedAs<Visibility>?,
	-- An optional custom knob to render instead of the default one.
	knob: UsedAs<Child>?,
	step: UsedAs<number>?,

	onValueChanged: ((newValue: number) -> ())?,
	onDragStarted: (() -> ())?,
	onDragEnded: (() -> ())?
} & Types.CommonProps

return function(sliderProps: SliderProps)
	local scope = sliderProps.scope
	assert(scope, "A scope has not been provided for the Slider component.")

	local theme = ThemeProvider()
	local props = withDefaults(sliderProps, defaultProps)

	local controlState = scope:Value(ControlState.Initialize :: ControlState)
	local isDragging = scope:Value(false)
	local isKnobVisible = scope:Value(false)
	local lastInputMode = useLastInputMode(scope)

	-- The fraction we seek to on DragStart; DragUDim2 deltas are anchored to it. 
	local dragStartFraction = 0
	-- Previous DragUDim2 scale, used to detect the engine resetting the drag origin when
	-- directional input changes direction.
	local lastDragUDim2 = 0

	local function currentRange(): NumberRange
		return unwrap(props.range) or NumberRange.new(0, 1)
	end

	local function clampedValue(): number
		local range = currentRange()
		return math.clamp(unwrap(props.value), range.Min, range.Max)
	end

	local function updateValue(newValue: number)
		if newValue == clampedValue() then return end
		if props.onValueChanged then
			props.onValueChanged(newValue)
		end
	end

	local function updateKnobVisibility()
		local visibility = unwrap(props.knobVisibility)
		if visibility == Visibility.None then
			isKnobVisible:set(false)
		elseif visibility == Visibility.Always then
			isKnobVisible:set(true)
		else
			local state = unwrap(controlState)
			isKnobVisible:set(
				unwrap(isDragging)
					or state == ControlState.Hover
					or state == ControlState.Selected
					or state == ControlState.Pressed
			)
		end
	end

	local dragDetector: UIDragDetector
	dragDetector = scope:New "UIDragDetector" {
		DragStyle = Enum.UIDragDetectorDragStyle.TranslateLine,
		DragAxis = Vector2.new(1, 0),
		ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomScale,
		DragRelativity = Enum.UIDragDetectorDragRelativity.Absolute,
		Enabled = scope:Computed(function(use: Use)
			return not unwrap(props.isDisabled, use)
		end),

		[OnEvent "DragStart"] = function(inputPosition: Vector2)
			isDragging:set(true)
			updateKnobVisibility()

			if props.onDragStarted then
				props.onDragStarted()
			end

			lastDragUDim2 = 0

			local range = currentRange()
			local rangeSpan = range.Max - range.Min

			if unwrap(lastInputMode) == InputMode.Directional then
				-- Directional input has no meaningful press position, so anchor to the
				-- current value and let DragUDim2 deltas adjust it from there.
				dragStartFraction = (clampedValue() - range.Min) / rangeSpan
				return
			end

			-- DragUDim2 only reports movement *after* the grab, so seek to the press point
			-- here and anchor subsequent drag deltas to this fraction.
			local hitbox = dragDetector.Parent :: GuiObject?
			local pressValue = if hitbox
				then calculateSliderValueFromPosition(inputPosition, hitbox, range)
				else range.Min

			dragStartFraction = (pressValue - range.Min) / rangeSpan

			local step = unwrap(props.step)
			updateValue(if step then calculateSliderStepValue(pressValue, step, range) else pressValue)
		end,

		[OnEvent "DragContinue"] = function()
			local range = currentRange()
			local rangeSpan = range.Max - range.Min
			local delta = dragDetector.DragUDim2.X.Scale

			if unwrap(lastInputMode) == InputMode.Directional then
				-- When using directional input (Gamepad/WASD/Arrow keys), the engine resets
				-- `position` when making significant directional changes (e.g. Right -> Left).
				-- Discard that jump by making sure the delta isn't too large, then
				-- incremental changes resume like normal.
				if math.abs(delta - lastDragUDim2) > MAX_DIRECTIONAL_INPUT_DRAG_DELTA then
					dragStartFraction = (clampedValue() - range.Min) / rangeSpan - delta
					lastDragUDim2 = delta
					return
				end

				lastDragUDim2 = delta
			end

			local fraction = math.clamp(dragStartFraction + delta, 0, 1)
			local newValue = range.Min + fraction * rangeSpan

			local step = unwrap(props.step)
			updateValue(if step then calculateSliderStepValue(newValue, step, range) else newValue)
		end,

		[OnEvent "DragEnd"] = function()
			isDragging:set(false)
			updateKnobVisibility()

			if props.onDragEnded then
				props.onDragEnded()
			end
		end,
	}

	dragDetector:AddConstraintFunction(1, function(proposedPosition: UDim2, proposedRotation: number)
		-- Keep the seeked fraction plus the drag delta within [0, 1] so the knob stops at
		-- the ends instead of over-dragging past them.
		local base = dragStartFraction
		local clampedDelta = math.clamp(proposedPosition.X.Scale, -base, 1 - base)
		return UDim2.fromScale(clampedDelta, 0), proposedRotation
	end)

	local function onStateChanged(newState: ControlState)
		controlState:set(newState)
		updateKnobVisibility()
	end

	updateKnobVisibility()

	local knobColor3Goal = scope:Value(Color3.new())
	local knobTransparencyGoal = scope:Value(1)
	local tweenInfo = scope:Computed(function(use: Use)
		return TweenInfo.new(
			if unwrap(isDragging, use) then 0.1 else 0.15,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)
	end)
	local knobColor3 = scope:Tween(knobColor3Goal, tweenInfo)
	local knobTransparency = scope:Tween(knobTransparencyGoal, tweenInfo)

	local variantProps = scope:Computed(function(use: Use)
		local tokens = unwrap(theme.Tokens, use)
		return useSliderVariants(unwrap(theme.Theme, use), tokens, unwrap(props.size, use), unwrap(props.variant, use))
	end)

	local valuePercent = scope:Computed(function(use: Use)
		local range = unwrap(props.range, use) or NumberRange.new(0, 1)
		local value = math.clamp(unwrap(props.value, use), range.Min, range.Max)
		return (value - range.Min) / (range.Max - range.Min)
	end)

	local knobAnchorPoint = scope:Computed(function(use: Use)
		if unwrap(props.isContained, use) then
			return Vector2.new(unwrap(valuePercent, use), 0.5)
		end
		return Vector2.new(0.5, 0.5)
	end)

	-- Keeps dragDetector.Enabled and the knob's tween goals in sync with reactive state,
	-- since they can't be driven by a returned prop the way the rest of the tree is.
	local function syncSideEffects()
		local knobVisible = unwrap(isKnobVisible)
		local dragging = unwrap(isDragging)
		local variant = unwrap(variantProps)
		local currentKnobStyle = if dragging and knobVisible
			then (variant.knob.dragStyle or variant.knob.style)
			else variant.knob.style
		knobColor3Goal:set(currentKnobStyle.Color3)
		knobTransparencyGoal:set(if knobVisible then currentKnobStyle.Transparency else 1)
	end

	scope:Observer(scope:Computed(function(use: Use)
		return {
			isDisabled = unwrap(props.isDisabled, use),
			knobVisible = unwrap(isKnobVisible, use),
			dragging = unwrap(isDragging, use),
			variant = unwrap(variantProps, use),
		}
	end)):onChange(syncSideEffects)
	syncSideEffects()

	-- Reacts only to whether a custom knob is *present*, not to per-drag values like
	-- anchor point or visibility. 
	local hasCustomKnob = scope:Computed(function(use: Use)
		return unwrap(props.knob, use) ~= nil
	end)

	local knobPosition = UDim2.fromScale(1, 0.5)

	local knobSlot = scope:Computed(function(use: Use, knobInnerScope: Scope)
		if unwrap(hasCustomKnob, use) then
			return View {
				scope = knobInnerScope,
				tag = "size-0-0 auto-xy",
				AnchorPoint = knobAnchorPoint,
				Position = knobPosition,
				Visible = isKnobVisible,
				-- Passed through via its own nested Computed rather than unwrapped once here,
				-- so the caller's own knob content can change without rebuilding this View.
				children = {knobInnerScope:Computed(function(use: Use)
					return unwrap(props.knob, use)
				end)}
			}
		end

		return PresentationContext.Context:is(IS_INVERSE):during(function()
			return Knob {
				scope = knobInnerScope,
				AnchorPoint = knobAnchorPoint,
				Position = knobPosition,
				size = props.size,
				style = knobInnerScope:Computed(function(use: Use)
					return {
						Color3 = unwrap(knobColor3, use),
						Transparency = unwrap(knobTransparency, use)
					}
				end),
				stroke = knobInnerScope:Computed(function(use2: Use)
					return unwrap(variantProps, use).knob.stroke
				end),
				hasShadow = knobInnerScope:Computed(function(use2: Use)
					return unwrap(variantProps, use).knob.hasShadow
				end)
			}
		end)
	end)

	local fillView = View {
		scope = scope,
		tag = scope:Computed(function(use: Use)
			return unwrap(variantProps, use).fill.tag
		end),
		Size = scope:Computed(function(use: Use)
			return UDim2.fromScale(unwrap(valuePercent, use), 1)
		end),
		children = { Knob = knobSlot }
	}

	local barView = View {
		scope = scope,
		tag = scope:Computed(function(use: Use)
			return unwrap(variantProps, use).bar.tag
		end),
		children = { Fill = fillView }
	}

	local viewProps = withCommonProps(props, {
		scope = scope,
		Size = scope:Computed(function(use: Use)
			local width = unwrap(props.width, use)
			local height = unwrap(variantProps, use).hitbox.height
			return UDim2.new(width, UDim.new(0, height))
		end),
		GroupTransparency = scope:Computed(function(use: Use)
			return if unwrap(props.isDisabled, use) then Constants.DISABLED_TRANSPARENCY else nil
		end),
		stateLayer = {
			affordance = StateLayerAffordance.None
		},
		onStateChanged = onStateChanged,
		isDisabled = props.isDisabled,
		children = {
			DragDetector = dragDetector,
			Bar = barView
		}
	})

	return View(viewProps)
end
