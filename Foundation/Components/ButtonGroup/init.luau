local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local View = require(Components.View)
local Button = require(Components.Button)

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)
local Orientation = require(Enums.Orientation)
local FillBehavior = require(Enums.FillBehavior)
local ButtonVariant = require(Enums.ButtonVariant)

local defaultProps = {
	orientation = Orientation.Horizontal,
	size = InputSize.Medium
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type InputSize = InputSize.InputSize
type ButtonVariant = ButtonVariant.ButtonVariant
type FillBehavior = FillBehavior.FillBehavior
type Orientation = Orientation.Orientation

-- InputSize.Large is not supported by ButtonGroup.
export type ButtonGroupSize = typeof(InputSize.XSmall) | typeof(InputSize.Small) | typeof(InputSize.Medium)

export type ButtonGroupItem = {
	text: UsedAs<string>?,
	icon: UsedAs<string>?,
	onActivated: () -> (),
	variant: UsedAs<ButtonVariant>?,
	isDisabled: UsedAs<boolean>?,
	isLoading: UsedAs<boolean>?,
	inputDelay: UsedAs<number>?
}

export type ButtonGroupProps = {
	scope: Scope,
	buttons: { ButtonGroupItem },
	orientation: UsedAs<Orientation>?,
	fillBehavior: UsedAs<FillBehavior>?,
	size: UsedAs<ButtonGroupSize>?,
} & Types.CommonProps

return function(buttonGroupProps: ButtonGroupProps)
	local scope = buttonGroupProps.scope
	assert(scope, "A scope has not been provided for the ButtonGroup component.")

	local props = withDefaults(buttonGroupProps, defaultProps)
	assert(#props.buttons <= 3, `ButtonGroup: a maximum of 3 buttons is supported, got {#props.buttons}.`)

	return scope:Computed(function(use: Use, innerScope: Scope)
		local size = unwrap(props.size, use)
		local orientation = unwrap(props.orientation, use)
		local fillBehavior = unwrap(props.fillBehavior, use)

		local isVertical = orientation == Orientation.Vertical
		local isFill = isVertical or fillBehavior == FillBehavior.Fill

		-- Horizontal fill: fillBehavior=Fill lets UIFlexItem distribute row space.
		-- Vertical fill: flex-x-fill on the container stretches children without
		-- touching their Size or AutomaticSize.
		local buttonFillBehavior = if not isVertical and isFill then FillBehavior.Fill else nil

		local buttonChildren = {}
		for i, buttonItem in ipairs(props.buttons) do
			buttonChildren["Button" .. i] = Button {
				scope = innerScope,
				text = buttonItem.text,
				icon = buttonItem.icon,
				onActivated = buttonItem.onActivated,
				variant = buttonItem.variant,
				isDisabled = buttonItem.isDisabled,
				isLoading = buttonItem.isLoading,
				inputDelay = buttonItem.inputDelay,
				size = size,
				fillBehavior = buttonFillBehavior,
				LayoutOrder = i
			}
		end

		return View(withCommonProps(props, {
			scope = innerScope,
			tag = {
				["gap-small"] = true,
				["col flex-x-fill"] = isVertical,
				["row"] = not isVertical and isFill,
				["row wrap"] = not isVertical and not isFill,
				["size-full-0 auto-y"] = isFill,
				["auto-xy"] = not isFill
			},
			children = buttonChildren
		}))
	end)
end