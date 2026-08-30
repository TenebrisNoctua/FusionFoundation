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

local View = require(Components.View)
local Text = require(Components.Text)
local BaseInput = require(Components.BaseInput)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

type Scope = Types.Scope
type Use = Types.Use

local CHECKED_STYLE_CHOICES = {
	"Success",
	"Alert",
	"Default",
}

local LABEL_POSITION_CHOICES = {
	"Right",
	"Left",
	"Center",
}

local function BaseInputStory(props: {
	scope: Scope,
	controls: any,
	layoutOrder: number?,
})
	local scope = props.scope
	local controls = props.controls
	local theme = ThemeProvider()

	local isChecked = scope:Value(false)

	local function handleActivated(newValue: boolean)
		isChecked:set(newValue)
	end

	local checkedStyle = scope:Computed(function(use: Use)
		local tokens = unwrap(theme.Tokens, use)
		local styleName = unwrap(controls.checkedStyle, use)
		return tokens.Color.System[styleName]
	end)

	local labelPosition = scope:Computed(function(use: Use)
		local posName = unwrap(controls.labelPosition, use)
		return Enum.HorizontalAlignment:FromName(posName) or Enum.HorizontalAlignment.Right
	end)

	return BaseInput {
		scope = scope,
		isChecked = isChecked,
		isDisabled = controls.isDisabled,
		size = controls.size,
		onActivated = handleActivated,
		label = {
			text = controls.labelText,
			position = labelPosition,
		},
		customVariantProps = {
			tag = "row align-x-center align-y-center gap-small",
			size = UDim2.fromOffset(200, 50),
			cursorRadius = UDim.new(0, 8),
			colors = { checkedStyle = checkedStyle },
		},
		LayoutOrder = props.layoutOrder,
		children = function(childScope: Scope): Instance?
			return Text {
				scope = childScope,
				tag = "content-inverse-emphasis",
				Text = "Checked!",
				Visible = isChecked
			}
		end
	}
end

return {
	fusion = Fusion,
	summary = "Base input",
	controls = {
		isDisabled = false,
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(InputSize)[1],
			List = Dash.values(InputSize),
			DefIndex = 1,
		},
		labelText = "Input Label",
		labelPosition = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = LABEL_POSITION_CHOICES[1],
			List = LABEL_POSITION_CHOICES,
			DefIndex = 1,
		},
		checkedStyle = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = CHECKED_STYLE_CHOICES[1],
			List = CHECKED_STYLE_CHOICES,
			DefIndex = 1,
		},
		theme = CommonControls.theme,
	},
	story = StoryMiddleware(function(props)
		local scope = props.scope
		local controls = props.controls

		return scope:Computed(function(use: Use, innerScope: Scope)
			unwrap(controls.theme, use)

			return View {
				scope = innerScope,
				tag = "col gap-large size-3000 auto-xy padding-xlarge",
				children = {
					innerScope:New "UIListLayout" {
						Padding = UDim.new(0, 16),
						SortOrder = Enum.SortOrder.LayoutOrder,
					},

					StorySection {
						scope = innerScope,
						title = "Playground",
						layoutOrder = 1,
						children = {
							BaseInputStory {
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
