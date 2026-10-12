local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useNumberInputVariants = require(script.Parent.useNumberInputVariants)

local Icon = require(Components.Icon)
local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local blendTransparencies = require(Utility.blendTransparencies)
local Types = require(Utility.Types)

local IconSize = require(Enums.IconSize)
local InputSize = require(Enums.InputSize)
local InputVariant = require(Enums.InputVariant)
local StateLayerAffordance = require(Enums.StateLayerAffordance)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local Constants = require(Foundation.Constants)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type InputSize = InputSize.InputSize
type IconSize = IconSize.IconSize
type InputVariant = InputVariant.InputVariant

type NumberInputControlProps = {
	isDisabled: UsedAs<boolean>,
	onClick: () -> (),
}

type NumberInputControlsProps = {
	-- The scope the component will be created in.
	scope: Scope,
	variant: UsedAs<InputVariant>,
	-- Size of the controls
	size: UsedAs<InputSize>,
	increment: NumberInputControlProps,
	decrement: NumberInputControlProps,
	hasDivider: boolean?,
	LayoutOrder: number?,
}

type IncrementButtonProps = {
	scope: Scope,
	icon: string,
	iconSize: IconSize,
	hasDivider: boolean?,
	isDisabled: UsedAs<boolean>,
	onActivated: () -> (),
	radius: number,
	size: number,
	LayoutOrder: number,
}

local function IncrementButton(props: IncrementButtonProps)
	local theme = ThemeProvider()

	return props.scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local isDisabled = unwrap(props.isDisabled, use) == true
		local foreground = tokens.Color.ActionUtility.Foreground

		return View {
			scope = innerScope,
			onActivated = props.onActivated,
			isDisabled = isDisabled,
			selection = {
				Selectable = not isDisabled,
			},
			stateLayer = {
				affordance = if isDisabled then StateLayerAffordance.None else StateLayerAffordance.Background,
			},
			cursor = {
				radius = UDim.new(0, props.radius),
				offset = tokens.Size.Size_150,
				borderWidth = tokens.Stroke.Thicker
			},
			cornerRadius = UDim.new(0, props.radius),
			Size = UDim2.fromOffset(props.size, props.size),
			LayoutOrder = props.LayoutOrder,
			children = {
				Divider = if props.hasDivider
					then View {
						scope = innerScope,
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.fromScale(0, 0.5),
						Size = UDim2.new(0, tokens.Stroke.Standard, 1, 0),
						backgroundStyle = tokens.Color.Stroke.Default,
					}
					else nil,
				Icon = Icon {
					scope = innerScope,
					name = props.icon,
					size = props.iconSize,
					style = {
						Color3 = foreground.Color3,
						Transparency = if isDisabled
							then blendTransparencies(foreground.Transparency, Constants.DISABLED_TRANSPARENCY)
							else foreground.Transparency,
					},
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
				}
			}
		}
	end)
end

return function(props: NumberInputControlsProps)
	local scope = props.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the NumberInputControls component.")

	return scope:Computed(function(use: Use, innerScope: Scope)
		local variantProps = useNumberInputVariants(unwrap(theme.Theme, use), unwrap(theme.Tokens, use), unwrap(props.size, use))
		local controls = variantProps.controls

		return View {
			scope = innerScope,
			tag = controls.tag,
			Size = UDim2.fromOffset(controls.width, controls.buttonSize),
			LayoutOrder = 1,
			children = {
				ControlDecrement = IncrementButton {
					scope = innerScope,
					icon = BuilderIcons.Icon.MinusSmall,
					iconSize = controls.iconSize,
					isDisabled = props.decrement.isDisabled,
					onActivated = props.decrement.onClick,
					radius = controls.radius,
					size = controls.buttonSize,
					LayoutOrder = 1
				},
				ControlIncrement = IncrementButton {
					scope = innerScope,
					icon = BuilderIcons.Icon.PlusSmall,
					iconSize = controls.iconSize,
					hasDivider = props.hasDivider,
					isDisabled = props.increment.isDisabled,
					onActivated = props.increment.onClick,
					radius = controls.radius,
					size = controls.buttonSize,
					LayoutOrder = 2
				}
			}
		}
	end)
end
