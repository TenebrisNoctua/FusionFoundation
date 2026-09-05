local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local RadioGroup = require(script.Parent.RadioGroup)
local RadioGroupItem = require(script.Parent.Item)

local Image = require(Components.Image)
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

local VALUES = { "A", "B", "C", "D", "E" }

local function PlaygroundStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls

	return RadioGroup {
		scope = scope,
		onValueChanged = function(value: string)
			print("Checking value", value)
		end,
		LayoutOrder = props.layoutOrder,
		children = function(groupScope: Scope)
			local items = {}
			for index, value in VALUES do
				items[index] = RadioGroupItem {
					scope = groupScope,
					value = value,
					label = scope:Computed(function(use: Use)
						local optionLabel = unwrap(controls.optionLabel, use)
						return if #optionLabel > 0 then `{optionLabel} {value}` else ""
					end),
					isDisabled = value == "D",
					size = controls.size,
					placement = controls.placement,
					LayoutOrder = index,
				}
			end
			return items
		end
	}
end

local DIFFERENT_LENGTH_ITEMS = {
	{ value = "A", label = "Short" },
	{ value = "B", label = "Medium length label" },
	{ value = "C", label = "A much, much longer label to test wrapping and layout in the radio group" },
	{ value = "D", label = "Tiny" },
	{
		value = "E",
		label = "Extremely long label that spans multiple lines to ensure alignment across items with a label on the left",
	},
}

local function DifferentLabelLengthsStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls

	return View {
		scope = scope,
		tag = "auto-y",
		Size = UDim2.fromOffset(400, 0),
		LayoutOrder = props.layoutOrder,
		children = {
			RadioGroup = RadioGroup {
				scope = scope,
				onValueChanged = function(value: string)
					print("Checking value", value)
				end,
				children = function(groupScope: Scope)
					local items = {}
					for index, item in DIFFERENT_LENGTH_ITEMS do
						items[index] = RadioGroupItem {
							scope = groupScope,
							value = item.value,
							label = item.label,
							size = controls.size,
							placement = controls.placement,
							LayoutOrder = index,
						}
					end
					return items
				end,
			},
		},
	}
end

local function CustomSelectionStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls
	local theme = ThemeProvider()
	local selectedValue = scope:Value(nil :: string?)

	local cursor = scope:Computed(function(use: Use)
		local tokens = unwrap(theme.Tokens, use)
		return {
			radius = UDim.new(0, tokens.Radius.Medium),
			offset = tokens.Size.Size_150,
			borderWidth = tokens.Stroke.Thicker,
		}
	end)

	local function createSelectionCard(cardScope: Scope, value: string, imageName: string, label: string, layoutOrder: number)
		return View {
			scope = cardScope,
			tag = "col align-x-center gap-small auto-xy padding-medium",
			LayoutOrder = layoutOrder,
			children = {
				ImageContainer = View {
					scope = cardScope,
					cursor = cursor,
					onActivated = function()
						selectedValue:set(value)
						print("Selected card:", value)
					end,
					tag = "size-2000-2000 radius-medium bg-surface-100",
					children = {
						Image = Image {
							scope = cardScope,
							Image = imageName,
							Size = UDim2.fromScale(0.8, 0.8),
							Position = UDim2.fromScale(0.1, 0.1),
						},
					},
				},
				RadioButton = RadioGroupItem {
					scope = cardScope,
					value = value,
					label = label,
					placement = controls and controls.placement or nil,
				},
			},
		}
	end

	return RadioGroup {
		scope = scope,
		value = selectedValue,
		onValueChanged = function(value: string)
			selectedValue:set(value)
		end,
		-- Non-selectable since individual cards handle their own selection
		Selectable = false,
		LayoutOrder = props.layoutOrder,
		children = function(groupScope: Scope)
			return {
				Container = View {
					scope = groupScope,
					tag = "row wrap gap-large auto-xy",
					children = {
						CardA = createSelectionCard(groupScope, "A", "icons/graphic/success_xlarge", "Success", 1),
						CardB = createSelectionCard(groupScope, "B", "icons/graphic/error_xlarge", "Error", 2),
						CardC = createSelectionCard(groupScope, "C", "icons/graphic/newclothing_xlarge", "Info", 3),
					},
				},
			}
		end,
	}
end

return {
	fusion = Fusion,
	summary = "Radio Group component",
	controls = {
		optionLabel = "Option",
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
					AutomaticCanvasSize = Enum.AutomaticSize.XY	
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
						title = "Different Label Lengths",
						description = "Items with labels of varying length",
						layoutOrder = 2,
						children = { DifferentLabelLengthsStory { scope = innerScope, controls = controls, layoutOrder = 3 } },
					},
					StorySection {
						scope = innerScope,
						title = "Custom Selection",
						description = "Select images instead of radio buttons",
						layoutOrder = 3,
						children = { CustomSelectionStory { scope = innerScope, controls = controls, layoutOrder = 3 } },
					},
				},
			}
		end)
	end),
}
