local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useTextInputVariants = require(script.useTextInputVariants)
local truncateTextToCursor = require(script.truncateTextToCursor)

local View = require(Components.View)
local Icon = require(Components.Icon)
local Padding = require(Components.Padding)
local ScrollView = require(Components.ScrollView)

local unwrap = require(Utility.unwrap)
local isState = require(Utility.isState)
local stripProps = require(Utility.stripProps)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local getDisabledStyle = require(Utility.getDisabledStyle)
local isPluginSecurity = require(Utility.isPluginSecurity)
local usePreferredInput = require(Utility.usePreferredInput)
local blendTransparencies = require(Utility.blendTransparencies)
local getMultiLineTextHeight = require(Utility.getMultiLineTextHeight)
local Types = require(Utility.Types)

local Radius = require(Enums.Radius)
local InputSize = require(Enums.InputSize)
local InputVariant = require(Enums.InputVariant)
local ControlState = require(Enums.ControlState)
local InputFocusBehavior = require(Enums.InputFocusBehavior)
local StateLayerAffordance = require(Enums.StateLayerAffordance)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local useStyleTags = require(Foundation.Providers.ThemeProvider.useStyleTags)
local Constants = require(Foundation.Constants)

local Children = Fusion.Children
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent
local Tags = Fusion.Tags

local COMPONENT_ONLY_PROPERTIES = {
	"text",
	"textInputType",
	"size",
	"variant",
	"radius",
	"horizontalPadding",
	"hasError",
	"isDisabled",
	"numLines",
	"focusBehavior",
	"hasClearButton",
	"onChanged",
	"onFocus",
	"onFocusLost",
	"onReturnPressed",
	"onDragStarted",
	"onDrag",
	"onDragEnded",
	"textBoxRef",
	"placeholder"
}

local defaultProps = {
	size = InputSize.Large,
	variant = InputVariant.Standard,
	numLines = 1,
	Selectable = true
}

--// Local Functions

local function setSelectionStart(position: number, textBoxInstance: TextBox?, mobileTextBoxInstance: TextBox?)
	if textBoxInstance then
		textBoxInstance.SelectionStart = position
	end
	if mobileTextBoxInstance then
		mobileTextBoxInstance.SelectionStart = position
	end
end

local function setCursorPosition(position: number, textBoxInstance: TextBox?, mobileTextBoxInstance: TextBox?)
	if textBoxInstance then
		textBoxInstance.CursorPosition = position
	end
	if mobileTextBoxInstance then
		mobileTextBoxInstance.CursorPosition = position
	end
end

local function highlightAllText(textBoxInstance: TextBox?, mobileTextBoxInstance: TextBox?)
	local textBox = textBoxInstance or mobileTextBoxInstance
	if not textBox or not textBox.Parent then return end

	local inputLength = utf8.len(textBox.Text)
	if not inputLength then return end

	setSelectionStart(0, textBoxInstance, mobileTextBoxInstance)
	setCursorPosition(inputLength + 1, textBoxInstance, mobileTextBoxInstance)
end

local function focusTextBox(focusBehavior: InputFocusBehavior, textBoxInstance: TextBox?, mobileTextBoxInstance: TextBox?)
	if not textBoxInstance then return end
	textBoxInstance:CaptureFocus()

	if focusBehavior ~= InputFocusBehavior.Highlight then return end
	task.spawn(highlightAllText, textBoxInstance, mobileTextBoxInstance)
end

local function releaseTextBoxFocus(textBoxInstance: TextBox?)
	if not textBoxInstance then return end
	textBoxInstance:ReleaseFocus()
end

local function getIsFocused(textBoxInstance: TextBox?): boolean?
	if not textBoxInstance then return end
	return textBoxInstance:IsFocused()
end

local function getSelectionStart(textBoxInstance: TextBox?): number?
	if not textBoxInstance then return end
	return textBoxInstance.SelectionStart
end

local function getCursorPosition(textBoxInstance: TextBox?): number?
	if not textBoxInstance then return end
	return textBoxInstance.CursorPosition
end

--// Types

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

type ControlState = ControlState.ControlState
type InputSize = InputSize.InputSize
type InputVariant = InputVariant.InputVariant
type InputFocusBehavior = InputFocusBehavior.InputFocusBehavior
type Radius = Radius.Radius
type ColorStyleValue = Types.ColorStyleValue
type InternalTextInputRef = Types.InternalTextInputRef

type ComputedChild = (scope: Scope) -> Child

type HorizontalPadding = {
	left: UsedAs<UDim>?,
	right: UsedAs<UDim>?,
	innerLeft: UsedAs<UDim>?,
	innerRight: UsedAs<UDim>?,
}

export type BaseTextInputProps = {
	scope: Scope,
	text: UsedAs<string>,
	textInputType: Enum.TextInputType?,
	size: UsedAs<InputSize>?,
	variant: UsedAs<InputVariant>?,
	radius: UsedAs<Radius>?,
	horizontalPadding: HorizontalPadding?,
	hasError: UsedAs<boolean>?,
	isDisabled: UsedAs<boolean>?,
	numLines: UsedAs<number>?,
	focusBehavior: UsedAs<InputFocusBehavior>?,
	hasClearButton: UsedAs<boolean>?,
	onChanged: (text: string) -> (),
	onFocus: (() -> ())?,
	onFocusLost: ((inputObject: InputObject?) -> ())?,
	onReturnPressed: (() -> ())?,
	onDragStarted: ((inputObject: InputObject, position: Vector2) -> ())?,
	onDrag: ((inputObject: InputObject, position: Vector2) -> ())?,
	onDragEnded: ((inputObject: InputObject, position: Vector2) -> ())?,
	textBoxRef: UsedAs<InternalTextInputRef?>?,
	placeholder: UsedAs<string>?,
	backgroundGradient: UsedAs<ComputedChild>?,
	leadingElement: UsedAs<ComputedChild>?,
	trailingElement: UsedAs<ComputedChild>?
} & Types.SelectionProps & Types.CommonProps

return function(inputProps: BaseTextInputProps)
	local scope = inputProps.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the BaseTextInput component.")

	local props = withDefaults(inputProps, defaultProps)
	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local inputSize = unwrap(props.size, use)
		local inputVariant = unwrap(props.variant, use)
		local inputRadius = unwrap(props.radius, use)
		local isDisabled = unwrap(props.isDisabled, use)
		local numLines = math.max(1, unwrap(props.numLines, use) or 1)
		local isMultiLine = numLines > 1
		local isScrollable = isMultiLine
		local hasClearButton = unwrap(props.hasClearButton, use)

		local textBoxInstance: TextBox? = nil
		local mobileTextBoxInstance: TextBox? = nil
		local textBoundsCheckerInstance: TextBox? = nil
		local scrollingFrameInstance: ScrollingFrame? = nil

		local mobileTextBoxText = ""
		local lastDispatchedText = unwrap(props.text) or ""
		local dragStartPosition: Vector2? = nil
		local shouldHighlight = false

		local preferredInput = usePreferredInput(innerScope)
		local isMobileDevice = unwrap(preferredInput, use) == Enum.PreferredInput.Touch
		
		local focus = innerScope:Value(false)
		local isTouchFocused = innerScope:Value(false)
		
		-- The variantProps here are not used in any reactive context.
		local variantProps = useTextInputVariants(
			unwrap(theme.Theme), tokens, inputSize, inputVariant, inputRadius,
			false, false
		)
		local containerProps = variantProps.container
		
		-- The variantProps created under this computed are used in a reactive context for focus.
		-- When the focus changes, this is re-evaluated.
		local strokeVariantComputed = innerScope:Computed(function(use: Use)
			local currentFocus = unwrap(focus, use)
			local currentHasError = unwrap(props.hasError, use)
			return useTextInputVariants(
				unwrap(theme.Theme), tokens, inputSize, inputVariant, inputRadius,
				currentFocus, currentHasError
			).container
		end)

		local textBoxTagComputed = useStyleTags(innerScope, variantProps.textBox.tag, theme.AddTags)

		local textInputTypeValue = innerScope:Computed(function(use: Use)
			local inputType = unwrap(props.textInputType, use)
			return inputType or Enum.TextInputType.Default
		end)

		local outerBorderThickness = tokens.Stroke.Standard
		local outerBorderOffset = math.ceil(outerBorderThickness) * 2

		local textStyle = getDisabledStyle(tokens.Color.Content.Emphasis, isDisabled)
		local fontStyle = variantProps.textBox.fontStyle
		local fontSize = fontStyle.FontSize :: number
		local lineHeight = fontStyle.LineHeight :: number

		local textBoxViewportHeight = getMultiLineTextHeight(fontSize, numLines, lineHeight)
		local containerPaddingY = math.round(
			(containerProps.minHeight - outerBorderOffset - getMultiLineTextHeight(fontSize, 1, lineHeight)) * 2
		) / 2
		local paddingFloored = UDim.new(0, math.floor(containerPaddingY / 2))
		local paddingCeiled = UDim.new(0, math.ceil(containerPaddingY / 2))
		local borderFrameSizeY = textBoxViewportHeight + math.round(containerPaddingY) + outerBorderOffset

		local textBoxWrapperPadding = {
			top = paddingFloored,
			bottom = paddingCeiled,
			left = UDim.new(0, 0),
			right = UDim.new(0, 0)
		}

		local textBoxVerticalPadding = textBoxWrapperPadding.bottom.Offset + textBoxWrapperPadding.top.Offset
		local textBoxSizeFullHeight = UDim2.new(1, 0, 0, textBoxViewportHeight + textBoxVerticalPadding)

		-- Set textBoxRef if provided
		if isState(props.textBoxRef) then
			props.textBoxRef:set({
				getIsFocused = function()
					return getIsFocused(textBoxInstance)	
				end,
				focus = function() 
					return focusTextBox(unwrap(props.focusBehavior), textBoxInstance, mobileTextBoxInstance)	
				end,
				releaseFocus = function()
					return releaseTextBoxFocus(textBoxInstance)	
				end,
				getSelectionStart = function()
					return getSelectionStart(textBoxInstance)	
				end,
				getCursorPosition = function() 
					return getCursorPosition(textBoxInstance)	
				end,
				setCursorPosition = function(position: number)
					return setCursorPosition(position, textBoxInstance, mobileTextBoxInstance)	
				end,
				setSelectionStart = function(position: number)
					return setSelectionStart(position, textBoxInstance, mobileTextBoxInstance)
				end
			})
		end
		
		-- Clear handler
		local function clearText()
			if not textBoxInstance then return end
			textBoxInstance.Text = ""
		end

		-- Event handlers
		local function onTextChange(newText: string)
			if newText == lastDispatchedText then return end
			lastDispatchedText = newText
			if isScrollable and textBoundsCheckerInstance then
				textBoundsCheckerInstance.Text = newText
			end
			props.onChanged(newText)
		end

		local function onFocusGained()
			if isDisabled then return end
			if isScrollable and isMobileDevice then
				if textBoxInstance and textBoxInstance.Parent then
					mobileTextBoxText = textBoxInstance.Text
				end
				isTouchFocused:set(true)
			end
			if props.onFocus then
				props.onFocus()
			end
			
			local focusBehavior = unwrap(props.focusBehavior)
			focus:set(true)
			if focusBehavior == InputFocusBehavior.Clear then
				mobileTextBoxText = ""
				if textBoxInstance then
					textBoxInstance.Text = ""
				end
				if mobileTextBoxInstance then
					mobileTextBoxInstance.Text = ""
				end
			elseif focusBehavior == InputFocusBehavior.Highlight then
				shouldHighlight = true
			end
		end

		local function onInputChanged(inputObject: InputObject)
			if inputObject.UserInputType ~= Enum.UserInputType.MouseMovement then return end
			shouldHighlight = false
		end

		local function onInputEnded(inputObject: InputObject)
			if not shouldHighlight then return end
			shouldHighlight = false
			if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			highlightAllText(textBoxInstance, mobileTextBoxInstance)
		end

		local function onFocusLost(enterPressed: boolean, inputThatCausedFocusLoss: InputObject)
			focus:set(false)
			shouldHighlight = false
			if isScrollable then
				isTouchFocused:set(false)
			end
			if props.onFocusLost then
				props.onFocusLost(inputThatCausedFocusLoss)
			end
			if enterPressed and props.onReturnPressed then
				props.onReturnPressed()
			end
		end

		local function onDragStarted(position: Vector2)
			dragStartPosition = position
			if not props.onDragStarted then return end
			props.onDragStarted(position)
		end

		local function onDrag(position: Vector2)
			if not props.onDrag then return end
			props.onDrag(position)
		end

		local function onDragEnded(position: Vector2)
			if dragStartPosition == position then
				focusTextBox(unwrap(props.focusBehavior), textBoxInstance, mobileTextBoxInstance)
			else
				releaseTextBoxFocus(textBoxInstance)
				focus:set(false)
			end
			dragStartPosition = nil
			if props.onDragEnded then
				props.onDragEnded(position)
			end
		end

		local function onCursorPositionChanged(cursorPosition: number)
			if not scrollingFrameInstance or not textBoundsCheckerInstance then return end

			local textHeight = textBoxInstance.TextSize * textBoxInstance.LineHeight
			local canvasPositionY = scrollingFrameInstance.CanvasPosition.Y

			textBoundsCheckerInstance.Text = truncateTextToCursor(textBoxInstance)
			local truncatedTextHeight = textBoundsCheckerInstance.TextBounds.Y

			local viewportTopEdge = canvasPositionY
				- textBoxWrapperPadding.top.Offset
				+ textBoxWrapperPadding.bottom.Offset
			local viewportBottomEdge = canvasPositionY
				+ scrollingFrameInstance.AbsoluteSize.Y
				- textBoxWrapperPadding.top.Offset
				- textBoxWrapperPadding.bottom.Offset

			if truncatedTextHeight - textHeight < viewportTopEdge then
				scrollingFrameInstance.CanvasPosition += Vector2.new(
					0,
					truncatedTextHeight - textHeight - viewportTopEdge
				)
			end

			if truncatedTextHeight > viewportBottomEdge then
				scrollingFrameInstance.CanvasPosition += Vector2.new(
					0,
					truncatedTextHeight - viewportBottomEdge
				)
			end
		end
		
		local function onMobileTextBoxMount(mobileTextBox: TextBox?)
			if not mobileTextBox then return end
			mobileTextBoxInstance = mobileTextBox
			mobileTextBox.Text = mobileTextBoxText
			mobileTextBoxText = ""
			task.defer(function()
				if not mobileTextBox.Parent then return end
				mobileTextBox:CaptureFocus()
			end)
		end

		-- Cursor
		local cursor = {
			radius = UDim.new(0, containerProps.radius),
			offset = tokens.Stroke.Thick,
			borderWidth = tokens.Stroke.Thick
		}

		-- Horizontal padding
		local horizontalPaddingLeft = if props.horizontalPadding
			then props.horizontalPadding.left or containerProps.horizontalPadding
			else containerProps.horizontalPadding
		local horizontalPaddingRight = if props.horizontalPadding
			then props.horizontalPadding.right or containerProps.horizontalPadding
			else containerProps.horizontalPadding

		-- Clear text button position
		local clearTextButtonPosition = if hasClearButton
			then UDim2.fromOffset(0, (containerProps.minHeight - tokens.Stroke.Standard) / 2)
			else nil

		-- Automatic size for scrollable text box
		local textBoxAutomaticSize = innerScope:Computed(function(use: Use)
			if isScrollable and not unwrap(isTouchFocused, use) then
				local text = unwrap(props.text, use)
				if text ~= "" then
					return Enum.AutomaticSize.Y
				end
			end
			return Enum.AutomaticSize.None
		end)

		-- Visible States
		local textBoxVisible = innerScope:Computed(function(use: Use)
			return not unwrap(isTouchFocused, use)
		end)

		local mobileTextBoxVisible = innerScope:Computed(function(use: Use)
			return isScrollable and unwrap(isTouchFocused, use)
		end)

		local clearButtonVisible = innerScope:Computed(function(use: Use)
			local text = unwrap(props.text, use)
			return text ~= ""
		end)

		-- DragDetector
		local hasDrag = props.onDragStarted ~= nil or props.onDrag ~= nil or props.onDragEnded ~= nil
		local dragDetectorProps = {}
		if hasDrag then
			dragDetectorProps = {
				DragStyle = Enum.UIDragDetectorDragStyle.Scriptable,
				[OnEvent "DragStart"] = onDragStarted,
				[OnEvent "DragContinue"] = onDrag,
				[OnEvent "DragEnd"] = onDragEnded
			}
		end

		-- Helper to create a TextBox instance
		local function createTextBox(isMobile: boolean): TextBox
			local children = {
				Padding {
					scope = innerScope,
					value = textBoxWrapperPadding
				},
				if hasDrag then innerScope:New "UIDragDetector" (dragDetectorProps) else nil -- DragDetector inside TextBox
			}

			-- BoundsChecker for scrollable
			if isScrollable and not isMobile then
				local boundsChecker = innerScope:New "TextBox" {
					ClearTextOnFocus = false,
					Selectable = false,
					Active = false,
					Visible = false,
					Font = fontStyle.Font,
					TextSize = fontStyle.FontSize,
					LineHeight = fontStyle.LineHeight,
					MultiLine = true,
					TextWrapped = true,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextEditable = false,
					Size = UDim2.new(1, 0, 1, textBoxVerticalPadding),
				}
				textBoundsCheckerInstance = boundsChecker
				table.insert(children, boundsChecker)
			end

			local tbProps = {
				ClearTextOnFocus = false,
				Selectable = false,
				Font = fontStyle.Font,
				TextSize = fontStyle.FontSize,
				LineHeight = fontStyle.LineHeight,
				TextColor3 = textStyle.Color3,
				TextTransparency = textStyle.Transparency,
				MultiLine = isMultiLine,
				TextWrapped = isMultiLine,
				TextYAlignment = if isMultiLine then Enum.TextYAlignment.Top else Enum.TextYAlignment.Center,
				TextEditable = not isDisabled,
				PlaceholderText = props.placeholder,
				TextInputType = if isPluginSecurity() then textInputTypeValue else Enum.TextInputType.Default,
				Size = if isScrollable then textBoxSizeFullHeight else UDim2.fromScale(1, 1),
				Text = props.text,
				Visible = if isMobile then mobileTextBoxVisible else textBoxVisible,
				AutomaticSize = if isMobile then nil else textBoxAutomaticSize,
				[OnChange "Text"] = onTextChange,
				[OnChange "CursorPosition"] = if isScrollable then onCursorPositionChanged else nil,
				[OnEvent "Focused"] = onFocusGained,
				[OnEvent "FocusLost"] = onFocusLost,
				[OnEvent "InputChanged"] = if isMobile then nil else onInputChanged,
				[OnEvent "InputEnded"] = if isMobile then nil else onInputEnded,
				[Children] = children,
				[Tags] = textBoxTagComputed
			}
			return innerScope:New "TextBox" (tbProps)
		end

		-- Create main TextBox
		local mainTextBox = createTextBox(false)
		textBoxInstance = mainTextBox

		-- Create mobile TextBox if scrollable
		local mobileTextBox = nil
		if isScrollable then
			mobileTextBox = createTextBox(true)
		end

		-- Handle mobile TextBox mount via observer
		if mobileTextBox then
			innerScope:Observer(mobileTextBoxVisible):onChange(function()
				if not unwrap(mobileTextBoxVisible) or mobileTextBoxInstance then return end
				onMobileTextBoxMount(mobileTextBox)
			end)
		end

		-- Build children for outer View
		local outerChildren = {}
		local backgroundGradient = unwrap(props.backgroundGradient, use)
		local leadingElement = unwrap(props.leadingElement, use)
		local trailingElement = unwrap(props.trailingElement, use)

		-- DragDetector at outer level (when no scroll)
		if hasDrag and not isScrollable then
			outerChildren.DragDetector = innerScope:New "UIDragDetector" (dragDetectorProps)
		end
		
		-- Background gradient
		if backgroundGradient then
			outerChildren.Background = backgroundGradient(innerScope)
		end

		-- Leading element
		if leadingElement then
			outerChildren.Leading = View {
				scope = innerScope,
				GroupTransparency = if isDisabled then innerScope:Value(Constants.DISABLED_TRANSPARENCY) else nil,
				LayoutOrder = 1,
				tag = "size-0-full auto-x",
				children = leadingElement
			}
		end
		
		-- Trailing element
		if trailingElement then
			outerChildren.Trailing = View {
				scope = innerScope,
				GroupTransparency = if isDisabled then innerScope:Value(Constants.DISABLED_TRANSPARENCY) else nil,
				LayoutOrder = 4,
				tag = "size-0-full auto-x",
				children = trailingElement
			}
		end

		-- TextBoxWrapper (ScrollView or View)
		local textBoxWrapperChildren = {
			TextBox = mainTextBox
		}
		
		if mobileTextBox then
			textBoxWrapperChildren.MobileTextBox = mobileTextBox
		end

		local textBoxWrapperProps = {
			scope = innerScope,
			LayoutOrder = 2,
			selection = { Selectable = false },
			tag = "fill size-full clip",
			children = textBoxWrapperChildren
		}

		if isScrollable then
			textBoxWrapperProps.scroll = {
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.fromOffset(0, 0),
				ScrollingDirection = Enum.ScrollingDirection.Y,
				VerticalScrollBarInset = Enum.ScrollBarInset.Always
			}
			textBoxWrapperProps.layout = {
				FillDirection = Enum.FillDirection.Vertical,
				ItemLineAlignment = Enum.ItemLineAlignment.Center
			}
			outerChildren.TextBoxWrapper = ScrollView(textBoxWrapperProps)
		else
			outerChildren.TextBoxWrapper = View(textBoxWrapperProps)
		end

		-- Clear button
		if hasClearButton then
			outerChildren.Clear = View {
				scope = innerScope,
				isDisabled = isDisabled,
				GroupTransparency = if isDisabled then innerScope:Value(Constants.DISABLED_TRANSPARENCY) else nil,
				LayoutOrder = 3,
				Visible = clearButtonVisible,
				tag = variantProps.clearButton.tag,
				children = {
					View {
						scope = innerScope,
						onActivated = clearText,
						padding = UDim.new(0, variantProps.clearButton.padding),
						Position = clearTextButtonPosition,
						stateLayer = { affordance = StateLayerAffordance.None },
						tag = "anchor-center-left auto-xy",
						children = {
							Icon {
								scope = innerScope,
								name = variantProps.clearButton.icon
							}
						}
					}
				}
			}
		end

		-- Background style
		local backgroundStyle = nil
		if containerProps.bgStyle then
			backgroundStyle = getDisabledStyle({
				Color3 = containerProps.bgStyle.Color3,
				Transparency = if props.backgroundGradient then 0 else containerProps.bgStyle.Transparency
			}, isDisabled)
		end
		
		local strokeProps = nil
		if containerProps.strokeStyle and containerProps.strokeThickness then
			local strokeColor = innerScope:Computed(function(use: Use)
				return unwrap(strokeVariantComputed, use).strokeStyle.Color3
			end)
			local strokeTransparency = innerScope:Computed(function(use: Use)
				local transparency = unwrap(strokeVariantComputed, use).strokeStyle.Transparency
				return if isDisabled
					then blendTransparencies(transparency, Constants.DISABLED_TRANSPARENCY)
					else transparency
			end)
			local strokeThickness = innerScope:Computed(function(use: Use)
				return unwrap(strokeVariantComputed, use).strokeThickness
			end)
			local borderStrokePosition = innerScope:Computed(function(use: Use)
				return if unwrap(focus, use)
					then Enum.BorderStrokePosition.Center
					else Enum.BorderStrokePosition.Inner
			end)
			strokeProps = {
				Color = strokeColor,
				Transparency = strokeTransparency,
				Thickness = strokeThickness,
				BorderStrokePosition = borderStrokePosition
			}
		end

		-- Corner radius
		local cornerRadius
		if inputRadius == Radius.Circle then
			cornerRadius = UDim.new(0, math.ceil(containerProps.minHeight / 2))
		end

		-- Horizontal padding for outer container
		local outerPaddingLeft = innerScope:Computed(function(use: Use)
			local leftPad = unwrap(horizontalPaddingLeft, use)
			return UDim.new(0, outerBorderThickness) + leftPad
		end)

		local outerPaddingRight
		if not props.trailingElement and hasClearButton then
			outerPaddingRight = UDim.new(0, outerBorderThickness)
		else
			outerPaddingRight = innerScope:Computed(function(use: Use)
				local rightPad = unwrap(horizontalPaddingRight, use)
				return UDim.new(0, outerBorderThickness) + rightPad
			end)
		end

		-- Selection props
		local selectionProps = {
			Selectable = if isDisabled then false else props.Selectable,
			NextSelectionUp = props.NextSelectionUp,
			NextSelectionDown = props.NextSelectionDown,
			NextSelectionLeft = props.NextSelectionLeft,
			NextSelectionRight = props.NextSelectionRight
		}

		-- Build outer View props
		local outerViewProps = withCommonProps(props, {
			scope = innerScope,
			Size = UDim2.new(1, 0, 0, borderFrameSizeY),
			selection = selectionProps,
			cursor = cursor,
			stroke = strokeProps,
			cornerRadius = cornerRadius,
			padding = {
				left = outerPaddingLeft,
				right = outerPaddingRight,
				top = UDim.new(0, outerBorderThickness),
				bottom = UDim.new(0, outerBorderThickness),
			},
			onActivated = if not isDisabled then function()
				return focusTextBox(unwrap(props.focusBehavior), textBoxInstance, mobileTextBoxInstance)
			end else nil,
			isDisabled = isDisabled,
			backgroundStyle = backgroundStyle,
			stateLayer = { affordance = StateLayerAffordance.None },
			tag = containerProps.tag,
			children = outerChildren
		})

		return innerScope:Hydrate(View(outerViewProps))(stripProps(props, COMPONENT_ONLY_PROPERTIES))
	end)
end