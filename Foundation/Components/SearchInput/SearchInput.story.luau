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
local SearchInputShape = require(Enums.SearchInputShape)

local View = require(Components.View)
local Text = require(Components.Text)
local ScrollView = require(Components.ScrollView)
local SearchInput = require(Components.SearchInput)

type Scope = Types.Scope
type Use = Types.Use

local NONE = "None"

local HAS_CLEAR_BUTTON_CHOICES = {
	NONE,
	false,
	true,
}

local function SearchInputStory(props: {
	scope: Scope,
	controls: any,
	layoutOrder: number?,
	variantOverride: any?,
})
	local scope = props.scope
	local controls = props.controls

	local text = scope:Value("")

	local function handleChange(newText: string)
		print(`[SearchInput] query changed: "{newText}"`)
		text:set(newText)
	end

	local function onFocusGained()
		print("[SearchInput] focus gained!")
	end

	local function onFocusLost(inputObject: InputObject?)
		print(
			"[SearchInput] focus lost!",
			if inputObject then `InputObject: {inputObject.UserInputType.Name}` else "no input object"
		)
	end

	local hasClearButton = scope:Computed(function(use: Use)
		local cb = unwrap(controls.hasClearButton, use)
		return if cb == NONE then nil else cb
	end)

	local width = scope:Computed(function(use: Use)
		local w = unwrap(controls.width, use)
		return if w == 0 then nil else UDim.new(0, w)
	end)

	local placeholder = scope:Computed(function(use: Use)
		local p = unwrap(controls.placeholder, use)
		return if p == "" then nil else p
	end)

	local variant = props.variantOverride or controls.variant

	return View {
		scope = scope,
		LayoutOrder = props.layoutOrder,
		tag = "col gap-large auto-y",
		Size = UDim2.fromOffset(400, 0),
		children = {
			SearchInput = SearchInput {
				scope = scope,
				text = text,
				placeholder = placeholder,
				hasClearButton = hasClearButton,
				hasError = controls.hasError,
				isDisabled = controls.isDisabled,
				shape = controls.shape,
				variant = variant,
				onChanged = handleChange,
				onFocus = onFocusGained,
				onFocusLost = onFocusLost,
				size = controls.size,
				width = width,
				LayoutOrder = 1,
			},
			Output = Text {
				scope = scope,
				Text = text,
				LayoutOrder = 2,
				tag = "auto-xy",
			},
		},
	}
end

return {
	fusion = Fusion,
	summary = "Search input field with leading search icon",
	controls = {
		hasError = false,
		isDisabled = false,
		hasClearButton = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = HAS_CLEAR_BUTTON_CHOICES[1],
			List = HAS_CLEAR_BUTTON_CHOICES,
			DefIndex = 1,
		},
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(InputSize)[1],
			List = Dash.values(InputSize),
			DefIndex = 1,
		},
		shape = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(SearchInputShape)[1],
			List = Dash.values(SearchInputShape),
			DefIndex = 1,
		},
		variant = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(InputVariant)[1],
			List = Dash.values(InputVariant),
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
		placeholder = "",
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
							SearchInputStory {
								scope = innerScope,
								controls = controls,
								layoutOrder = 2,
							},
						},
					},
					StorySection {
						scope = innerScope,
						title = "Standard Variant",
						layoutOrder = 3,
						children = {
							SearchInputStory {
								scope = innerScope,
								controls = controls,
								layoutOrder = 4,
								variantOverride = InputVariant.Standard,
							},
						},
					},
					StorySection {
						scope = innerScope,
						title = "Contrast Variant",
						layoutOrder = 5,
						children = {
							SearchInputStory {
								scope = innerScope,
								controls = controls,
								layoutOrder = 6,
								variantOverride = InputVariant.Contrast,
							},
						},
					},
					StorySection {
						scope = innerScope,
						title = "Utility Variant",
						layoutOrder = 7,
						children = {
							SearchInputStory {
								scope = innerScope,
								controls = controls,
								layoutOrder = 8,
								variantOverride = InputVariant.Utility,
							},
						},
					},
				},
			}
		end)
	end),
}
