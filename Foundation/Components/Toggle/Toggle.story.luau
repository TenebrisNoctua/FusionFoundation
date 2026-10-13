local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Toggle = require(script.Parent)

local Text = require(Components.Text)
local View = require(Components.View)
local ScrollView = require(Components.ScrollView)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StorySection = require(Utility.Stories.StorySection)
local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local CommonControls = require(Utility.Stories.CommonControls)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local InputPlacement = require(Enums.InputPlacement)
local InputSize = require(Enums.InputSize)

type Scope = Types.Scope
type Use = Types.Use

local function PlaygroundStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls
	local isChecked = scope:Value(false)

	return View {
		scope = scope,
		tag = "col size-3000-0 auto-xy",
		LayoutOrder = props.layoutOrder,
		children = {
			Toggle {
				scope = scope,
				isChecked = isChecked,
				isDisabled = controls.isDisabled,
				onActivated = function()
					isChecked:set(not unwrap(isChecked))
				end,
				size = controls.size,
				label = controls.label,
				placement = controls.placement,
			}
		}
	}
end

local function CustomSelectionStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	local theme = ThemeProvider()
	local isChatEnabled = scope:Value(false)
	local isNotifications = scope:Value(true)

	local cursor = scope:Computed(function(use: Use)
		local tokens = unwrap(theme.Tokens, use)
		return {
			radius = UDim.new(0, tokens.Radius.Medium),
			offset = tokens.Size.Size_150,
			borderWidth = tokens.Stroke.Thicker,
		}
	end)

	local function createToggleCard(label: string, description: string, isChecked: Types.Value<boolean>, layoutOrder: number)
		local function onToggle()
			isChecked:set(not unwrap(isChecked))
		end

		return View {
			scope = scope,
			cursor = cursor,
			onActivated = onToggle,
			tag = "col gap-medium padding-large stroke-muted radius-medium bg-surface-100",
			Size = UDim2.fromOffset(320, 100),
			LayoutOrder = layoutOrder,
			children = {
				TextContainer = View {
					scope = scope,
					tag = "row flex-x-between gap-small size-full-0 auto-y",
					LayoutOrder = 1,
					children = {
						Label = Text {
							scope = scope,
							Text = label,
							tag = "auto-xy text-body-medium content-emphasis",
							LayoutOrder = 1,
						},
						Toggle = Toggle {
							scope = scope,
							isChecked = isChecked,
							onActivated = onToggle,
							label = "",
							-- Make the toggle non-selectable since the parent card handles selection
							Selectable = false,
							LayoutOrder = 2,
						},
					},
				},
				Description = Text {
					scope = scope,
					Text = description,
					tag = "auto-xy text-body-small text-wrap content-muted",
					LayoutOrder = 2,
				},
			},
		}
	end

	return View {
		scope = scope,
		tag = "col gap-large auto-xy",
		LayoutOrder = props.layoutOrder,
		children = {
			NotificationsCard = createToggleCard(
				"Push Notifications",
				"Receive notifications for messages and updates",
				isNotifications,
				1
			),
			ChatCard = createToggleCard("Chat", "Enable chat for real-time communication", isChatEnabled, 2),
		},
	}
end

local function UncontrolledStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls

	return View {
		scope = scope,
		tag = "col size-3000-0 auto-xy",
		LayoutOrder = props.layoutOrder,
		children = {
			Toggle {
				scope = scope,
				isDisabled = controls.isDisabled,
				onActivated = function(value: boolean)
					print("isChecked: ", value)
				end,
				size = controls.size,
				label = controls.label,
				placement = controls.placement,
			},
		},
	}
end

return {
	fusion = Fusion,
	summary = "Toggle component",
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
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
				},
				children = {
					StorySection {
						scope = innerScope,
						title = "Playground",
						layoutOrder = 1,
						children = { PlaygroundStory { scope = innerScope, controls = controls, layoutOrder = 1 } },
					},
					StorySection {
						scope = innerScope,
						title = "Custom Selection",
						description = "Select card containers instead of toggles",
						layoutOrder = 2,
						children = { CustomSelectionStory { scope = innerScope, layoutOrder = 1 } },
					},
					StorySection {
						scope = innerScope,
						title = "Uncontrolled",
						description = "State is controlled by the toggle itself",
						layoutOrder = 3,
						children = { UncontrolledStory { scope = innerScope, controls = controls, layoutOrder = 1 } },
					},
				},
			}
		end)
	end),
}
