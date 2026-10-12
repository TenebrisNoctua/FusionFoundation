local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local NumberInput = require(script.Parent)

local Text = require(Components.Text)
local View = require(Components.View)
local Button = require(Components.Button)
local ScrollView = require(Components.ScrollView)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local StorySection = require(Utility.Stories.StorySection)
local CommonControls = require(Utility.Stories.CommonControls)

local InputSize = require(Enums.InputSize)
local InputVariant = require(Enums.InputVariant)
local ScrubBehavior = require(Enums.ScrubBehavior)
local InputFocusBehavior = require(Enums.InputFocusBehavior)
local OnChangeCallbackReason = require(Enums.OnChangeCallbackReason)

type Scope = Types.Scope
type Use = Types.Use

type OnChangeCallbackReason = OnChangeCallbackReason.OnChangeCallbackReason

type FormatAsStringEntry = {
	name: string,
	callback: ((value: number) -> string)?,
}

type GroupProps = {
	scope: Scope,
	caption: string,
	contentTag: string,
	layoutOrder: number?,
	children: { any },
}

-- Stands in for React.None in the controls.
local NONE = "None"

local function withDefaultFirst<T>(values: { T }, defaultValue: T): { T }
	local result = { defaultValue }
	for _, value in values do
		if value ~= defaultValue then
			table.insert(result, value)
		end
	end
	return result
end

local FORMAT_AS_STRING_CALLBACKS: { FormatAsStringEntry } = {
	{
		name = "none",
		callback = nil,
	},
	{
		name = "stringified",
		callback = function(numValue)
			return `{numValue}`
		end,
	},
	{
		name = "punctuation",
		callback = function(numValue)
			local withPunctuation = ""
			local roundedNumString = tostring(math.round(numValue))
			local s, e = math.max(#roundedNumString - 2, 1), #roundedNumString
			while e >= 1 do
				local nextThreeChars = string.sub(roundedNumString, s, e)
				e = s - 1
				s = math.max(e - 2, 1)
				if e >= 1 then
					withPunctuation = "," .. nextThreeChars .. withPunctuation
				else
					withPunctuation = nextThreeChars .. withPunctuation
				end
			end
			local numString = tostring(numValue)
			local decimalsStart, _ = string.find(numString, ".", 1, true)
			return withPunctuation .. string.sub(numString, decimalsStart or #numString + 1, #numString)
		end,
	},
}

local function noneToNil(controlValue: any, use: Use)
	local value = unwrap(controlValue, use)
	return if value == NONE then nil else value
end

local function Group(props: GroupProps)
	return View {
		scope = props.scope,
		tag = "col gap-medium auto-xy",
		LayoutOrder = props.layoutOrder,
		children = {
			Caption = Text {
				scope = props.scope,
				Text = props.caption,
				tag = "text-body-small content-default auto-xy",
				LayoutOrder = 1,
			},
			Content = View {
				scope = props.scope,
				tag = props.contentTag,
				LayoutOrder = 2,
				children = props.children,
			},
		}
	}
end

-- A NumberInput that keeps its own value. `defaultValue` is the starting value.
local function StatefulNumberInput(scope: Scope, props: { [string]: any })
	local value = scope:Value(props.defaultValue or 0)

	props.defaultValue = nil
	props.scope = scope
	props.value = value
	props.onChanged = function(newValue: number)
		value:set(newValue)
	end

	return NumberInput(props)
end

local function PlaygroundStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls
	local value = scope:Value(0)

	-- isRequired, onTextChanged and formatAsString are not states in NumberInput, so it is rebuilt when they change.
	return scope:Computed(function(use: Use, innerScope: Scope)
		local formatAsStringName = unwrap(controls.formatAsString, use)
		local formatAsString = (Dash.find(FORMAT_AS_STRING_CALLBACKS, function(entry)
			return entry.name == formatAsStringName
		end) :: FormatAsStringEntry).callback

		local useOnTextChanged = unwrap(controls.onTextChanged, use)

		return NumberInput {
			scope = innerScope,
			value = value,
			variant = controls.variant,
			hasError = controls.hasError,
			isDisabled = controls.isDisabled,
			isRequired = noneToNil(controls.isRequired, use),
			onChanged = function(newValue: number)
				value:set(newValue)
			end,
			onTextChanged = if useOnTextChanged
				then function(text: string)
					print(text)
				end
				else nil,
			formatAsString = formatAsString,
			label = controls.label,
			size = controls.size,
			width = innerScope:Computed(function(use: Use)
				local width = unwrap(controls.width, use)
				return if width == 0 then nil else UDim.new(0, width)
			end),
			maximum = controls.maximum,
			minimum = controls.minimum,
			step = controls.step,
			hint = innerScope:Computed(function(use: Use)
				local hint = unwrap(controls.hint, use)
				return if hint == "" then nil else hint
			end),
			precision = controls.precision,
			leadingIcon = innerScope:Computed(function(use: Use)
				return noneToNil(controls.leadingIcon, use)
			end),
			trailingIcon = innerScope:Computed(function(use: Use)
				return noneToNil(controls.trailingIcon, use)
			end),
			scrubBehavior = controls.scrubBehavior,
			prefix = innerScope:Computed(function(use: Use)
				local prefix = unwrap(controls.prefix, use)
				return if prefix == "" then nil else prefix
			end),
			suffix = innerScope:Computed(function(use: Use)
				local suffix = unwrap(controls.suffix, use)
				return if suffix == "" then nil else suffix
			end),
			hasControls = controls.hasControls,
			focusBehavior = innerScope:Computed(function(use: Use)
				return noneToNil(controls.focusBehavior, use)
			end),
			LayoutOrder = props.layoutOrder,
		}
	end)
end

local function SizesStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	local children = {}

	local sizes = { Large = InputSize.Large, Medium = InputSize.Medium, Small = InputSize.Small, XSmall = InputSize.XSmall }
	local order = { "Large", "Medium", "Small", "XSmall" }
	for index, name in order do
		children[name] = Group {
			scope = scope,
			caption = name,
			contentTag = "auto-xy",
			layoutOrder = index,
			children = {
				Input = StatefulNumberInput(scope, {
					defaultValue = 42,
					size = sizes[name],
					label = "Value",
					minimum = 0,
					maximum = 100,
					step = 1,
					width = UDim.new(0, 200),
				}),
			},
		}
	end

	return View {
		scope = scope,
		tag = "row gap-xxlarge auto-xy align-y-bottom",
		LayoutOrder = props.layoutOrder,
		children = children,
	}
end

local function VariantsStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	local children = {}

	local index = 0
	for name, variant in InputVariant do
		index += 1
		children[name] = Group {
			scope = scope,
			caption = name,
			contentTag = "auto-xy",
			layoutOrder = index,
			children = {
				Input = StatefulNumberInput(scope, {
					defaultValue = 25,
					variant = variant,
					label = "Value",
					minimum = 0,
					maximum = 100,
					step = 1,
					width = UDim.new(0, 200),
				}),
			},
		}
	end

	return View {
		scope = scope,
		tag = "row gap-xxlarge auto-xy",
		LayoutOrder = props.layoutOrder,
		children = children,
	}
end

local function StatesStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope

	local states = {
		{ caption = "Enabled", isDisabled = false, hasError = false },
		{ caption = "Disabled", isDisabled = true, hasError = false },
		{ caption = "Error", isDisabled = false, hasError = true },
	}

	local children = {}
	for index, state in states do
		children[state.caption] = Group {
			scope = scope,
			caption = state.caption,
			contentTag = "auto-xy",
			layoutOrder = index,
			children = {
				Input = StatefulNumberInput(scope, {
					defaultValue = 50,
					label = "Value",
					hint = if state.hasError then "Value is invalid" else "Hint text",
					isDisabled = state.isDisabled,
					hasError = state.hasError,
					minimum = 0,
					maximum = 100,
					step = 1,
					width = UDim.new(0, 200),
				}),
			},
		}
	end

	return View {
		scope = scope,
		tag = "row gap-xxlarge auto-xy",
		LayoutOrder = props.layoutOrder,
		children = children,
	}
end

local function ControlsStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope

	local options = {
		{ caption = "With Controls", hasControls = true },
		{ caption = "Without Controls", hasControls = false },
	}

	local children = {}
	for index, option in options do
		children[option.caption] = Group {
			scope = scope,
			caption = option.caption,
			contentTag = "auto-xy",
			layoutOrder = index,
			children = {
				Input = StatefulNumberInput(scope, {
					defaultValue = 10,
					label = "Value",
					hasControls = option.hasControls,
					minimum = 0,
					maximum = 100,
					step = 1,
					width = UDim.new(0, 200),
				}),
			},
		}
	end

	return View {
		scope = scope,
		tag = "row gap-xxlarge auto-xy",
		LayoutOrder = props.layoutOrder,
		children = children,
	}
end

local function PrefixSuffixStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope

	local examples: { { caption: string, prefix: string?, suffix: string?, leadingIcon: string? } } = {
		{ caption = "Prefix ($)", prefix = "$", suffix = nil },
		{ caption = "Suffix (%)", prefix = nil, suffix = "%" },
		{ caption = "Suffix (px) + Icon", prefix = nil, suffix = "px", leadingIcon = "icons/common/search_small" },
	}

	local children = {}
	for index, example in examples do
		children[example.caption] = Group {
			scope = scope,
			caption = example.caption,
			contentTag = "auto-xy",
			layoutOrder = index,
			children = {
				Input = StatefulNumberInput(scope, {
					defaultValue = 100,
					label = "Value",
					prefix = example.prefix,
					suffix = example.suffix,
					leadingIcon = example.leadingIcon,
					minimum = 0,
					maximum = 9999,
					step = 1,
					width = UDim.new(0, 200),
				}),
			},
		}
	end

	return View {
		scope = scope,
		tag = "row gap-xxlarge auto-xy",
		LayoutOrder = props.layoutOrder,
		children = children,
	}
end

local function IconsStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope

	local examples: { { caption: string, leadingIcon: string?, trailingIcon: string? } } = {
		{ caption = "Leading", leadingIcon = "icons/common/search_small", trailingIcon = nil },
		{ caption = "Trailing", leadingIcon = nil, trailingIcon = "icons/status/private_small" },
		{ caption = "Both", leadingIcon = "icons/common/search_small", trailingIcon = "icons/status/private_small" },
	}

	local children = {}
	for index, example in examples do
		children[example.caption] = Group {
			scope = scope,
			caption = example.caption,
			contentTag = "auto-xy",
			layoutOrder = index,
			children = {
				Input = StatefulNumberInput(scope, {
					defaultValue = 42,
					label = "Value",
					leadingIcon = example.leadingIcon,
					trailingIcon = example.trailingIcon,
					minimum = 0,
					maximum = 100,
					step = 1,
					width = UDim.new(0, 200),
				}),
			},
		}
	end

	return View {
		scope = scope,
		tag = "row gap-xxlarge auto-xy",
		LayoutOrder = props.layoutOrder,
		children = children,
	}
end

local function ScrubBehaviorStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	local children = {}

	local index = 0
	for name, behavior in ScrubBehavior do
		index += 1
		children[name] = Group {
			scope = scope,
			caption = name,
			contentTag = "auto-xy",
			layoutOrder = index,
			children = {
				Input = StatefulNumberInput(scope, {
					defaultValue = 50,
					label = "Drag to change",
					hint = if behavior == ScrubBehavior.On then "Scrub enabled" else "Scrub disabled",
					scrubBehavior = behavior,
					minimum = 0,
					maximum = 100,
					step = 1,
					width = UDim.new(0, 200),
				}),
			},
		}
	end

	return View {
		scope = scope,
		tag = "row gap-xxlarge auto-xy",
		LayoutOrder = props.layoutOrder,
		children = children,
	}
end

local function evaluateExpression(text: string): number?
	local trimmed = string.match(text, "^%s*(.-)%s*$")
	if trimmed == nil or trimmed == "" then
		return nil
	end

	local left, op, right = string.match(trimmed, "^(%d+%.?%d*)%s*([+%-])%s*(%d+%.?%d*)$")
	if left and op and right then
		local a, b = tonumber(left), tonumber(right)
		if a and b then
			if op == "+" then
				return a + b
			elseif op == "-" then
				return a - b
			end
		end
	end

	return tonumber(trimmed)
end

local EXPRESSION_INPUT_HINT = 'Type an expression like "3 + 5"'
local INVALID_EXPRESSION_HINT = "Could not compute expression"

local function ExpressionInputStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope

	local value = scope:Value(nil :: number?)
	local expression = scope:Value("")
	local errorMessage = scope:Value(nil :: string?)

	return View {
		scope = scope,
		tag = "col gap-large auto-xy padding-large",
		LayoutOrder = props.layoutOrder,
		children = {
			Input = NumberInput {
				scope = scope,
				value = scope:Computed(function(use: Use)
					return unwrap(value, use) or 0
				end),
				label = "Padding",
				-- Pair hasError with a hint message to tell the user their formula is invalid.
				hasError = scope:Computed(function(use: Use)
					return unwrap(errorMessage, use) ~= nil
				end),
				hint = scope:Computed(function(use: Use)
					return unwrap(errorMessage, use) or EXPRESSION_INPUT_HINT
				end),
				onTextChanged = function(text: string)
					expression:set(text)
					errorMessage:set(nil)
				end,
				onChanged = function() end,
				onFocusLost = function()
					local result = evaluateExpression(unwrap(expression))
					if result ~= nil then
						value:set(result)
						expression:set(tostring(result))
						errorMessage:set(nil)
					else
						value:set(nil)
						errorMessage:set(INVALID_EXPRESSION_HINT)
					end
				end,
				width = UDim.new(0, 300),
				LayoutOrder = 1,
			},
			Expression = Text {
				scope = scope,
				tag = "auto-xy text-body-medium content-default",
				Text = scope:Computed(function(use: Use)
					local currentExpression = unwrap(expression, use)
					return `Expression: {if currentExpression == "" then "—" else currentExpression}`
				end),
				LayoutOrder = 2,
			},
			Value = Text {
				scope = scope,
				tag = "auto-xy text-body-medium content-emphasis",
				Text = scope:Computed(function(use: Use)
					local currentValue = unwrap(value, use)
					return if currentValue ~= nil then `Value: {currentValue}` else "Value: nil"
				end),
				LayoutOrder = 3,
			},
		}
	}
end

type HistoryEntry = {
	value: number,
	reason: OnChangeCallbackReason,
}

local function UndoRedoStackStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope

	local value = scope:Value(50)
	local history = scope:Value({ { value = 50, reason = OnChangeCallbackReason.FocusLost } } :: { HistoryEntry })
	local historyIndex = scope:Value(1)
	local lastReason: OnChangeCallbackReason? = nil

	local canUndo = scope:Computed(function(use: Use)
		return unwrap(historyIndex, use) > 1
	end)
	local canRedo = scope:Computed(function(use: Use)
		return unwrap(historyIndex, use) < #unwrap(history, use)
	end)

	local function handleChange(newValue: number, reason: OnChangeCallbackReason)
		value:set(newValue)

		if reason == OnChangeCallbackReason.Keyboard then
			return
		end

		local currentIndex = unwrap(historyIndex)
		local currentHistory = unwrap(history)

		if reason == OnChangeCallbackReason.Drag and lastReason == OnChangeCallbackReason.Drag then
			local newHistory = table.clone(currentHistory)
			newHistory[currentIndex] = { value = newValue, reason = reason }
			history:set(newHistory)
		else
			local newHistory = {}
			for i = 1, currentIndex do
				table.insert(newHistory, currentHistory[i])
			end
			table.insert(newHistory, { value = newValue, reason = reason })
			history:set(newHistory)
			historyIndex:set(currentIndex + 1)
		end

		lastReason = reason
	end

	local function undo()
		if unwrap(canUndo) then
			local newIndex = unwrap(historyIndex) - 1
			historyIndex:set(newIndex)
			value:set(unwrap(history)[newIndex].value)
			lastReason = nil
		end
	end

	local function redo()
		if unwrap(canRedo) then
			local newIndex = unwrap(historyIndex) + 1
			historyIndex:set(newIndex)
			value:set(unwrap(history)[newIndex].value)
			lastReason = nil
		end
	end

	return View {
		scope = scope,
		tag = "col gap-large size-full-0 auto-y padding-large",
		LayoutOrder = props.layoutOrder,
		children = {
			Input = NumberInput {
				scope = scope,
				value = value,
				onChanged = handleChange,
				label = "Value with Undo/Redo",
				hint = "Drag consolidates, buttons/keyboard create entries",
				minimum = 0,
				maximum = 100,
				step = 1,
				isScrubbable = true,
				width = UDim.new(0, 300),
				LayoutOrder = 1,
			},
			Controls = View {
				scope = scope,
				tag = "row gap-small auto-xy",
				LayoutOrder = 2,
				children = {
					UndoButton = Button {
						scope = scope,
						text = "Undo",
						onActivated = undo,
						isDisabled = scope:Computed(function(use: Use)
							return not unwrap(canUndo, use)
						end),
						LayoutOrder = 1,
					},
					RedoButton = Button {
						scope = scope,
						text = "Redo",
						onActivated = redo,
						isDisabled = scope:Computed(function(use: Use)
							return not unwrap(canRedo, use)
						end),
						LayoutOrder = 2,
					},
				}
			},
			HistoryLabel = Text {
				scope = scope,
				tag = "auto-xy text-title-medium content-emphasis",
				Text = "History Stack:",
				LayoutOrder = 3,
			},
			History = View {
				scope = scope,
				tag = "col gap-xsmall auto-y",
				LayoutOrder = 4,
				children = scope:Computed(function(use: Use, innerScope: Scope)
					local currentIndex = unwrap(historyIndex, use)
					local items = {}
					for i, entry in unwrap(history, use) do
						local isCurrent = i == currentIndex
						table.insert(items, Text {
							scope = innerScope,
							tag = {
								["auto-xy text-body-medium content-emphasis"] = isCurrent,
								["auto-xy text-body-medium content-default"] = not isCurrent,
							},
							Text = `{i}. {entry.value} ({entry.reason}){if isCurrent then " ←" else ""}`,
							LayoutOrder = i,
						})
					end
					return items
				end),
			},
		}
	}
end

local inputSizes = withDefaultFirst(Dash.values(InputSize), InputSize.Large)
local inputVariants = withDefaultFirst(Dash.values(InputVariant), InputVariant.Standard)
local scrubBehaviors = withDefaultFirst(Dash.values(ScrubBehavior), ScrubBehavior.Off)
local focusBehaviors = { NONE, unpack(Dash.values(InputFocusBehavior)) }

local formatAsStringNames = {}
for _, entry in FORMAT_AS_STRING_CALLBACKS do
	table.insert(formatAsStringNames, entry.name)
end

local iconList = {
	NONE,
	"icons/placeholder/placeholderOn_small",
	"icons/status/private_small",
	"icons/common/search_small",
}

local function chooseControl(list: { any })
	return {
		EntryType = "Control",
		Type = "Choose",
		ControlValue = list[1],
		List = list,
		DefIndex = 1,
	}
end

return {
	summary = "NumberInput",
	fusion = Fusion,
	controls = {
		label = "",
		hint = "",
		size = chooseControl(inputSizes),
		isRequired = chooseControl({ NONE, false, true }),
		variant = chooseControl(inputVariants),
		formatAsString = chooseControl(formatAsStringNames),
		onTextChanged = false,
		hasError = false,
		isDisabled = false,
		maximum = math.huge,
		minimum = -math.huge,
		step = 1,
		precision = 3,
		prefix = "",
		suffix = "",
		width = 0,
		scrubBehavior = chooseControl(scrubBehaviors),
		leadingIcon = chooseControl(iconList),
		trailingIcon = chooseControl(iconList),
		hasControls = false,
		focusBehavior = chooseControl(focusBehaviors),
		theme = CommonControls.theme
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
						title = "Sizes",
						layoutOrder = 2,
						children = { SizesStory { scope = innerScope, layoutOrder = 2 } },
					},
					StorySection {
						scope = innerScope,
						title = "Variants",
						layoutOrder = 3,
						children = { VariantsStory { scope = innerScope, layoutOrder = 2 } },
					},
					StorySection {
						scope = innerScope,
						title = "States",
						layoutOrder = 4,
						children = { StatesStory { scope = innerScope, layoutOrder = 2 } },
					},
					StorySection {
						scope = innerScope,
						title = "Controls",
						layoutOrder = 5,
						children = { ControlsStory { scope = innerScope, layoutOrder = 2 } },
					},
					StorySection {
						scope = innerScope,
						title = "PrefixSuffix",
						layoutOrder = 6,
						children = { PrefixSuffixStory { scope = innerScope, layoutOrder = 2 } },
					},
					StorySection {
						scope = innerScope,
						title = "Icons",
						layoutOrder = 7,
						children = { IconsStory { scope = innerScope, layoutOrder = 2 } },
					},
					StorySection {
						scope = innerScope,
						title = "ScrubBehavior",
						layoutOrder = 8,
						children = { ScrubBehaviorStory { scope = innerScope, layoutOrder = 2 } },
					},
					StorySection {
						scope = innerScope,
						title = "UndoRedoStack",
						layoutOrder = 9,
						children = { UndoRedoStackStory { scope = innerScope, layoutOrder = 2 } },
					},
					StorySection {
						scope = innerScope,
						title = "Expression input",
						description = "Uses `onTextChanged` to allow for custom expressions to be written instead of exclusively numbers.",
						layoutOrder = 10,
						children = { ExpressionInputStory { scope = innerScope, layoutOrder = 3 } }
					}
				}
			}
		end)
	end)
}
