local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Spinner = require(script.Spinner)
local ButtonIcon = require(script.ButtonIcon)

local endAlignedIcons = require(script.endAlignedIcons)
local useButtonVariants = require(script.useButtonVariants)
local useButtonMotionStates = require(script.useButtonMotionStates)

local View = require(Components.View)
local Text = require(Components.Text)

local unwrap = require(Utility.unwrap)
local isState = require(Utility.isState)
local stripProps = require(Utility.stripProps)
local withDefaults = require(Utility.withDefaults)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)
local FillBehavior = require(Enums.FillBehavior)
local ControlState = require(Enums.ControlState)
local ButtonVariant = require(Enums.ButtonVariant)
local ColorNamespace = require(Enums.ColorNamespace)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local usePresentationContext = require(Foundation.Providers.ThemeProvider.PresentationContext).usePresentationContext
local Constants = require(Foundation.Constants)

local Children = Fusion.Children

local BUTTON_VARIANT_TO_RICH_TEXT_FORMAT: { [ButtonVariant]: { format: string, controlState: { ControlState } } } = {
	[ButtonVariant.Link] = {
		format = "<u>%s</u>",
		controlState = { ControlState.Hover, ControlState.Pressed }
	}
}

local COMPONENT_ONLY_PROPERTIES = {
	"text",
	"icon",
	"variant",
	"size",
	"width",
	"scale",
	"isDisabled",
	"isLoading",
	"onActivated",
	"fillBehavior",
	"inputDelay",
	"textSizeOffset",
	"isIconSize",
	"colorNamespace"
}

local defaultProps = {
	isDisabled = false,
	isLoading = false,
	variant = ButtonVariant.Standard,
	size = InputSize.Medium,
	width = UDim.new(0, 0),
	inputDelay = 0
}

local function onProgressChange(progress: number)
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(math.max(0, progress - 0.0001), 0),
		NumberSequenceKeypoint.new(math.min(1, progress + 0.0001), Constants.DISABLED_TRANSPARENCY),
		NumberSequenceKeypoint.new(1, Constants.DISABLED_TRANSPARENCY),
	})
end

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type InputSize = InputSize.InputSize
type ButtonVariant = ButtonVariant.ButtonVariant
type ColorNamespace = ColorNamespace.ColorNamespace
type SupportedButtonVariant = ButtonVariant.ButtonVariant
type FillBehavior = FillBehavior.FillBehavior
type ControlState = ControlState.ControlState

export type ButtonProps = {
	-- The scope in which the component will be created.
	scope: Scope,
	text: UsedAs<string>?,
	icon: UsedAs<string>?,
	onActivated: () -> (),
	isDisabled: UsedAs<boolean>?,
	isLoading: UsedAs<boolean>?,
	-- Officially supported variants are `Standard`, `Emphasis`, `SoftEmphasis`, `Alert` and `Utility`
	variant: UsedAs<SupportedButtonVariant>?,
	size: UsedAs<InputSize>?,
	-- Width of the button. `fillBehavior` is preferred and works better with flex layouts. Intended for cross-directional scaled sizing.
	width: UsedAs<UDim>?,
	fillBehavior: UsedAs<FillBehavior>?,
	-- The delay in seconds before the button is enabled.
	-- This will only visually show on buttons whose variants use a filled background.
	inputDelay: UsedAs<number>?,
	-- These properties are converted from contexts.
	textSizeOffset: UsedAs<number>?,
	isIconSize: UsedAs<boolean>?,
	colorNamespace: UsedAs<ColorNamespace>?
} & Types.SelectionProps & Types.CommonProps

return function(buttonProps: ButtonProps)
	local scope = buttonProps.scope
	local theme = ThemeProvider()
	local presentationContext = usePresentationContext()
	assert(scope, "A scope has not been provided for the Button component.")

	local props = withDefaults(buttonProps, defaultProps)
	local controlState = scope:Value(ControlState.Initialize :: ControlState)

	local function setControlState(newState: ControlState)
		if newState == ControlState.Disabled then return end
		controlState:set(newState)
	end

	local hasTextState = scope:Computed(function(use: Use)
		local text = unwrap(props.text, use)
		return text ~= nil and text ~= ""
	end)

	local hasIconState = scope:Computed(function(use: Use)
		local icon = unwrap(props.icon, use)
		return icon ~= nil and icon ~= ""
	end)

	local initialColorNamespace = if props.colorNamespace
		then unwrap(props.colorNamespace)
		else unwrap(presentationContext.colorNamespace)
	local initialVariantProps = useButtonVariants(
		unwrap(theme.Theme),
		unwrap(theme.Tokens),
		unwrap(props.size),
		unwrap(props.variant),
		initialColorNamespace
	)
	
	local defaultTransparency = initialVariantProps.content.style.Transparency or 0
	local motion = useButtonMotionStates(scope, props.isLoading, props.isDisabled, defaultTransparency, Constants.DISABLED_TRANSPARENCY)
	
	local inputDelay: number = unwrap(props.inputDelay)
	local isInputDelayAState = isState(props.inputDelay)
	local isDelaying = scope:Value(inputDelay > 0)
	local progressGoal = scope:Value(0)
	
	local progressTween = scope:Tween(progressGoal, scope:Computed(function(use: Use)
		local inputDelay = unwrap(props.inputDelay, use)
		return TweenInfo.new(inputDelay, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	end))
	
	local disconnect
	disconnect = scope:Observer(progressTween):onChange(function()
		if unwrap(progressTween) < 1 then return end
		isDelaying:set(false)
		task.defer(progressGoal.set, progressGoal, 0)
		
		if isInputDelayAState then return end
		disconnect() -- If the input delay is not a state, this observer should not continue to listen.
	end)
	
	if inputDelay > 0 then
		progressGoal:set(1)
	end
	
	if isInputDelayAState then
		scope:Observer(props.inputDelay):onChange(function() 
			local inputDelay = unwrap(props.inputDelay)
			if inputDelay <= 0 then return end
			isDelaying:set(true)
			progressGoal:set(1)
		end)
	end
	
	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local buttonSize = unwrap(props.size, use)
		local buttonVariant = unwrap(props.variant, use)

		local buttonColor = if props.colorNamespace
			then unwrap(props.colorNamespace, use)
			else unwrap(presentationContext.colorNamespace, use)

		local variantProps = useButtonVariants(unwrap(theme.Theme), tokens, buttonSize, buttonVariant, buttonColor)

		local isIcon = unwrap(hasIconState, use)
		local hasText = unwrap(hasTextState, use)

		local currentWidth = unwrap(props.width, use)
		local currentFillBehavior = unwrap(props.fillBehavior, use)

		local function formatText(use: Use)
			local currentText = unwrap(props.text, use)
			local state = unwrap(controlState, use)
			local richTextFormat = BUTTON_VARIANT_TO_RICH_TEXT_FORMAT[buttonVariant]

			if hasText and richTextFormat and table.find(richTextFormat.controlState, state) then
				return richTextFormat.format:format(currentText)
			end
			return currentText
		end

		local buttonChildren = {}

		buttonChildren.Loading = innerScope:New "Folder" {
			[Children] = {
				Spinner = Spinner {
					scope = innerScope,
					Size = variantProps.icon.size,
					isVisible = props.isLoading,
					style = innerScope:Computed(function(use: Use)
						return {
							Color3 = variantProps.content.style.Color3,
							Transparency = unwrap(motion.transparency, use)
						}
					end)
				}
			}
		}

		if isIcon then
			buttonChildren.IconWrapper = View {
				scope = innerScope,
				Size = variantProps.icon.size,
				LayoutOrder = innerScope:Computed(function(use: Use)
					local icon = unwrap(props.icon, use)
					local endAligned = icon and endAlignedIcons[icon]
					return if endAligned then 3 else 1
				end),
				children = {
					Icon = ButtonIcon {
						scope = innerScope,
						icon = props.icon,
						isLoading = props.isLoading,
						variant = buttonVariant,
						size = buttonSize,
						disabledTransparencyBinding = motion.transparency,
						textTransparencyBinding = motion.textTransparency,
						textSizeOffset = props.textSizeOffset
					}
				}
			}
		end

		if hasText then
			buttonChildren.Text = Text {
				scope = innerScope,
				Text = innerScope:Computed(formatText),
				RichText = if BUTTON_VARIANT_TO_RICH_TEXT_FORMAT[buttonVariant] ~= nil then true else false,
				tag = variantProps.text.tag,
				textStyle = innerScope:Computed(function(use: Use)
					local disabledTransp = unwrap(motion.transparency, use)
					local textTransp = unwrap(motion.textTransparency, use)
					return {
						Color3 = variantProps.content.style.Color3,
						Transparency = textTransp + disabledTransp,
					}
				end),
				LayoutOrder = 2
			}
		end
		
		if isInputDelayAState or inputDelay > 0 then
			buttonChildren.Gradient = innerScope:New "UIGradient" {
				Enabled = innerScope:Computed(function(use: Use) 
					return unwrap(props.inputDelay, use) > 0
				end),
				Transparency = innerScope:Computed(function(use: Use)
					local delaying = unwrap(isDelaying, use)
					if not delaying then
						return NumberSequence.new(0)
					end
					local progress = unwrap(progressTween, use)
					return onProgressChange(progress)
				end)
			}	
		end

		local viewProps = {
			scope = innerScope,
			AutomaticSize = if currentWidth.Scale == 0 then Enum.AutomaticSize.X else nil,
			LayoutOrder = props.LayoutOrder,
			cornerRadius = UDim.new(0, variantProps.container.radius),

			backgroundStyle = if variantProps.container.style
				then {
					Color3 = variantProps.container.style.Color3,
					Transparency = innerScope:Computed(function(use: Use)
						local baseTransp = variantProps.container.style.Transparency or 0
						local disabledVal = unwrap(motion.transparency, use)
						return baseTransp + (1 - baseTransp) * disabledVal
					end),
				}
				else nil,

			flexItem = if currentFillBehavior
				then {
					FlexMode = if currentFillBehavior == FillBehavior.Fill
					then Enum.UIFlexMode.Fill
					else Enum.UIFlexMode.Shrink,
				}
				else nil,

			stroke = if variantProps.container.stroke
				then {
					Color = variantProps.container.stroke.Color,
					Transparency = innerScope:Computed(function(use: Use)
						local baseTransp = variantProps.container.stroke.Transparency or 0
						local disabledVal = unwrap(motion.transparency, use)
						return baseTransp + (1 - baseTransp) * disabledVal
					end),
				}
				else nil,

			Size = UDim2.new(
				if currentFillBehavior == FillBehavior.Fill then 1 else currentWidth.Scale,
				if currentFillBehavior == FillBehavior.Fill then 0 else currentWidth.Offset,
				0,
				variantProps.container.height
			),

			selection = {
				Selectable = innerScope:Computed(function(use: Use)
					return if unwrap(props.isDisabled, use) then false else props.Selectable
				end),
				NextSelectionUp = props.NextSelectionUp,
				NextSelectionDown = props.NextSelectionDown,
				NextSelectionLeft = props.NextSelectionLeft,
				NextSelectionRight = props.NextSelectionRight,
			},

			cursor = {
				radius = UDim.new(0, variantProps.container.radius),
				offset = tokens.Size.Size_200,
				borderWidth = tokens.Stroke.Thicker,
			},

			onActivated = props.onActivated,
			onStateChanged = setControlState,

			isDisabled = innerScope:Computed(function(use: Use)
				return (unwrap(props.isDisabled, use) or unwrap(props.isLoading, use) or unwrap(isDelaying, use))
			end),

			stateLayer = variantProps.container.stateLayer,
			tag = variantProps.container.tag,
			children = buttonChildren
		}

		return innerScope:Hydrate(View(viewProps))(props, stripProps(props, COMPONENT_ONLY_PROPERTIES))
	end)
end