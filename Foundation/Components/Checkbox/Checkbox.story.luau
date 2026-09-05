local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Checkbox = require(script.Parent)

local Text = require(Components.Text)
local View = require(Components.View)
local ScrollView = require(Components.ScrollView)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local StorySection = require(Utility.Stories.StorySection)
local CommonControls = require(Utility.Stories.CommonControls)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local InputPlacement = require(Enums.InputPlacement)
local InputSize = require(Enums.InputSize)

type Scope = Types.Scope
type Use = Types.Use
type InputSize = InputSize.InputSize

local function PlaygroundStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls
	local isChecked = scope:Value(true)

	return Checkbox {
		scope = scope,
		isChecked = isChecked,
		isDisabled = controls.isDisabled,
		onActivated = function()
			isChecked:set(not unwrap(isChecked))
		end,
		size = controls.size,
		label = controls.label,
		placement = controls.placement,
		LayoutOrder = props.layoutOrder,
	}
end

local function SizesStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	local sizes: { InputSize } = { InputSize.Large, InputSize.Medium, InputSize.Small, InputSize.XSmall }

	local checkedBySize = {}
	for _, size in sizes do
		checkedBySize[size] = scope:Value(true)
	end

	local children = {}
	for index, size in sizes do
		children[size] = Checkbox {
			scope = scope,
			isChecked = checkedBySize[size],
			onActivated = function()
				checkedBySize[size]:set(not unwrap(checkedBySize[size]))
			end,
			size = size,
			label = "Label",
			placement = InputPlacement.Start,
			LayoutOrder = index,
		}
	end

	return View {
		scope = scope,
		tag = "auto-xy col gap-xxlarge",
		LayoutOrder = props.layoutOrder,
		children = children
	}
end

local function CustomSelectionStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	local theme = ThemeProvider()
	local isChecked = scope:Value(true)

	local function toggle()
		isChecked:set(not unwrap(isChecked))
	end

	local cursor = scope:Computed(function(use: Use)
		local tokens = unwrap(theme.Tokens, use)
		return {
			radius = UDim.new(0, tokens.Radius.Medium),
			offset = tokens.Size.Size_150,
			borderWidth = tokens.Stroke.Thicker,
		}
	end)

	return View {
		scope = scope,
		cursor = cursor,
		onActivated = toggle,
		tag = "col align-x-center align-y-center gap-medium auto-y padding-large stroke-muted radius-medium bg-surface-100",
		Size = UDim2.fromOffset(300, 120),
		LayoutOrder = props.layoutOrder,
		children = {
			Checkbox {
				scope = scope,
				isChecked = isChecked,
				onActivated = toggle,
				size = InputSize.Medium,
				label = "Enable notifications",
				placement = InputPlacement.Start,
				-- Non-selectable since the parent card handles selection
				Selectable = false,
				LayoutOrder = 1,
			},
			Text {
				scope = scope,
				Text = "Get notified when someone mentions you or sends you a message",
				tag = "size-full-0 auto-y text-body-small text-wrap content-muted",
				LayoutOrder = 2,
			},
		},
	}
end

local function IndeterminateStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	local isChecked1 = scope:Value(false)
	local isChecked2 = scope:Value(false)
	local isChecked3 = scope:Value(true)

	local isAggregationChecked = scope:Computed(function(use: Use)
		return unwrap(isChecked1, use) or unwrap(isChecked2, use) or unwrap(isChecked3, use)
	end)
	local isAggregationIndeterminate = scope:Computed(function(use: Use)
		local a, b, c = unwrap(isChecked1, use), unwrap(isChecked2, use), unwrap(isChecked3, use)
		return a ~= b or b ~= c
	end)

	return View {
		scope = scope,
		tag = "col gap-medium size-3000-0 auto-xy",
		LayoutOrder = props.layoutOrder,
		children = {
			Aggregation = Checkbox {
				scope = scope,
				LayoutOrder = 1,
				isChecked = isAggregationChecked,
				isIndeterminate = isAggregationIndeterminate,
				onActivated = function(value: boolean)
					isChecked1:set(value)
					isChecked2:set(value)
					isChecked3:set(value)
				end,
				size = InputSize.Medium,
				label = "",
				placement = InputPlacement.Start,
			},
			Check1 = Checkbox {
				scope = scope,
				LayoutOrder = 2,
				isChecked = isChecked1,
				onActivated = function(value: boolean)
					isChecked1:set(value)
				end,
				size = InputSize.Medium,
				label = "Item 1",
				placement = InputPlacement.Start,
			},
			Check2 = Checkbox {
				scope = scope,
				LayoutOrder = 3,
				isChecked = isChecked2,
				onActivated = function(value: boolean)
					isChecked2:set(value)
				end,
				size = InputSize.Medium,
				label = "Item 2",
				placement = InputPlacement.Start,
			},
			Check3 = Checkbox {
				scope = scope,
				LayoutOrder = 4,
				isChecked = isChecked3,
				onActivated = function(value: boolean)
					isChecked3:set(value)
				end,
				size = InputSize.Medium,
				label = "Item 3",
				placement = InputPlacement.Start,
			},
		},
	}
end

local function UncontrolledStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope

	return View {
		scope = scope,
		tag = "col size-3000-0 auto-xy",
		LayoutOrder = props.layoutOrder,
		children = {
			Checkbox {
				scope = scope,
				onActivated = function(value: boolean)
					print("isChecked: ", value)
				end,
				size = InputSize.Medium,
				label = "Label",
				placement = InputPlacement.Start,
			},
		},
	}
end

return {
	fusion = Fusion,
	summary = "Checkbox component",
	controls = {
		isDisabled = false,
		label = "Label",
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = InputSize.Medium,
			List = Dash.values(InputSize),
			DefIndex = 3,
		},
		placement = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = InputPlacement.Start,
			List = Dash.values(InputPlacement),
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
				tag = "col size-full padding-large gap-xxlarge",
				scroll = {
					AutomaticCanvasSize = Enum.AutomaticSize.Y	
				},
				children = {
					StorySection {
						scope = innerScope,
						title = "Playground",
						layoutOrder = 1,
						children = { PlaygroundStory { scope = innerScope, controls = controls, layoutOrder = 2 } },
					},
					StorySection {
						scope = innerScope,
						title = "Sizes",
						description = "Checkbox rendered at every supported size",
						layoutOrder = 2,
						children = { SizesStory { scope = innerScope, layoutOrder = 3 } },
					},
					StorySection {
						scope = innerScope,
						title = "Custom Selection",
						description = "Select card container instead of checkbox",
						layoutOrder = 3,
						children = { CustomSelectionStory { scope = innerScope, layoutOrder = 3 } },
					},
					StorySection {
						scope = innerScope,
						title = "Indeterminate",
						description = "A checkbox with an indeterminate state. Useful for aggregating other checkboxes",
						layoutOrder = 4,
						children = { IndeterminateStory { scope = innerScope, layoutOrder = 3 } },
					},
					StorySection {
						scope = innerScope,
						title = "Uncontrolled",
						description = "State is controlled by the checkbox itself",
						layoutOrder = 5,
						children = { UncontrolledStory { scope = innerScope, layoutOrder = 3 } },
					}
				}
			}
		end)
	end)
}

