local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")
local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Utility = Foundation.Utility
local Enums = Foundation.Enums
local TypesSource = Utility.Types

local Spinner = require(script.Spinner)
local Image = require(script.Parent.Image)
local View = require(script.Parent.View)
local Text = require(script.Parent.Text)

local endAlignedIcons = require(script.endAlignedIcons)
local useButtonVariants = require(script.useButtonVariants)
local useButtonMotionStates = require(script.Parent.useButtonMotionStates)

local withCommonProps = require(Utility.withCommonProps)
local iconMigrationUtils = require(Utility.iconMigrationUtils)
local withDefaults = require(Utility.withDefaults)
local unwrap = require(Utility.unwrap)
local getIconScale = require(Utility.getIconScale)
local stripProps = require(Utility.stripProps)
local themeProvider = require(Utility.themeProvider)()

local InputSize = require(Enums.InputSize)
local ButtonVariant = require(Enums.ButtonVariant)
local FillBehavior = require(Enums.FillBehavior)
local ControlState = require(Enums.ControlState)
local ColorMode = require(Enums.ColorMode)

local Constants = require(Foundation.Constants)
local Types = require(TypesSource.Types)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

local migrationLookup = BuilderIcons.Migration["uiblox"]

local isMigrated = iconMigrationUtils.isMigrated
local isBuilderOrMigratedIcon = iconMigrationUtils.isBuilderOrMigratedIcon

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
	"isDisabled",
	"isLoading",
	"onActivated",
	"fillBehavior",
	"inputDelay",
	"textSizeOffset",
	"isIconSize",
	"colorMode",
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

type SupportedButtonVariant =
	typeof(ButtonVariant.Standard)
	| typeof(ButtonVariant.Emphasis)
	| typeof(ButtonVariant.SoftEmphasis)
	| typeof(ButtonVariant.Alert)
	| typeof(ButtonVariant.Utility)
	| typeof(ButtonVariant.Link)
	| typeof(ButtonVariant.SubEmphasis)
	| typeof(ButtonVariant.Subtle)
	| typeof(ButtonVariant.Text)

type FillBehavior = FillBehavior.FillBehavior
type ControlState = ControlState.ControlState

export type ButtonProps = {
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
	assert(Scope, "A scope has not been provided for the Button component.")

	local props = withDefaults(buttonProps, defaultProps)

	local controlState = Scope:Value(ControlState.Initialize :: ControlState)
	local isDelaying = Scope:Value(unwrap(props.inputDelay) > 0)
	local progressGoal = Scope:Value(0)

	if unwrap(props.inputDelay) > 0 then
		isDelaying:set(true)
		progressGoal:set(1)
	end

	local progressTween = Scope:Tween(progressGoal, Scope:Computed(function(use)
		local duration = use(props.inputDelay) or 0
		return TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	end))

	local buttonState = Scope:Computed(function(use)
		if use(props.isDisabled) then return "Disabled"
		elseif use(props.isLoading) then return "Loading"
		else return "Default" end
	end)

	local variantProps = useButtonVariants(Scope, props.size, props.variant, props.colorMode)

	local defaultTransparency = Scope:Computed(function(use) 
		return use(variantProps).content.style.Transparency or 0 
	end)

	local motion = useButtonMotionStates(Scope, buttonState, defaultTransparency, Constants.DISABLED_TRANSPARENCY)
	local function setControlState(newState: ControlState)
		controlState:set(newState)
	end

	return Scope:Computed(function(use: Use, innerScope: Scope)
		local currentVariantProps = use(variantProps)
		local isIcon = use(props.icon)
		local isEndAligned = isIcon and endAlignedIcons[isIcon]
		local hasText = use(props.text) and use(props.text) ~= ""

		local currentSize = use(props.size)
		local currentWidth = use(props.width)
		local currentFillBehavior = use(props.fillBehavior)
		local currentDelaying = use(isDelaying)
		local currentLoading = use(props.isLoading)
		local textOffset = use(props.textSizeOffset) or 0

		local intrinsicIconSize, scale = getIconScale(isIcon, currentSize)

		local function formatText()
			local currentText = use(props.text)
			local state = use(controlState)
			local variant = use(props.variant)
			local richTextFormat = BUTTON_VARIANT_TO_RICH_TEXT_FORMAT[variant]

			if hasText and richTextFormat and table.find(richTextFormat.controlState, state) then
				return richTextFormat.format:format(currentText) :: string?
			end
			return currentText
		end

		local viewProps = withCommonProps(props, {
			scope = innerScope,
			AutomaticSize = if currentWidth.Scale == 0 then Enum.AutomaticSize.X else nil,
			cornerRadius = UDim.new(0, currentVariantProps.container.radius),

			backgroundStyle = if currentVariantProps.container.style
				then {
					Color3 = currentVariantProps.container.style.Color3,
					Transparency = Scope:Computed(function(innerUse)
						local baseTransp = currentVariantProps.container.style.Transparency or 0
						local disabledVal = innerUse(motion.transparency)
						return baseTransp + (1 - baseTransp) * disabledVal
					end)
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
					Transparency = Scope:Computed(function(innerUse)
						local baseTransp = currentVariantProps.container.stroke.Transparency or 0
						local disabledVal = innerUse(motion.transparency)
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
				Selectable = if use(props.isDisabled) then false else props.Selectable,
				NextSelectionUp = props.NextSelectionUp,
				NextSelectionDown = props.NextSelectionDown,
				NextSelectionLeft = props.NextSelectionLeft,
				NextSelectionRight = props.NextSelectionRight,
			},

			cursor = {
				radius = UDim.new(0, currentVariantProps.container.radius),
				offset = use(themeProvider:GetTokenData("Size", "Size_200")),
				borderWidth = use(themeProvider:GetTokenData("Stroke", "Thicker")),
			},

			onActivated = props.onActivated,
			onStateChanged = setControlState,
			isDisabled = use(props.isDisabled) or currentLoading or currentDelaying,
			stateLayer = currentVariantProps.container.stateLayer,
			tag = currentVariantProps.container.tag,
		})

		local buttonChildren = {}
		if isIcon or currentLoading then
			local presenceChildren = {}

			if currentLoading then
				presenceChildren.Spinner = Spinner({
					scope = innerScope,
					Size = currentVariantProps.icon.size - UDim2.fromOffset(0, 0),
					style = Scope:Computed(function(innerUse)
						return {
							Color3 = currentVariantProps.content.style.Color3,
							Transparency = innerUse(motion.transparency),
						}
					end)
				})
			end

			if not currentLoading and isIcon then
				if isBuilderOrMigratedIcon(isIcon) then
					presenceChildren.Icon = Text({
						scope = innerScope,
						Text = if isMigrated(isIcon) then migrationLookup[isIcon].name else isIcon,
						fontStyle = {
							Font = BuilderIcons.Font[if isMigrated(isIcon)
								then migrationLookup[isIcon].variant
								else BuilderIcons.IconVariant.Regular],
							FontSize = currentVariantProps.icon.size.Y.Offset,
						},
						tag = "anchor-center-center position-center-center",
						Size = currentVariantProps.icon.size,
						textStyle = Scope:Computed(function(innerUse)
							return {
								Color3 = currentVariantProps.content.style.Color3,
								Transparency = innerUse(motion.transparency),
							}
						end),
						scale = motion.iconScale,
						[Children] = if textOffset > 0 then {
							innerScope:New("UITextSizeConstraint")({
								MaxTextSize = Scope:Computed(function(innerUse)
									return innerUse(motion.iconScale) * currentVariantProps.icon.size.Y.Offset
								end),
							})
						} else nil
					})
				else
					presenceChildren.Icon = Image({
						scope = innerScope,
						tag = "anchor-center-center position-center-center",
						Image = isIcon,
						Size = if intrinsicIconSize
							then UDim2.fromOffset(intrinsicIconSize.X, intrinsicIconSize.Y)
							else currentVariantProps.icon.size,
						imageStyle = Scope:Computed(function(innerUse)
							return {
								Color3 = currentVariantProps.content.style.Color3,
								Transparency = innerUse(motion.transparency),
							}
						end),
						scale = Scope:Computed(function(innerUse)
							return innerUse(motion.iconScale) * scale
						end)
					})
				end
			end

			local wrapperComponent = if isIcon then View else function(p) return innerScope:New("Folder")(p) end

			buttonChildren.IconWrapper = wrapperComponent({
				scope = innerScope,
				Size = if isIcon then currentVariantProps.icon.size else nil,
				LayoutOrder = if isIcon then (if isEndAligned then 3 else 1) else nil,
				[Children] = presenceChildren
			})
		end

		if hasText then
			buttonChildren.Text = Text({
				scope = innerScope,
				Text = Scope:Computed(formatText),
				RichText = if BUTTON_VARIANT_TO_RICH_TEXT_FORMAT[use(props.variant)] ~= nil then true else false,
				tag = currentVariantProps.text.tag,
				textStyle = Scope:Computed(function(innerUse)
					local disabledTransp = innerUse(motion.transparency)
					local textTransp = innerUse(motion.textTransparency)
					return {
						Color3 = currentVariantProps.content.style.Color3,
						Transparency = if isIcon then disabledTransp else (textTransp + disabledTransp),
					}
				end),
				LayoutOrder = 2
			})
		end

		if currentDelaying then
			buttonChildren.Gradient = innerScope:New("UIGradient")({
				Transparency = Scope:Computed(function(innerUse)
					return onProgressChange(innerUse(progressTween))
				end)
			})
		end

		viewProps[Children] = buttonChildren
		return innerScope:Hydrate(View(viewProps))(stripProps(props, COMPONENT_ONLY_PROPERTIES))
	end)
end