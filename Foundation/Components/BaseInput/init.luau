local Foundation = script.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local View = require(Components.View)
local InputLabel = require(Components.InputLabel)

local useInputVariants = require(script.useInputVariants)
local useInputMotionStates = require(script.useInputMotionStates)

local unwrap = require(Utility.unwrap)
local stripProps = require(Utility.stripProps)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local getInputTextSize = require(Utility.getInputTextSize)
local Types = require(Utility.Types)

local ControlState = require(Enums.ControlState)
local InputSize = require(Enums.InputSize)
local StateLayerAffordance = require(Enums.StateLayerAffordance)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local Constants = require(Foundation.Constants)

local COMPONENT_ONLY_PROPERTIES = {
	"isChecked",
	"isIndeterminate",
	"isDisabled",
	"onActivated",
	"label",
	"size",
	"customVariantProps"
}

local defaultProps = {
	size = InputSize.Medium,
	Selectable = true
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type ControlState = ControlState.ControlState
type InputSize = InputSize.InputSize
type ColorStyleValue = Types.ColorStyleValue

export type InputColors = useInputMotionStates.InputColors

export type InputVariantProps = {
	tag: string,
	size: UDim2,
	cursorRadius: UDim?,
	colors: InputColors?,
	checkedStyle: ColorStyleValue?,
	stroke: {
		thickness: number?,
	}?,
}

type InputProps = {
	scope: Scope,
	isChecked: UsedAs<boolean>,
	isIndeterminate: UsedAs<boolean>?,
	isDisabled: UsedAs<boolean>?,
	onActivated: (boolean) -> (),
	label: {
		text: UsedAs<string>? | Instance?,
		position: UsedAs<Enum.HorizontalAlignment>?,
	},
	size: UsedAs<InputSize>?,
	customVariantProps: InputVariantProps,
} & Types.SelectionProps & Types.CommonProps

return function(inputProps: InputProps)
	local scope = inputProps.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the BaseInput component.")

	local props = withDefaults(inputProps, defaultProps)
	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local inputSize = unwrap(props.size, use)

		local label = unwrap(props.label.text, use)
		local labelPosition = unwrap(props.label.position, use) or Enum.HorizontalAlignment.Right
		local hasLabel = if typeof(label) == "string" then #label > 0 else label ~= nil

		local variantProps = useInputVariants(unwrap(theme.Theme), tokens, inputSize, labelPosition)

		local isHovering = innerScope:Value(false)

		local inputState = innerScope:Computed(function(use: Use)
			local filled = unwrap(props.isChecked, use) or unwrap(props.isIndeterminate, use)
			local hovering = unwrap(isHovering, use)
			if filled then
				return "Checked"
			elseif hovering then
				return "Hover"
			else
				return "Default"
			end
		end)

		local rawColors = props.customVariantProps.colors
		local unwrappedColors = rawColors
		if rawColors then
			unwrappedColors = {}
			for key, value in pairs(rawColors) do
				unwrappedColors[key] = unwrap(value, use)
			end
		end

		local motion = useInputMotionStates(
			innerScope,
			tokens,
			unwrappedColors,
			inputState
		)

		local cursor = {
			radius = props.customVariantProps.cursorRadius or UDim.new(0, 0),
			offset = tokens.Size.Size_200,
			borderWidth = tokens.Stroke.Thicker,
		}

		local function onInputStateChanged(newState: ControlState)
			isHovering:set(newState == ControlState.Hover)
		end

		local function onActivated()
			if unwrap(props.isDisabled) then return end
			local currentChecked = unwrap(props.isChecked)
			props.onActivated(not currentChecked)
		end

		local selectable = innerScope:Computed(function(use: Use)
			if unwrap(props.isDisabled, use) then
				return false
			end
			return unwrap(props.Selectable, use)
		end)

		local selectionProps = {
			Selectable = selectable,
			NextSelectionUp = props.NextSelectionUp,
			NextSelectionDown = props.NextSelectionDown,
			NextSelectionLeft = props.NextSelectionLeft,
			NextSelectionRight = props.NextSelectionRight,
		}

		local strokeThickness = if props.customVariantProps.stroke
				and props.customVariantProps.stroke.thickness ~= nil
			then props.customVariantProps.stroke.thickness
			else variantProps.input.stroke.thickness

		local backgroundStyle = innerScope:Computed(function(use: Use)
			return {
				Color3 = unwrap(motion.backgroundColor, use),
				Transparency = unwrap(motion.backgroundTransparency, use),
			}
		end)

		local strokeColor = innerScope:Computed(function(use: Use)
			return unwrap(motion.strokeColor, use)
		end)

		local strokeTransparency = innerScope:Computed(function(use: Use)
			local currentDisabled = unwrap(props.isDisabled, use)
			if currentDisabled and not hasLabel then
				return Constants.DISABLED_TRANSPARENCY
			end
			return unwrap(motion.strokeTransparency, use)
		end)

		local labelStyle = innerScope:Computed(function(use: Use)
			return {
				Color3 = unwrap(motion.labelColor, use),
				Transparency = unwrap(motion.labelTransparency, use),
			}
		end)

		local groupTransparency = innerScope:Computed(function(use: Use)
			return if unwrap(props.isDisabled, use) then Constants.DISABLED_TRANSPARENCY else 0
		end)

		if not hasLabel then
			local viewProps = withCommonProps(props, {
				scope = innerScope,
				tag = props.customVariantProps.tag,
				Size = props.customVariantProps.size - UDim2.fromOffset(strokeThickness, strokeThickness),
				backgroundStyle = backgroundStyle,
				onActivated = onActivated,
				onStateChanged = onInputStateChanged,
				stateLayer = { affordance = StateLayerAffordance.Background },
				stroke = {
					Color = strokeColor,
					Transparency = strokeTransparency,
					Thickness = strokeThickness,
					BorderStrokePosition = Enum.BorderStrokePosition.Inner,
				},
				selection = selectionProps,
				cursor = cursor,
				GroupTransparency = groupTransparency,
				isDisabled = props.isDisabled,
				children = props.children
			})

			return innerScope:Hydrate(View(viewProps))(stripProps(props, COMPONENT_ONLY_PROPERTIES))
		end

		-- With label: container View wraps Input View and InputLabel
		local inputViewProps = {
			scope = innerScope,
			tag = props.customVariantProps.tag,
			Size = props.customVariantProps.size - UDim2.fromOffset(strokeThickness, strokeThickness),
			backgroundStyle = backgroundStyle,
			onActivated = onActivated,
			stateLayer = { affordance = StateLayerAffordance.Background },
			stroke = {
				Color = strokeColor,
				Transparency = strokeTransparency,
				Thickness = strokeThickness,
				BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			},
			selection = selectionProps,
			cursor = cursor,
			LayoutOrder = if labelPosition == Enum.HorizontalAlignment.Left then 1 else -1,
			children = props.children,
		}

		local containerChildren = {
			Input = View(inputViewProps),
		}

		if typeof(label) == "string" then
			containerChildren.InputLabel = InputLabel {
				scope = innerScope,
				Text = label,
				textStyle = labelStyle,
				size = getInputTextSize(inputSize),
			}
		else
			containerChildren.InputLabel = label
		end

		local containerViewProps = withCommonProps(props, {
			scope = innerScope,
			tag = variantProps.container.tag,
			padding = {
				top = variantProps.container.padding,
				bottom = variantProps.container.padding,
				left = if labelPosition == Enum.HorizontalAlignment.Right then variantProps.container.padding else nil,
				right = if labelPosition == Enum.HorizontalAlignment.Left then variantProps.container.padding else nil,
			},
			GroupTransparency = groupTransparency,
			onActivated = onActivated,
			onStateChanged = onInputStateChanged,
			stateLayer = { affordance = StateLayerAffordance.None },
			selection = { Selectable = false },
			isDisabled = props.isDisabled,
			children = containerChildren
		})

		return innerScope:Hydrate(View(containerViewProps))(stripProps(props, COMPONENT_ONLY_PROPERTIES))
	end)
end