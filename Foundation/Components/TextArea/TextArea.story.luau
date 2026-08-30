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
local TextArea = require(Components.TextArea)

type Scope = Types.Scope
type Use = Types.Use

local NONE = "None"

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

local function TextAreaStory(props: {
	scope: Scope,
	controls: any,
	layoutOrder: number?,
})
	local scope = props.scope
	local controls = props.controls

	local text = scope:Value("")
	local textBoxRef = scope:Value(nil)

	local function handleChange(newText: string)
		text:set(newText)
	end

	local function gainFocus()
		local ref = unwrap(textBoxRef)
		if ref and ref.focus then
			ref.focus()
		end
	end

	local focusBehavior = scope:Computed(function(use: Use)
		local behavior = unwrap(controls.focusBehavior, use)
		return if behavior == NONE then nil else behavior
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
			TextArea = TextArea {
				scope = scope,
				text = text,
				hasError = controls.hasError,
				isDisabled = controls.isDisabled,
				isRequired = isRequired,
				variant = controls.variant,
				focusBehavior = focusBehavior,
				onChanged = handleChange,
				label = controls.label,
				hint = hint,
				size = controls.size,
				width = width,
				hasClearButton = hasClearButton,
				numLines = controls.numLines,
				placeholder = controls.placeholder,
				textBoxRef = textBoxRef,
				LayoutOrder = 1,
			},
			Output = Text {
				scope = scope,
				Text = text,
				LayoutOrder = 2,
				tag = "size-full-0 auto-y text-wrap text-align-x-left",
			},
			FocusButton = Button {
				scope = scope,
				text = "Focus TextArea",
				onActivated = gainFocus,
				variant = ButtonVariant.Standard,
				LayoutOrder = 3,
			},
		},
	}
end

return {
	fusion = Fusion,
	summary = "TextArea",
	controls = {
		hasError = false,
		isDisabled = false,
		numLines = {
			EntryType = "Control",
			Type = "Slider",
			ControlValue = 4,
			Min = 1,
			Max = 10,
			Step = 1,
		},
		variant = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(InputVariant)[1],
			List = Dash.values(InputVariant),
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
		width = {
			EntryType = "Control",
			Type = "Slider",
			ControlValue = 0,
			Min = 0,
			Max = 500,
			Step = 10,
		},
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(InputSize)[1],
			List = Dash.values(InputSize),
			DefIndex = 1,
		},
		label = "Biography",
		hint = "1000 characters maximum",
		placeholder = "Tell us your life story!",
		isRequired = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = IS_REQUIRED_CHOICES[1],
			List = IS_REQUIRED_CHOICES,
			DefIndex = 1,
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
							TextAreaStory {
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
