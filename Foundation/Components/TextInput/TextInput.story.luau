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
local ButtonVariant = require(Enums.ButtonVariant)

local View = require(Components.View)
local Text = require(Components.Text)
local Button = require(Components.Button)
local ScrollView = require(Components.ScrollView)
local TextInput = require(Components.TextInput)

type Scope = Types.Scope
type Use = Types.Use

local NONE = "None"

local LEADING_ICON_CHOICES = {
	"icons/placeholder/placeholderOn_small",
	"icons/status/private_small",
	"icons/common/search_small",
	NONE,
}

local TRAILING_ICON_CHOICES = {
	"icons/placeholder/placeholderOff",
	"icons/actions/edit/clear_small",
	"icons/actions/info_small",
	"icons/actions/viewOn",
	"icons/actions/viewOff",
	NONE,
}

local TEXT_INPUT_TYPE_CHOICES = {
	NONE,
	"Default",
	"Password",
	"Number",
}

local FOCUS_BEHAVIOR_CHOICES = {
	NONE,
	InputFocusBehavior.Clear,
	InputFocusBehavior.Highlight,
}

local IS_REQUIRED_CHOICES = {
	NONE,
	false,
	true,
}

local HAS_CLEAR_BUTTON_CHOICES = {
	NONE,
	false,
	true,
}

local function TextInputStory(props: {
	scope: Scope,
	controls: any,
	layoutOrder: number?,
})
	local scope = props.scope
	local controls = props.controls

	local text = scope:Value("")
	local numReturnPressed = scope:Value(0)
	local textBoxRef = scope:Value(nil)

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

	local function onFocusGained()
		print("focus gained!")
	end

	local function onFocusLost(inputObject: InputObject?)
		print("focus lost!", if inputObject then `InputObject: {inputObject.UserInputType.Name}` else "no input object")
	end

	local function gainFocus()
		local ref = unwrap(textBoxRef)
		if ref and ref.focus then
			ref.focus()
		end
	end

	local leadingIcon = scope:Computed(function(use: Use)
		local icon = unwrap(controls.leadingIcon, use)
		return if icon == NONE then nil else icon
	end)

	local iconTrailing = scope:Computed(function(use: Use)
		local icon = unwrap(controls.iconTrailing, use)
		if icon == NONE then return nil end
		local useTrailingButton = unwrap(controls.trailingButton, use)
		if useTrailingButton then
			return {
				name = icon,
				onActivated = onTrailingButtonActivated,
			}
		end
		return icon
	end)

	local focusBehavior = scope:Computed(function(use: Use)
		local behavior = unwrap(controls.focusBehavior, use)
		return if behavior == NONE then nil else behavior
	end)

	local textInputType = scope:Computed(function(use: Use)
		local inputType = unwrap(controls.textInputType, use)
		return if inputType == NONE then nil else Enum.TextInputType:FromName(inputType)
	end)

	local isRequired = scope:Computed(function(use: Use)
		local req = unwrap(controls.isRequired, use)
		return if req == NONE then nil else req
	end)

	local hasClearButton = scope:Computed(function(use: Use)
		local cb = unwrap(controls.hasClearButton, use)
		return if cb == NONE then nil else cb
	end)

	local width = scope:Computed(function(use: Use)
		local w = unwrap(controls.width, use)
		return if w == 0 then nil else UDim.new(0, w)
	end)

	local hint = scope:Computed(function(use: Use)
		local h = unwrap(controls.hint, use)
		return if h == "" then nil else h
	end)

	return View {
		scope = scope,
		LayoutOrder = props.layoutOrder,
		tag = "col gap-large auto-y",
		Size = UDim2.fromOffset(400, 0),
		children = {
			TextInput = TextInput {
				scope = scope,
				text = text,
				textInputType = textInputType,
				focusBehavior = focusBehavior,
				hasClearButton = hasClearButton,
				variant = controls.variant,
				hasError = controls.hasError,
				isDisabled = controls.isDisabled,
				isRequired = isRequired,
				onChanged = handleChange,
				onFocus = onFocusGained,
				onFocusLost = onFocusLost,
				onReturnPressed = onReturnPressed,
				label = controls.label,
				size = controls.size,
				width = width,
				hint = hint,
				placeholder = controls.placeholder,
				leadingIcon = leadingIcon,
				iconTrailing = iconTrailing,
				textBoxRef = textBoxRef,
				LayoutOrder = 1,
			},
			Output = Text {
				scope = scope,
				Text = text,
				LayoutOrder = 2,
				tag = "auto-xy",
			},
			FocusButton = Button {
				scope = scope,
				text = "Focus TextInput",
				onActivated = gainFocus,
				variant = ButtonVariant.Standard,
				LayoutOrder = 3,
			},
			NumReturnPressed = scope:Computed(function(use: Use, innerScope: Scope)
				return Text {
					scope = innerScope,
					LayoutOrder = 4,
					Text = "Num return pressed: " .. tostring(unwrap(numReturnPressed, use)),
					tag = "auto-xy",
				}
			end),
		},
	}
end

return {
	fusion = Fusion,
	summary = "Text field",
	controls = {
		hasError = false,
		isDisabled = false,
		isRequired = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = IS_REQUIRED_CHOICES[1],
			List = IS_REQUIRED_CHOICES,
			DefIndex = 1,
		},
		focusBehavior = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = FOCUS_BEHAVIOR_CHOICES[1],
			List = FOCUS_BEHAVIOR_CHOICES,
			DefIndex = 1,
		},
		hasClearButton = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = HAS_CLEAR_BUTTON_CHOICES[1],
			List = HAS_CLEAR_BUTTON_CHOICES,
			DefIndex = 1,
		},
		textInputType = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = TEXT_INPUT_TYPE_CHOICES[1],
			List = TEXT_INPUT_TYPE_CHOICES,
			DefIndex = 1,
		},
		variant = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(InputVariant)[1],
			List = Dash.values(InputVariant),
			DefIndex = 1,
		},
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(InputSize)[1],
			List = Dash.values(InputSize),
			DefIndex = 1,
		},
		label = "Input Label",
		hint = "Helper text goes here",
		placeholder = "Placeholder text",
		leadingIcon = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = LEADING_ICON_CHOICES[1],
			List = LEADING_ICON_CHOICES,
			DefIndex = 1,
		},
		iconTrailing = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = TRAILING_ICON_CHOICES[1],
			List = TRAILING_ICON_CHOICES,
			DefIndex = 1,
		},
		trailingButton = false,
		width = {
			EntryType = "Control",
			Type = "Slider",
			ControlValue = 0,
			Min = 0,
			Max = 500,
			Step = 10,
		},
		theme = CommonControls.theme,
	},
	story = StoryMiddleware(function(props)
		local scope = props.scope
		local controls = props.controls

		return scope:Computed(function(use: Use, innerScope: Scope)
			unwrap(controls.theme, use)

			return ScrollView {
				scope = innerScope,
				scroll = {
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
				},
				tag = "size-full padding-x-large padding-top-large col",
				children = {
					StorySection {
						scope = innerScope,
						title = "Playground",
						layoutOrder = 1,
						children = {
							TextInputStory {
								scope = innerScope,
								controls = controls,
								layoutOrder = 2,
							},
						},
					},
				},
			}
		end)
	end),
}
