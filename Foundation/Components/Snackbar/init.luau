local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Icon = require(Components.Icon)
local Text = require(Components.Text)
local View = require(Components.View)
local CloseAffordance = require(Components.CloseAffordance)

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local useScaledValue = require(Utility.useScaledValue)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)
local ColorNamespace = require(Enums.ColorNamespace)
local StateLayerMode = require(Enums.StateLayerMode)
local CloseAffordanceVariant = require(Enums.CloseAffordanceVariant)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local PresentationContext = require(Foundation.Providers.ThemeProvider.PresentationContext)

local SNACKBAR_DEFAULT_MAX_WIDTH = 272
local SNACKBAR_WITH_ICON_MAX_WIDTH = 304
local SNACKBAR_WITH_BUTTONS_FIXED_WIDTH = 371

local MAX_LINES = 2
local IS_INVERSE = table.freeze { colorNamespace = ColorNamespace.Inverse, isIconSize = false }

local defaultProps = {}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type IconVariant = typeof(BuilderIcons.IconVariant)

type SnackbarIcon = {
	name: string,
	variant: IconVariant?
}

export type SnackbarAction = {
	onActivated: () -> (),
	text: string
}

export type SnackbarProps = {
	scope: Scope,
	action: UsedAs<SnackbarAction?>?,
	icon: UsedAs<(string | SnackbarIcon)?>?,
	onClose: (() -> ())?,
	title: UsedAs<string>
} & Types.CommonProps

return function(snackbarProps: SnackbarProps)
	local scope = snackbarProps.scope
	assert(scope, "A scope has not been provided for the Snackbar component.")

	local theme = ThemeProvider()
	local props = withDefaults(snackbarProps, defaultProps)
	
	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local icon = unwrap(props.icon, use)
		local action = unwrap(props.action, use)
		local title = unwrap(props.title, use)

		local hasIcon = icon ~= nil and icon ~= ""
		local hasAction = action ~= nil and action.text ~= ""
		local hasButton = hasAction or props.onClose ~= nil
		local hasIconOrButton = hasIcon or hasButton

		local scaledFixedWidth = useScaledValue(SNACKBAR_WITH_BUTTONS_FIXED_WIDTH, use)
		local scaledMaxWidth =
			useScaledValue(if hasIcon then SNACKBAR_WITH_ICON_MAX_WIDTH else SNACKBAR_DEFAULT_MAX_WIDTH, use)

		local iconProps: SnackbarIcon? = if typeof(icon) == "string"
			then { name = icon :: string, variant = BuilderIcons.IconVariant.Regular }
			else icon :: SnackbarIcon?

		local titleFontSize = tokens.Typography.CaptionLarge.FontSize
		local titleLineHeight = tokens.Typography.CaptionLarge.LineHeight
		local maxTitleHeight = titleFontSize * titleLineHeight * MAX_LINES

		return View(withCommonProps(props, {
			scope = innerScope,
			Size = if hasButton then UDim2.fromOffset(scaledFixedWidth, 0) else UDim2.fromOffset(0, 0),
			sizeConstraint = if hasButton
				then nil
				else {
					MinSize = Vector2.new(0, 0),
					MaxSize = Vector2.new(scaledMaxWidth, math.huge)
				},
			tag = {
				["row align-y-center gap-large padding-y-xsmall radius-medium bg-system-contrast"] = true,
				["padding-left-large"] = not hasIconOrButton,
				["padding-left-medium"] = hasIconOrButton,
				["auto-xy padding-right-large"] = not hasButton,
				["auto-y padding-right-small"] = hasButton
			},
			children = PresentationContext.Context:is(IS_INVERSE):during(function()
				return {
					Content = View {
						scope = innerScope,
						LayoutOrder = 1,
						tag = "row align-y-center fill gap-small auto-xy padding-y-small",
						children = {
							Icon = if hasIcon and iconProps
								then Icon {
									scope = innerScope,
									name = iconProps.name,
									variant = iconProps.variant,
									style = tokens.Inverse.Content.Emphasis,
									LayoutOrder = 1
								}
								else nil,
							Title = Text {
								scope = innerScope,
								LayoutOrder = 2,
								Text = title,
								sizeConstraint = {
									MinSize = Vector2.new(0, 0),
									MaxSize = Vector2.new(math.huge, maxTitleHeight)
								},
								tag = "fill auto-xy text-caption-large text-wrap text-align-x-left text-truncate-split content-inverse-emphasis"
							}
						}
					},
					Buttons = if hasButton
						then View {
							scope = innerScope,
							LayoutOrder = 2,
							tag = "row align-y-center gap-xsmall auto-xy",
							children = {
								Action = if hasAction
									then Text {
										scope = innerScope,
										LayoutOrder = 1,
										onActivated = action.onActivated,
										stateLayer = {
											mode = StateLayerMode.Inverse,
										},
										Text = action.text,
										tag = "auto-xy padding-small text-label-medium radius-medium content-inverse-link"
									}
								else nil,
								CloseAffordance = if props.onClose ~= nil
									then CloseAffordance {
										scope = innerScope,
										LayoutOrder = 2,
										onActivated = props.onClose,
										size = InputSize.Small,
										variant = CloseAffordanceVariant.Utility,
									}
								else nil
							}
						}
					else nil
				}
			end)
		}))
	end)
end
