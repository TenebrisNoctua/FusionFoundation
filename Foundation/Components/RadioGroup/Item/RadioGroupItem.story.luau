local Foundation = script.Parent.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local RadioGroupItem = require(script.Parent)
local RadioGroupContext = require(script.Parent.Parent.RadioGroupContext)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local StorySection = require(Utility.Stories.StorySection)
local CommonControls = require(Utility.Stories.CommonControls)

local InputSize = require(Enums.InputSize)
local InputPlacement = require(Enums.InputPlacement)

type Scope = Types.Scope
type Use = Types.Use

local function PlaygroundStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls
	local value = scope:Value(nil :: string?)

	local contextValue = {
		value = value,
		onValueChanged = function(newValue: string)
			value:set(newValue)
		end,
		Selectable = true,
	}

	return RadioGroupContext:is(contextValue):during(function()
		return RadioGroupItem {
			scope = scope,
			value = controls.value,
			label = scope:Computed(function(use: Use)
				local label = unwrap(controls.label, use)
				local itemValue = unwrap(controls.value, use)
				return if #label > 0 then `{label} {itemValue}` else ""
			end),
			isDisabled = controls.isDisabled,
			size = controls.size,
			placement = controls.placement,
			LayoutOrder = props.layoutOrder
		}
	end)
end

return {
	fusion = Fusion,
	summary = "RadioGroupItem component",
	controls = {
		isDisabled = false,
		label = "Label",
		value = "A",
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

			return StorySection {
				scope = innerScope,
				title = "Playground",
				children = { PlaygroundStory { scope = innerScope, controls = controls, layoutOrder = 2 } },
			}
		end)
	end),
}
