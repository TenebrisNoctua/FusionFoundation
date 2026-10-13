local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useToggleVariants = require(script.useToggleVariants)

local BaseInput = require(Components.BaseInput)
local Knob = require(Components.Knob)

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)

local ColorNamespace = require(Enums.ColorNamespace)
local InputSize = require(Enums.InputSize)
local InputPlacement = require(Enums.InputPlacement)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local PresentationContext = require(Foundation.Providers.ThemeProvider.PresentationContext).Context

local Constants = require(Foundation.Constants)

-- The React version used an Otter spring with a frequency of 4 Hz (critically damped).
-- Fusion springs take an angular speed in radians per second, so the frequency is converted.
local SPRING_SPEED = 4 * 2 * math.pi
local SPRING_DAMPING = 1

local IS_INVERSE = { colorNamespace = ColorNamespace.Color }

local defaultProps = {
	size = InputSize.Medium,
	placement = InputPlacement.Start,
	Selectable = true,
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type InputSize = InputSize.InputSize
type InputPlacement = InputPlacement.InputPlacement

export type ToggleProps = {
	-- The scope the component will be created in.
	scope: Scope,
	-- Whether the toggle is currently checked (i.e. on). If it is left `nil`,
	-- the toggle will be considered uncontrolled.
	isChecked: UsedAs<boolean>?,
	-- Whether the toggle is disabled. When `true`, the `onActivated` callback
	-- will not be invoked, even if the user interacts with the toggle.
	isDisabled: UsedAs<boolean>?,
	-- A function that will be called whenever the toggle is activated.
	-- Returns the new value of the toggle when uncontrolled.
	onActivated: ((boolean) -> ())?,
	-- A label for the toggle. To omit, set it to an empty string.
	label: UsedAs<string>,
	size: UsedAs<InputSize>?,
	placement: UsedAs<InputPlacement>?,
} & Types.SelectionProps & Types.CommonProps

return function(toggleProps: ToggleProps)
	local scope = toggleProps.scope
	assert(scope, "A scope has not been provided for the Toggle component.")

	local theme = ThemeProvider()
	local props = withDefaults(toggleProps, defaultProps)

	local isChecked = scope:Value(unwrap(props.isChecked) or false)
	local externalIsChecked = scope:Computed(function(use: Use)
		return unwrap(props.isChecked, use)
	end)

	scope:Observer(externalIsChecked):onChange(function()
		local newValue = unwrap(externalIsChecked)
		if newValue ~= nil then
			isChecked:set(newValue)
		end
	end)

	local function onActivated(newValue: boolean)
		if unwrap(props.isChecked) == nil then
			isChecked:set(newValue)
		end
		if props.onActivated then
			props.onActivated(newValue)
		end
	end

	local progressGoal = scope:Computed(function(use: Use)
		return if use(isChecked) then 1 else 0
	end)
	local progress = scope:Spring(progressGoal, SPRING_SPEED, SPRING_DAMPING)

	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local size = unwrap(props.size, use)
		local placement = unwrap(props.placement, use)
		local isDisabled = unwrap(props.isDisabled, use) or false

		local variantProps = useToggleVariants(unwrap(theme.Theme, use), tokens, size)
		local knobSize: InputSize = if size == InputSize.Large then InputSize.Medium else size

		local knobPosition = innerScope:Computed(function(use: Use)
			return variantProps.knob.offPosition:Lerp(variantProps.knob.onPosition, use(progress))
		end)

		local knobIcon = innerScope:Computed(function(use: Use)
			if use(isChecked) then
				return {
					name = BuilderIcons.Icon.Check,
					variant = BuilderIcons.IconVariant.Regular,
				}
			end
			return nil
		end)

		return BaseInput(withCommonProps(props, {
			scope = innerScope,
			isChecked = isChecked,
			isDisabled = isDisabled,
			onActivated = onActivated,
			label = {
				text = props.label,
				position = Constants.INPUT_PLACEMENT_TO_LABEL_ALIGNMENT[placement],
			},
			customVariantProps = variantProps.input,
			size = size,
			Selectable = props.Selectable,
			NextSelectionUp = props.NextSelectionUp,
			NextSelectionDown = props.NextSelectionDown,
			NextSelectionLeft = props.NextSelectionLeft,
			NextSelectionRight = props.NextSelectionRight,
			children = function(childScope: Scope)
				local knob = PresentationContext:is(IS_INVERSE):during(function()
					return Knob {
						scope = childScope,
						size = knobSize,
						AnchorPoint = Vector2.new(0, 0.5),
						Position = knobPosition,
						hasShadow = false,
						icon = knobIcon,
					}
				end)
				return { Knob = knob }
			end
		}))
	end)
end
