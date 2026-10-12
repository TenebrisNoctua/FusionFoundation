local Foundation = script.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local NumberInputControls = require(script.NumberInputControls)
local useNumberInputVariants = require(script.useNumberInputVariants)
local calculateNumberInputValueFromPositions = require(script.calculateNumberInputValueFromPositions)
local useTextInputVariants = require(Components.TextInput.useTextInputVariants)

local Icon = require(Components.Icon)
local Text = require(Components.Text)
local View = require(Components.View)
local InputField = require(Components.InputField)
local BaseTextInput = require(Components.BaseTextInput)

local unwrap = require(Utility.unwrap)
local isState = require(Utility.isState)
local useIconSize = require(Utility.useIconSize)
local useTextSize = require(Utility.useTextSize)
local isBuilderIcon = require(Utility.isBuilderIcon)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local getInputTextSize = require(Utility.getInputTextSize)
local getMultiLineTextHeight = require(Utility.getMultiLineTextHeight)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)
local InputVariant = require(Enums.InputVariant)
local ScrubBehavior = require(Enums.ScrubBehavior)
local InputFocusBehavior = require(Enums.InputFocusBehavior)
local OnChangeCallbackReason = require(Enums.OnChangeCallbackReason)
local NumberInputControlsVariant = require(Enums.NumberInputControlsVariant)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local Constants = require(Foundation.Constants)

local function round(num: number, numDecimalPlaces: number?)
	local mult = 10 ^ (numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

local function defaultFormatAsString(value: number)
	return tostring(value)
end

local scrubBehaviorToSensitivity: { [string]: number } = {
	[ScrubBehavior.On] = 1,
	[ScrubBehavior.Off] = 0,
}

local defaultProps = {
	variant = InputVariant.Standard,
	size = InputSize.Large,
	minimum = -math.huge,
	maximum = math.huge,
	step = 1,
	precision = 3,
	value = 0,
	formatAsString = defaultFormatAsString,
	isScrubbable = false,
	scrubBehavior = ScrubBehavior.Off,
	hasControls = false,
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type InputSize = InputSize.InputSize
type InputVariant = InputVariant.InputVariant
type ScrubBehavior = ScrubBehavior.ScrubBehavior
type InputFocusBehavior = InputFocusBehavior.InputFocusBehavior
type OnChangeCallbackReason = OnChangeCallbackReason.OnChangeCallbackReason
type NumberInputControlsVariant = NumberInputControlsVariant.NumberInputControlsVariant
type InternalTextInputRef = Types.InternalTextInputRef

export type NumberInputRef = Types.TextInputRef

export type NumberInputProps = {
	-- The scope the component will be created in.
	scope: Scope,
	-- Input number value
	value: UsedAs<number>?,
	-- **DEPRECATED** Variant of controls to use
	controlsVariant: UsedAs<NumberInputControlsVariant>?,
	-- Whether the input shows an error state. Always shows while true, if false then invalid input will still render an error state.
	hasError: UsedAs<boolean>?,
	-- Style variant of the input
	variant: UsedAs<InputVariant>?,
	-- Size of the number input
	size: UsedAs<InputSize>?,
	-- Whether the input is disabled
	isDisabled: UsedAs<boolean>?,
	-- Whether the input is required, true for "*", false for " (optional)", nil for nothing
	isRequired: boolean?,
	-- The callback that processes the new value
	onChanged: (number: number, reason: OnChangeCallbackReason) -> (),
	-- The callback that fires when text is inputted into the value.
	-- This is used in rare scenarios such as mathematical expressions (letting people type `1 + 2`),
	-- and `onChanged` is virtually always what you want.
	onTextChanged: ((value: string) -> ())?,
	-- Input label text. To omit, set to an empty string
	label: UsedAs<string>,
	-- Hint text below the input, is red on error
	hint: UsedAs<string>?,
	-- Width of the component
	width: UsedAs<UDim>?,
	-- Image before the input
	leadingIcon: UsedAs<string>?,
	-- Icon after the input
	trailingIcon: UsedAs<string>?,
	-- The prefix to display before the input (e.g. $ or €)
	prefix: UsedAs<string>?,
	-- The suffix to display after the input (e.g. % or px)
	suffix: UsedAs<string>?,
	-- Value that will be added/subtracted every time you press increment/decrement controls
	step: UsedAs<number>?,
	-- Maximum value input may reach via increment
	maximum: UsedAs<number>?,
	-- Minimum value input may reach via decrement
	minimum: UsedAs<number>?,
	-- Precision that will be used to display a value. Value will be rounded to the nearest value. With the precision being 3 0.0001 will be rounded to 0, 0.0006 to 0.001
	precision: UsedAs<number>?,
	-- Callback to format the value when input is not focused
	formatAsString: ((value: number) -> string)?,
	-- Whether the input can be dragged to change the value. A number sets the scrub sensitivity.
	-- **DEPRECATED** Use scrubBehavior instead
	isScrubbable: UsedAs<boolean>?,
	-- Controls scrub (drag-to-change) behavior
	scrubBehavior: UsedAs<ScrubBehavior>?,
	-- Behavior of the text input when focused. Mobile does not yet support Highlight behavior.
	focusBehavior: UsedAs<InputFocusBehavior>?,
	-- Whether the input renders increment/decrement controls
	hasControls: UsedAs<boolean>?,
	-- Partial TextBox ref exposed via imperative handle. If given a state, it is set once the text box is available.
	textBoxRef: UsedAs<NumberInputRef?>?,
	onFocusGained: (() -> ())?,
	-- Called when focus is lost. The InputObject that caused focus to be lost is passed if available.
	onFocusLost: ((inputObject: InputObject?) -> ())?,
	onReturnPressed: (() -> ())?,
} & Types.SelectionProps & Types.CommonProps

return function(numberInputProps: NumberInputProps)
	local scope = numberInputProps.scope
	assert(scope, "A scope has not been provided for the NumberInput component.")

	local theme = ThemeProvider()
	local props = withDefaults(numberInputProps, defaultProps)

	-- Set once InputField constructs the input. Replaces `internalTextBoxRef` (React.useRef).
	local internalTextBoxRef: UsedAs<InternalTextInputRef?>? = nil
	-- Replaces `dragStartTable` (React.useRef)
	local dragStartTable: { position: number, value: number }? = nil

	local hasInvalidInput = scope:Value(false)
	local hasError = scope:Computed(function(use: Use)
		return unwrap(props.hasError, use) == true or unwrap(hasInvalidInput, use)
	end)

	local function isFocused(): boolean
		local ref = if internalTextBoxRef then unwrap(internalTextBoxRef) else nil
		return if ref then ref.getIsFocused() == true else false
	end

	local function getScrubBehavior(use: Use?): ScrubBehavior
		if unwrap(props.isScrubbable, use) then
			return ScrubBehavior.On
		end
		return unwrap(props.scrubBehavior, use) or ScrubBehavior.Off
	end

	local function clampValueToRange(value: number, use: Use?): number
		return math.clamp(value, unwrap(props.minimum, use), unwrap(props.maximum, use))
	end

	local function constrainValue(value: number, use: Use?): number
		return round(clampValueToRange(value, use), unwrap(props.precision, use))
	end

	local function snapToStep(value: number, roundFunction: (number) -> number, use: Use?): number
		local step = unwrap(props.step, use)
		return roundFunction(value / step) * step
	end

	local textInput = scope:Value(props.formatAsString(constrainValue(unwrap(props.value))))

	local upValue = scope:Computed(function(use: Use)
		local value = unwrap(props.value, use)
		local precision = unwrap(props.precision, use)

		local roundedValue = round(value, precision)
		local newUpValue = round(value + unwrap(props.step, use), precision)
		local snapUpValue = round(snapToStep(value, math.ceil, use), precision)
		if roundedValue ~= snapUpValue then
			newUpValue = snapUpValue
		end
		return clampValueToRange(newUpValue, use)
	end)

	local downValue = scope:Computed(function(use: Use)
		local value = unwrap(props.value, use)
		local precision = unwrap(props.precision, use)

		local roundedValue = round(value, precision)
		local newDownValue = round(value - unwrap(props.step, use), precision)
		local snapDownValue = round(snapToStep(value, math.floor, use), precision)
		if roundedValue ~= snapDownValue then
			newDownValue = snapDownValue
		end
		return clampValueToRange(newDownValue, use)
	end)

	local isUpDisabled = scope:Computed(function(use: Use)
		return unwrap(props.isDisabled, use) == true or unwrap(props.value, use) == unwrap(props.maximum, use)
	end)

	local isDownDisabled = scope:Computed(function(use: Use)
		return unwrap(props.isDisabled, use) == true or unwrap(props.value, use) == unwrap(props.minimum, use)
	end)

	-- The text shown in the text box: what's being typed while focused, the formatted value otherwise.
	local displayText = scope:Computed(function(use: Use)
		local text = unwrap(textInput, use)
		local value = unwrap(props.value, use)
		if isFocused() then
			return text
		end
		return props.formatAsString(constrainValue(value, use))
	end)

	local function valueChanged(value: number, reason: OnChangeCallbackReason)
		value = constrainValue(value)
		textInput:set(if isFocused() then tostring(value) else props.formatAsString(value))
		props.onChanged(value, reason)
	end

	local function onFocus()
		textInput:set(tostring(unwrap(props.value)))

		if props.onFocusGained then
			props.onFocusGained()
		end
	end

	local function onFocusLost(inputObject: InputObject?)
		hasInvalidInput:set(false)
		valueChanged(unwrap(props.value), OnChangeCallbackReason.FocusLost)

		if props.onFocusLost then
			props.onFocusLost(inputObject)
		end
	end

	local function onTextChanged(text: string)
		textInput:set(text)
		if not isFocused() then
			return
		end

		local n = tonumber(text)

		if props.onTextChanged ~= nil then
			props.onTextChanged(text)
		elseif n == nil then
			hasInvalidInput:set(true)
			return
		end

		if n ~= nil then
			hasInvalidInput:set(false)
			props.onChanged(n, OnChangeCallbackReason.Keyboard)
		end
	end

	local function onIncrement()
		if unwrap(isUpDisabled) then
			return
		end
		valueChanged(unwrap(upValue), OnChangeCallbackReason.Activate)
	end

	local function onDecrement()
		if unwrap(isDownDisabled) then
			return
		end
		valueChanged(unwrap(downValue), OnChangeCallbackReason.Activate)
	end

	local function onDragStarted(position: Vector2)
		dragStartTable = {
			position = position.X,
			value = unwrap(props.value),
		}
	end

	local function onDrag(position: Vector2)
		if not dragStartTable then return end

		local newValue = calculateNumberInputValueFromPositions(
			dragStartTable.value,
			dragStartTable.position,
			position.X,
			unwrap(props.step),
			scrubBehaviorToSensitivity[getScrubBehavior()]
		)
		valueChanged(newValue, OnChangeCallbackReason.Drag)
	end

	local function onDragEnded()
		dragStartTable = nil
	end

	-- Keeps the text in sync when the value is changed from the outside while the input is not focused.
	if isState(props.value) then
		scope:Observer(props.value):onChange(function()
			if not isFocused() then
				textInput:set(props.formatAsString(constrainValue(unwrap(props.value))))
			end
		end)
	end

	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local themeName = unwrap(theme.Theme, use)
		local inputSize = unwrap(props.size, use)
		local inputVariant = unwrap(props.variant, use)

		local variantProps = useTextInputVariants(themeName, tokens, inputSize, inputVariant, nil, false, false)
		local numberInputVariantProps = useNumberInputVariants(themeName, tokens, inputSize)
		local controlsProps = numberInputVariantProps.controls

		local isScrubbable = getScrubBehavior(use) ~= ScrubBehavior.Off

		local incrementButtonsGap = if inputSize == InputSize.XSmall
			then tokens.Gap.Small - (tokens.Gap.XSmall / 2)
			else tokens.Gap.Small

		local controlsVariant = unwrap(props.controlsVariant, use)
		local hasControls = unwrap(props.hasControls, use) == true
			and controlsVariant ~= NumberInputControlsVariant.None
			and controlsVariant ~= NumberInputControlsVariant.Stacked

		local leadingIcon = unwrap(props.leadingIcon, use)
		local trailingIcon = unwrap(props.trailingIcon, use)
		local prefix = unwrap(props.prefix, use)
		local suffix = unwrap(props.suffix, use)

		local textBoxFontStyle = variantProps.textBox.fontStyle
		local textBoxFontSize = textBoxFontStyle.FontSize :: number

		local hasUnits = (prefix ~= nil and prefix ~= "") or (suffix ~= nil and suffix ~= "")

		local prefixText = innerScope:Computed(function(use: Use)
			local currentPrefix = unwrap(props.prefix, use)
			return if currentPrefix then currentPrefix .. " " else nil
		end)

		-- Floor FontSize before measuring: the engine floors TextSize on render,
		-- so fractional token sizes (e.g. BodyMedium = 17.64) overestimate width.
		local prefixFontStyle = {
			Font = textBoxFontStyle.Font,
			FontSize = math.floor(textBoxFontSize),
			LineHeight = textBoxFontStyle.LineHeight,
		}
		local prefixTextSize = useTextSize(innerScope, prefixText, prefixFontStyle)

		local leadingIconSize = useIconSize(variantProps.icon.size, isBuilderIcon(leadingIcon or "")) :: UDim2
		local trailingIconSize = useIconSize(variantProps.icon.size, isBuilderIcon(trailingIcon or "")) :: UDim2
		local leadingIconWidth = if leadingIcon then leadingIconSize.X.Offset else 0
		local trailingIconWidth = if trailingIcon then trailingIconSize.X.Offset else 0
		local containerGap = if inputSize == InputSize.XSmall
			then tokens.Gap.Small
			elseif inputSize == InputSize.Small then tokens.Gap.Medium
			else tokens.Gap.Large
		local leadingIconGap = if leadingIcon then containerGap else 0
		local trailingIconGap = if trailingIcon then containerGap else 0

		local unitsXOffsets = {
			left = UDim.new(0, variantProps.container.horizontalPadding.Offset + leadingIconWidth + leadingIconGap),
			right = UDim.new(0, variantProps.container.horizontalPadding.Offset + trailingIconWidth + trailingIconGap),
		}

		-- Mirror BaseTextInput's textBoxWrapperPadding formula plus the 1px
		-- stroke inset so the overlay's text baseline matches the textbox's.
		local textHeight = getMultiLineTextHeight(textBoxFontSize, 1, textBoxFontStyle.LineHeight :: number)
		local outerBorderOffset = 2
		local containerPaddingY = math.round((variantProps.container.minHeight - outerBorderOffset - textHeight) * 2) / 2
		local strokeInset = 1
		local unitsPadding = {
			top = UDim.new(0, math.floor(containerPaddingY / 2) + strokeInset),
			bottom = UDim.new(0, math.ceil(containerPaddingY / 2) + strokeInset),
			left = UDim.new(),
			right = UDim.new(),
		}

		local width = unwrap(props.width, use) or UDim.new(0, Constants.DEFAULT_NUMBER_INPUT_WIDTH)
		local widthOffset = if hasControls then UDim.new(0, controlsProps.width + incrementButtonsGap) else UDim.new()

		local innerLeftPadding = innerScope:Computed(function(use: Use)
			local size = unwrap(prefixTextSize, use)
			return if size and size.X > 0 then UDim.new(0, size.X) else UDim.new()
		end)

		local filledStyleTransparency = tokens.Color.Shift.Shift_300.Transparency
		local unfilledStyleTransparency = tokens.Color.Shift.Shift_100.Transparency
		local scrubbableTransparencySequence = innerScope:Computed(function(use: Use)
			local value = unwrap(props.value, use)
			local minimum = unwrap(props.minimum, use)
			local maximum = unwrap(props.maximum, use)

			local percentageScrubbed = 0
			if value and maximum and minimum then
				local currentValue = clampValueToRange(value, use)
				if maximum == minimum then
					percentageScrubbed = 1
				else
					percentageScrubbed = (currentValue - minimum) / (maximum - minimum)
				end
			end

			if percentageScrubbed == 0 then
				return NumberSequence.new(unfilledStyleTransparency)
			elseif percentageScrubbed == 1 then
				return NumberSequence.new(filledStyleTransparency)
			elseif percentageScrubbed > 0 or percentageScrubbed < 1 then
				local numberSequenceKeypoints = {
					NumberSequenceKeypoint.new(0, filledStyleTransparency),
					NumberSequenceKeypoint.new(percentageScrubbed, filledStyleTransparency),
					NumberSequenceKeypoint.new(math.min(percentageScrubbed + 0.001, 1), unfilledStyleTransparency),
				}
				if percentageScrubbed < 0.999 then
					table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(1, unfilledStyleTransparency))
				end

				return NumberSequence.new(numberSequenceKeypoints)
			end
			return NumberSequence.new(unfilledStyleTransparency)
		end)

		local function createIconElement(iconName: UsedAs<string>)
			return function(elementScope: Scope)
				return View {
					scope = elementScope,
					tag = "row align-y-center size-0-full auto-x",
					children = {
						Icon {
							scope = elementScope,
							name = iconName,
							style = variantProps.icon.style,
							size = variantProps.icon.size
						}
					}
				}
			end
		end

		return InputField(withCommonProps(props, {
			scope = innerScope,
			width = width,
			hasError = hasError,
			label = props.label,
			size = getInputTextSize(inputSize),
			isRequired = props.isRequired,
			isDisabled = props.isDisabled,
			hint = props.hint,
			textBoxRef = props.textBoxRef,
			input = function(inputScope: Scope, textBoxRef: UsedAs<InternalTextInputRef?>)
				internalTextBoxRef = textBoxRef
				local controls = if hasControls
					then NumberInputControls {
						scope = inputScope,
						variant = props.variant,
						size = props.size,
						increment = {
							isDisabled = isUpDisabled,
							onClick = onIncrement,
						},
						decrement = {
							isDisabled = isDownDisabled,
							onClick = onDecrement,
						}
					}
					else nil

				local textInputView = BaseTextInput {
					scope = inputScope,
					textBoxRef = textBoxRef,
					text = displayText,
					hasError = hasError,
					variant = props.variant,
					size = props.size,
					Selectable = props.Selectable,
					NextSelectionUp = props.NextSelectionUp,
					NextSelectionDown = props.NextSelectionDown,
					NextSelectionLeft = props.NextSelectionLeft,
					NextSelectionRight = props.NextSelectionRight,
					horizontalPadding = {
						left = variantProps.container.horizontalPadding,
						right = variantProps.container.horizontalPadding,
						innerLeft = innerLeftPadding,
					},
					focusBehavior = props.focusBehavior,
					onChanged = onTextChanged,
					onFocusLost = onFocusLost,
					onFocus = onFocus,
					onDragStarted = if isScrubbable then onDragStarted else nil,
					onDrag = if isScrubbable then onDrag else nil,
					onDragEnded = if isScrubbable then onDragEnded else nil,
					onReturnPressed = props.onReturnPressed,
					backgroundGradient = if isScrubbable
						then function(gradientScope: Scope)
							return gradientScope:New "UIGradient" {
								Color = ColorSequence.new(tokens.Color.Shift.Shift_300.Color3),
								Transparency = scrubbableTransparencySequence,
								Rotation = 0,
							}
						end
						else nil,
					trailingElement = if trailingIcon then createIconElement(props.trailingIcon :: UsedAs<string>) else nil,
					leadingElement = if leadingIcon then createIconElement(props.leadingIcon :: UsedAs<string>) else nil,
					isDisabled = props.isDisabled,
					LayoutOrder = if hasControls then 0 else nil,
				}

				local unitsOverlay = if hasUnits
					then Text {
						scope = inputScope,
						tag = "text-align-x-left text-align-y-center content-muted",
						fontStyle = variantProps.textBox.fontStyle,
						Size = UDim2.new(1, -(unitsXOffsets.left.Offset + unitsXOffsets.right.Offset), 1, 0),
						Position = UDim2.fromOffset(unitsXOffsets.left.Offset, 0),
						Text = inputScope:Computed(function(use: Use)
							local value = unwrap(textInput, use)
							local currentPrefix = unwrap(props.prefix, use)
							local currentSuffix = unwrap(props.suffix, use)
							return `{if currentPrefix then currentPrefix .. " " else ""}<font transparency="1">{value}</font>{if currentSuffix then " " .. currentSuffix else ""}`
						end),
						RichText = true,
						ClipsDescendants = true,
						padding = unitsPadding,
					}
					else nil

				local inputWithUnits = View {
					scope = inputScope,
					tag = "size-full-0 auto-y",
					children = {
						Input = textInputView,
						Units = unitsOverlay,
					}
				}

				return View {
					scope = inputScope,
					Size = UDim2.new(width.Scale - widthOffset.Scale, width.Offset - widthOffset.Offset, 0, 0),
					tag = "row align-y-center auto-y",
					layout = {
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0, incrementButtonsGap),
						SortOrder = Enum.SortOrder.LayoutOrder,
					},
					children = {
						InputField = inputWithUnits,
						Controls = controls,
					}
				}
			end
		}))
	end)
end
