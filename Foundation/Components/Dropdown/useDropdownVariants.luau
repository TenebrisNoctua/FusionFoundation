local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Dash = PackageManager.getPackage("Dash")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useVariants = require(Utility.useVariants)
local composeStyleVariant = require(Utility.composeStyleVariant)
local Types = require(Utility.Types)

local IconSize = require(Enums.IconSize)
local InputSize = require(Enums.InputSize)
local ControlState = require(Enums.ControlState)
local InputVariant = require(Enums.InputVariant)
local InputLabelSize = require(Enums.InputLabelSize)

local getInputVariantsFactory = require(Components.InputField.getInputVariantsFactory)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type ColorStyleValue = Types.ColorStyleValue
type Padding = Types.Padding
type ControlState = ControlState.ControlState
type InputSize = InputSize.InputSize
type IconSize = IconSize.IconSize
type InputLabelSize = InputLabelSize.InputLabelSize
type InputVariant = InputVariant.InputVariant
type VariantProps = composeStyleVariant.VariantProps

type DropdownVariantProps = {
	container: {
		bgStyle: ColorStyleValue?,
		strokeStyle: ColorStyleValue?,
		strokeThickness: number,
		tag: string,
	},
	text: { tag: string },
	arrow: { size: IconSize },
}

local function variantsFactory()
	local common = {
		container = {
			tag = {
				["row flex-x-between align-y-center"] = true
			}
		},
		text = {
			tag = {
				["shrink auto-xy text-truncate-split content-emphasis"] = true
			}
		}
	}

	local sizes: { [InputSize]: VariantProps } = {
		[InputSize.XSmall] = {
			container = {
				tag = {
					["gap-small size-full-600 padding-small radius-small"] = true
				}
			},
			text = { tag = "text-body-small" },
			arrow = { size = IconSize.XSmall }
		},
		[InputSize.Small] = {
			container = {
				tag = {
					["gap-small size-full-800 padding-medium radius-medium"] = true
				}
			},
			text = { tag = "text-body-small" },
			arrow = { size = IconSize.Small }
		},
		[InputSize.Medium] = {
			container = {
				tag = {
					["gap-small size-full-1000 padding-medium radius-medium"] = true
				}
			},
			text = { tag = "text-body-medium" },
			arrow = { size = IconSize.Medium }
		},
		[InputSize.Large] = {
			container = {
				tag = {
					["gap-small size-full-1200 padding-medium radius-medium"] = true
				}
			},
			text = { tag = "text-body-large" },
			arrow = { size = IconSize.Large }
		},
	}

	local states: { [ControlState]: VariantProps } = {
		[ControlState.Disabled] = {
			text = { tag = "content-muted" }
		},
		[ControlState.Initialize] = {
			text = { tag = "content-default" }
		}
	}

	-- Placeholder existence should take precendent of content styling in any case.
	-- It should always be content-muted.
	local placeholderStates = Dash.map(states, function(state)
		return Dash.join(state, {
			text = { tag = "content-muted" }
		})
	end)

	return {
		common = common,
		sizes = sizes,
		states = states,
		placeholderStates = placeholderStates
	}
end

return function(
	theme: string,
	tokens: {[string]: any},
	size: InputSize,
	variant: InputVariant,
	controlState: ControlState,
	isPlaceholderShown: boolean,
	hasError: boolean,
	focused: boolean,
	hover: boolean
): DropdownVariantProps
	local props = useVariants(theme, tokens, "Dropdown", variantsFactory)
	local inputProps = useVariants(theme, tokens, "InputField", getInputVariantsFactory)
	local variantAttributes = inputProps.variants[variant or InputVariant.Standard]
	
	return composeStyleVariant(
		inputProps.common,
		props.common,
		inputProps.sizes[size],
		props.sizes[size],
		if variant ~= InputVariant.Utility then variantAttributes else {},
		inputProps.hoverState[hover],
		inputProps.focusedState[focused],
		inputProps.errorState[hasError],
		if isPlaceholderShown then props.placeholderStates[controlState] else props.states[controlState],
		if variant == InputVariant.Utility then variantAttributes else {}
	)
end
