local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useDropdownVariants = require(script.Parent.useDropdownVariants)

local View = require(Components.View)
local Icon = require(Components.Icon)
local Text = require(Components.Text)
local BaseMenu = require(Components.BaseMenu)
local InputField = require(Components.InputField)

local unwrap = require(Utility.unwrap)
local isState = require(Utility.isState)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local getInputTextSize = require(Utility.getInputTextSize)
local blendTransparencies = require(Utility.blendTransparencies)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)
local CursorType = require(Enums.CursorType)
local ControlState = require(Enums.ControlState)
local InputVariant = require(Enums.InputVariant)
local StateLayerAffordance = require(Enums.StateLayerAffordance)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local Constants = require(Foundation.Constants)

local MENU_OPEN_IMAGE = BuilderIcons.Icon.ChevronLargeUp
local MENU_CLOSE_IMAGE = BuilderIcons.Icon.ChevronLargeDown

local defaultProps = {
	variant = InputVariant.Standard,
	isMenuOpen = false,
	placeholder = "",
	Selectable = true
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

type ControlState = ControlState.ControlState
type CursorType = CursorType.CursorType
type InputSize = InputSize.InputSize
type InputVariant = InputVariant.InputVariant
type BaseMenuItem = BaseMenu.BaseMenuItem

type DropdownControlProps = {
	scope: Scope,
	variant: UsedAs<InputVariant>?,
	hasError: UsedAs<boolean>?,
	isDisabled: UsedAs<boolean>?,
	item: UsedAs<BaseMenuItem>?,
	placeholder: UsedAs<string>?,
	onActivated: () -> (),
	isMenuOpen: UsedAs<boolean>,
	width: UsedAs<UDim>,
	size: UsedAs<InputSize>,
	label: UsedAs<string>,
	hint: UsedAs<string>?,
	inputRef: UsedAs<GuiObject>?
} & Types.SelectionProps & Types.CommonProps

return function(dropdownControlProps: DropdownControlProps)
	local scope = dropdownControlProps.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the DropdownControl component.")

	local props = withDefaults(dropdownControlProps, defaultProps)
	local controlState = scope:Value(ControlState.Initialize :: ControlState)

	local function onStateChanged(newState: ControlState)
		controlState:set(newState)
	end

	local function setInputRef(instance: GuiObject?)
		if isState(props.inputRef) then
			props.inputRef:set(instance)
		end
	end
	
	local selectable = scope:Computed(function(use: Use)
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
		NextSelectionRight = props.NextSelectionRight
	}

	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local size = unwrap(props.size, use)
		local variant = unwrap(props.variant, use) or InputVariant.Standard

		local cursor = {
			radius = UDim.new(0, tokens.Radius.Small),
			offset = tokens.Size.Size_200,
			borderWidth = tokens.Stroke.Thicker
		}

		return InputField(withCommonProps(props, {
			scope = innerScope,
			size = getInputTextSize(size),
			hasError = props.hasError,
			isDisabled = props.isDisabled,
			label = props.label,
			hint = props.hint,
			width = props.width,
			input = function(childScope: Scope, textBoxRef: UsedAs<any?>)
				return childScope:Computed(function(use: Use, innerScope: Scope)
					local currentItem = unwrap(props.item, use)
					local currentIsMenuOpen = unwrap(props.isMenuOpen, use)
					local showPlaceholder = currentItem == nil
					
					local variantProps = innerScope:Computed(function(use: Use)
						local currentIsDisabled = unwrap(props.isDisabled, use)
						local currentControlState = if currentIsDisabled
							then ControlState.Disabled
							else unwrap(controlState, use)
						return useDropdownVariants(
							unwrap(theme.Theme),
							tokens,
							size,
							variant,
							currentControlState,
							showPlaceholder,
							unwrap(props.hasError, use),
							currentIsMenuOpen,
							currentControlState == ControlState.Hover
						)
					end)
					
					local backgroundStyle = innerScope:Computed(function(use: Use) 
						local variantProps = unwrap(variantProps, use)
						local currentIsDisabled = unwrap(props.isDisabled)
						return if variantProps.container.bgStyle then {
							Color3 = variantProps.container.bgStyle.Color3,
							Transparency = if currentIsDisabled
								then blendTransparencies(variantProps.container.bgStyle.Transparency, Constants.DISABLED_TRANSPARENCY)
								else variantProps.container.bgStyle.Transparency
						} else nil
					end)
					
					local strokeProps = innerScope:Computed(function(use: Use) 
						local variantProps = unwrap(variantProps, use)
						local currentIsDisabled = unwrap(props.isDisabled)
						return if variantProps.container.strokeStyle then {
							Color = variantProps.container.strokeStyle.Color3,
							Transparency = if currentIsDisabled
							then blendTransparencies(variantProps.container.strokeStyle.Transparency, Constants.DISABLED_TRANSPARENCY)
							else variantProps.container.strokeStyle.Transparency,
							Thickness = variantProps.container.strokeThickness,
							BorderStrokePosition = Enum.BorderStrokePosition.Inner
						} else nil
					end)
					
					local tag = innerScope:Computed(function(use: Use)
						return unwrap(variantProps, use).container.tag
					end)
					
					local textTag = innerScope:Computed(function(use: Use) 
						return unwrap(variantProps, use).text.tag
					end)
					
					local arrowSize = innerScope:Computed(function(use: Use) 
						return unwrap(variantProps, use).arrow.size	
					end)

					local viewInstance = unwrap(View {
						Name = "DropdownControl",
						scope = innerScope,
						onStateChanged = onStateChanged,
						isDisabled = props.isDisabled,
						onActivated = props.onActivated,
						selection = selectionProps,
						cursor = cursor,
						stateLayer = { affordance = StateLayerAffordance.None },
						backgroundStyle = backgroundStyle,
						stroke = strokeProps,
						tag = tag,
						children = {
							Text = Text {
								Name = "Text",
								scope = innerScope,
								LayoutOrder = 1,
								Text = if currentItem then currentItem.text else unwrap(props.placeholder, use),
								tag = textTag
							},
							Arrow = Icon {
								Name = "Arrow",
								scope = innerScope,
								LayoutOrder = 2,
								name = if currentIsMenuOpen then MENU_OPEN_IMAGE else MENU_CLOSE_IMAGE,
								size = arrowSize,
								style = innerScope:Computed(function(use: Use) 
									local currentIsDisabled = unwrap(props.isDisabled, use)
									return if currentIsDisabled then tokens.Color.Content.Muted else nil
								end),
								tag = textTag
							}
						}
					})

					setInputRef(viewInstance)
					return viewInstance
				end)
			end
		}))
	end)
end