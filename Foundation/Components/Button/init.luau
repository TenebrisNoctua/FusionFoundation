local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Utility = Foundation.Utility
local Enums = Foundation.Enums
local TypesSource = Utility.Types

local Spinner = require(script.Spinner)
local ButtonIcon = require(script.ButtonIcon)
local View = require(script.Parent.View)
local Text = require(script.Parent.Text)

local endAlignedIcons = require(script.endAlignedIcons)
local useButtonVariants = require(script.useButtonVariants)
local useButtonMotionStates = require(script.useButtonMotionStates)

local withCommonProps = require(Utility.withCommonProps)
local withDefaults = require(Utility.withDefaults)
local unwrap = require(Utility.unwrap)
local stripProps = require(Utility.stripProps)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local InputSize = require(Enums.InputSize)
local ButtonVariant = require(Enums.ButtonVariant)
local FillBehavior = require(Enums.FillBehavior)
local ControlState = require(Enums.ControlState)
local ColorMode = require(Enums.ColorMode)

local Constants = require(Foundation.Constants)
local Types = require(TypesSource.Types)

local Children = Fusion.Children

local BUTTON_VARIANT_TO_RICH_TEXT_FORMAT: { [ButtonVariant]: { format: string, controlState: { ControlState } } } = {
	[ButtonVariant.Link] = {
		format = "<u>%s</u>",
		controlState = { ControlState.Hover, ControlState.Pressed },
	},
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
	"colorMode"
}

local defaultProps = {
	isDisabled = false,
	isLoading = false,
	variant = ButtonVariant.Standard,
	size = InputSize.Medium,
	width = UDim.new(0, 0),
	inputDelay = 0,
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
type ColorMode = ColorMode.ColorMode
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
	colorMode: UsedAs<ColorMode>?,
} & Types.SelectionProps & Types.CommonProps

return function(buttonProps: ButtonProps)
	local Scope = buttonProps.scope
	local Theme = ThemeProvider()
	assert(Scope, "A scope has not been provided for the Button component.")

	local props = withDefaults(buttonProps, defaultProps)
	local controlState = Scope:Value(ControlState.Initialize :: ControlState)

	local buttonState = Scope:Computed(function(use: Use)
		if unwrap(props.isDisabled, use) then return "Disabled"
		elseif unwrap(props.isLoading, use) then return "Loading"
		else return "Default" end
	end)

	local variantProps = useButtonVariants(Scope, props.size, props.variant, props.colorMode)

	local defaultTransparency = Scope:Computed(function(use: Use)
		return unwrap(variantProps, use).content.style.Transparency or 0
	end)

	local motion = useButtonMotionStates(Scope, buttonState, defaultTransparency, Constants.DISABLED_TRANSPARENCY)

	local function setControlState(newState: ControlState)
		if newState == ControlState.Disabled then return end
		controlState:set(newState)
	end

	return Scope:Computed(function(use: Use, innerScope: Scope)
		local inputDelay = unwrap(props.inputDelay, use)
		local isDelaying = innerScope:Value(inputDelay > 0)
		local progressGoal = innerScope:Value(0)
		local progressTween = innerScope:Tween(progressGoal, TweenInfo.new(unwrap(props.inputDelay, use) or 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))

		if inputDelay > 0 then
			isDelaying:set(true)
			progressGoal:set(1)
		end

		local currentVariantProps = unwrap(variantProps, use)
		local isIcon = unwrap(props.icon, use)
		local isEndAligned = isIcon and endAlignedIcons[isIcon]
		local hasText = unwrap(props.text, use) and unwrap(props.text, use) ~= ""

		local currentWidth = unwrap(props.width, use)
		local currentFillBehavior = unwrap(props.fillBehavior, use)
		local currentDelaying = unwrap(isDelaying)
		local currentLoading = unwrap(props.isLoading, use)

		local function formatText(use: Use)
			local currentText = unwrap(props.text, use)
			local state = unwrap(controlState, use)
			local variant = unwrap(props.variant, use)
			local richTextFormat = BUTTON_VARIANT_TO_RICH_TEXT_FORMAT[variant]

			if hasText and richTextFormat and table.find(richTextFormat.controlState, state) then
				return richTextFormat.format:format(currentText)
			end
			return currentText
		end

		local buttonChildren = {}

		if currentLoading then
			buttonChildren.Loading = innerScope:New "Folder" {
				[Children] = {
					Spinner = Spinner {
						scope = innerScope,
						Size = currentVariantProps.icon.size,
						style = innerScope:Computed(function(use: Use)
							return {
								Color3 = currentVariantProps.content.style.Color3,
								Transparency = unwrap(motion.iconTransparency, use),
							}
						end)
					}
				}
			}
		end

		if isIcon then
			buttonChildren.IconWrapper = View {
				scope = innerScope,
				Size = currentVariantProps.icon.size,
				LayoutOrder = if isEndAligned then 3 else 1,
				children = {
					Icon = ButtonIcon {
						scope = innerScope,
						icon = props.icon,
						isLoading = props.isLoading,
						variant = props.variant,
						size = props.size,
						disabledTransparencyBinding = motion.transparency,
						textTransparencyBinding = motion.textTransparency,
						textSizeOffset = props.textSizeOffset,
					}
				},
			}
		end

		if hasText then
			buttonChildren.Text = Text {
				scope = innerScope,
				Text = innerScope:Computed(formatText),
				RichText = if BUTTON_VARIANT_TO_RICH_TEXT_FORMAT[use(props.variant)] ~= nil then true else false,
				tag = currentVariantProps.text.tag,
				textStyle = innerScope:Computed(function(use: Use)
					local disabledTransp = unwrap(motion.transparency, use)
					local textTransp = unwrap(motion.textTransparency, use)
					return {
						Color3 = currentVariantProps.content.style.Color3,
						Transparency = textTransp + disabledTransp,
					}
				end),
				LayoutOrder = 2,
			}
		end

		if currentDelaying then
			buttonChildren.Gradient = innerScope:New "UIGradient" {
				Transparency = innerScope:Computed(function(use: Use)
					local progress = unwrap(progressTween, use)
					if progress == 1 then isDelaying:set(false) end
					return onProgressChange(progress)
				end),
			}
		end

		local viewProps = {
			scope = innerScope,
			AutomaticSize = if currentWidth.Scale == 0 then Enum.AutomaticSize.X else nil,
			cornerRadius = UDim.new(0, currentVariantProps.container.radius),

			backgroundStyle = if currentVariantProps.container.style
				then {
					Color3 = currentVariantProps.container.style.Color3,
					Transparency = innerScope:Computed(function(use: Use)
						local baseTransp = currentVariantProps.container.style.Transparency or 0
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

			stroke = if currentVariantProps.container.stroke
				then {
					Color = currentVariantProps.container.stroke.Color,
					Transparency = innerScope:Computed(function(use: Use)
						local baseTransp = currentVariantProps.container.stroke.Transparency or 0
						local disabledVal = unwrap(motion.transparency, use)
						return baseTransp + (1 - baseTransp) * disabledVal
					end),
				}
				else nil,

			Size = UDim2.new(
				if currentFillBehavior == FillBehavior.Fill then 1 else currentWidth.Scale,
				if currentFillBehavior == FillBehavior.Fill then 0 else currentWidth.Offset,
				0,
				currentVariantProps.container.height
			),

			selection = {
				Selectable = if unwrap(props.isDisabled, use) then false else props.Selectable,
				NextSelectionUp = props.NextSelectionUp,
				NextSelectionDown = props.NextSelectionDown,
				NextSelectionLeft = props.NextSelectionLeft,
				NextSelectionRight = props.NextSelectionRight,
			},

			cursor = {
				radius = UDim.new(0, currentVariantProps.container.radius),
				offset = unwrap(Theme.Tokens, use).Size.Size_200,
				borderWidth = unwrap(Theme.Tokens, use).Stroke.Thicker,
			},

			onActivated = props.onActivated,
			onStateChanged = setControlState,

			isDisabled = innerScope:Computed(function(use: Use)
				return not (unwrap(props.isDisabled, use) or currentLoading or unwrap(isDelaying, use))
			end),

			stateLayer = currentVariantProps.container.stateLayer,
			tag = currentVariantProps.container.tag,
			children = buttonChildren
		}

		return innerScope:Hydrate(View(viewProps))(Dash.join(withCommonProps(props, {}), stripProps(props, COMPONENT_ONLY_PROPERTIES)))
	end)
end