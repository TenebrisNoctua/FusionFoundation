local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Utility = Foundation.Utility
local Enums = Foundation.Enums
local Components = Foundation.Components

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local StorySection = require(Utility.Stories.StorySection)
local CommonControls = require(Utility.Stories.CommonControls)

local InputSize = require(Enums.InputSize)
local InputVariant = require(Enums.InputVariant)
local InputFocusBehavior = require(Enums.InputFocusBehavior)
local Radius = require(Enums.Radius)
local IconSize = require(Enums.IconSize)

local View = require(Components.View)
local Text = require(Components.Text)
local Icon = require(Components.Icon)
local ScrollView = require(Components.ScrollView)
local IconButton = require(Components.IconButton)
local BaseTextInput = require(Components.BaseTextInput)

type Scope = Types.Scope
type Use = Types.Use

-- "None" is used as a control sentinel value for optional Choose controls whose
-- underlying type has no built-in "unset" member (unlike Radius, which already
-- has a first-class Radius.None), and is mapped back to nil below.
local NONE = "None"

local LEADING_ICON_CHOICES = {
	NONE,
	"icons/common/search_small",
	"icons/status/private_small"
}

local TRAILING_ICON_CHOICES = {
	NONE,
	"icons/actions/edit/clear_small",
	"icons/actions/info_small"
}

local TEXT_INPUT_TYPE_CHOICES = {
	"Default",
	"Password",
	"Number"
}

local FOCUS_BEHAVIOR_CHOICES = {
	NONE,
	InputFocusBehavior.Clear,
	InputFocusBehavior.Highlight
}

local function TextInputStory(props: {
	scope: Scope,
	controls: any,
	layoutOrder: number?,
	numLinesOverride: number?,
	placeholderOverride: string?
})
	local scope = props.scope
	local controls = props.controls

	local text = scope:Value("")
	local numReturnPressed = scope:Value(0)

	local function handleChange(newText: string)
		text:set(newText)
	end

	local function onReturnPressed()
		print("Return pressed!")
		numReturnPressed:set(unwrap(numReturnPressed) + 1)
	end

	local function onTrailingButtonActivated()
		print("press!")
	end
	
	local leadingElement = scope:Computed(function(use: Use) 
		local iconName = unwrap(controls.leadingIcon, use)
		if iconName == NONE then return end
		
		return function(childScope: Scope)
			return Icon {
				scope = childScope,
				name = iconName,
				size = IconSize.Small
			}
		end
	end)
	
	local trailingElement = scope:Computed(function(use: Use) 
		local iconName = unwrap(controls.trailingIcon, use)
		if iconName == NONE then return end

		return function(childScope: Scope)
			return IconButton {
				scope = childScope,
				icon = iconName,
				onActivated = onTrailingButtonActivated,
				isDisabled = controls.isDisabled,
				size = IconSize.Small
			}
		end
	end)

	local focusBehavior = scope:Computed(function(use: Use)
		local behavior = unwrap(controls.focusBehavior, use)
		return if behavior == NONE then nil else behavior
	end)
	
	local textInputType = scope:Computed(function(use: Use) 
		local inputType = unwrap(controls.textInputType, use)
		return Enum.TextInputType:FromName(inputType) or Enum.TextInputType.Default
	end)

	return View {
		scope = scope,
		LayoutOrder = props.layoutOrder,
		tag = "col gap-large auto-y",
		Size = UDim2.fromOffset(400, 0),
		children = {
			Input = BaseTextInput {
				scope = scope,
				text = text,
				size = controls.size,
				variant = controls.variant,
				radius = controls.radius,
				hasError = controls.hasError,
				isDisabled = controls.isDisabled,
				numLines = props.numLinesOverride or controls.numLines,
				focusBehavior = focusBehavior,
				hasClearButton = controls.hasClearButton,
				onChanged = handleChange,
				onReturnPressed = onReturnPressed,
				placeholder = props.placeholderOverride or controls.placeholder,
				leadingElement = leadingElement,
				trailingElement = trailingElement,
				textInputType = textInputType,
				LayoutOrder = 1
			},
			Output = Text {
				scope = scope,
				Text = text,
				LayoutOrder = 2,
				tag = "auto-xy"
			},
			NumReturnPressed = scope:Computed(function(use: Use, innerScope: Scope)
				return Text {
					scope = innerScope,
					LayoutOrder = 3,
					Text = "Num return pressed: " .. tostring(unwrap(numReturnPressed, use)),
					tag = "auto-xy"
				}
			end)
		}
	}
end

local function StoryPlayground(props)
	return TextInputStory {
		scope = props.scope,
		controls = props.controls,
		layoutOrder = props.layoutOrder,
	}
end

local function StoryMultiLine(props)
	local nums = {}
	for i = 1, 1000 do
		table.insert(nums, i)
	end

	return TextInputStory {
		scope = props.scope,
		controls = props.controls,
		layoutOrder = props.layoutOrder,
		numLinesOverride = 3,
		placeholderOverride = table.concat(nums, "\n")
	}
end

return {
	fusion = Fusion,
	summary = "Base text input",
	controls = {
		hasError = false,
		isDisabled = false,
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(InputSize)[1],
			List = Dash.values(InputSize),
			DefIndex = 1,
		},
		variant = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(InputVariant)[1],
			List = Dash.values(InputVariant),
			DefIndex = 1,
		},
		radius = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(Radius)[1],
			List = Dash.values(Radius),
			DefIndex = 1,
		},
		numLines = 1,
		focusBehavior = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = FOCUS_BEHAVIOR_CHOICES[1],
			List = FOCUS_BEHAVIOR_CHOICES,
			DefIndex = 1,
		},
		hasClearButton = true,
		placeholder = "Placeholder text",
		leadingIcon = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = LEADING_ICON_CHOICES[1],
			List = LEADING_ICON_CHOICES,
			DefIndex = 1,
		},
		trailingIcon = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = TRAILING_ICON_CHOICES[1],
			List = TRAILING_ICON_CHOICES,
			DefIndex = 1,
		},
		textInputType = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = TEXT_INPUT_TYPE_CHOICES[1],
			List = TEXT_INPUT_TYPE_CHOICES,
			DefIndex = 1,
		},
		theme = CommonControls.theme
	},
	story = StoryMiddleware(function(props)
		local scope = props.scope
		local controls = props.controls

		return scope:Computed(function(use: Use, innerScope: Scope)
			unwrap(controls.theme, use)

			return ScrollView {
				scope = innerScope,
				scroll = {
					AutomaticCanvasSize = Enum.AutomaticSize.Y	
				},
				tag = "size-full padding-x-large padding-top-large col",
				children = {
					StorySection {
						scope = innerScope,
						title = "Playground",
						layoutOrder = 1,
						children = {
							StoryPlayground {
								scope = innerScope,
								controls = controls,
								layoutOrder = 2,
							}
						}
					},

					StorySection {
						scope = innerScope,
						title = "Multi-line",
						description = "numLines is fixed at 3 and the placeholder is a long block of text, independent of the shared controls above.",
						layoutOrder = 2,
						children = {
							StoryMultiLine {
								scope = innerScope,
								controls = controls,
								layoutOrder = 2,
							}
						}
					}
				}
			}
		end)
	end)
}
