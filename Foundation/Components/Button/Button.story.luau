--!nonstrict

local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local ScrollView = require(Components.ScrollView)
local Button = require(Components.Button)
local View = require(Components.View)
local Text = require(Components.Text)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local CommonControls = require(Utility.Stories.CommonControls)
local StorySection = require(Utility.Stories.StorySection)

local InputSize = require(Enums.InputSize)
local ButtonVariant = require(Enums.ButtonVariant)
local FillBehavior = require(Enums.FillBehavior)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local Children = Fusion.Children

local Icons = {
	"arrow-up-right-from-square",
	"chain-link",
	"tilt",
	"icons/placeholder/placeholderOn",
	"icons/common/robux",
	"icons/common/play",
	"icons/controls/media-play-large",
	"icons/controls/media-play-medium",
	"icons/controls/media-play-small",
	"icons/actions/pumpkin_medium",
	"icons/actions/accept_small",
	"icons/actions/friends/friendAdd",
	"icons/actions/friends/friendAdd_small",
	"icons/navigation/externallink_medium",
	"icons/actions/info",
	"icons/actions/info_small",
	"",
}

local BUTTON_VARIANTS = {
	ButtonVariant.Standard,
	ButtonVariant.Emphasis,
	ButtonVariant.SoftEmphasis,
	ButtonVariant.Utility,
	ButtonVariant.Link,
	ButtonVariant.Alert,
}

type Scope = Types.Scope
type Use = Types.Use

type InputSize = InputSize.InputSize
type ButtonVariant = ButtonVariant.ButtonVariant
type FillBehavior = FillBehavior.FillBehavior

return {
	fusion = Fusion,
	summary = "Button",
	story = StoryMiddleware(function(props)
		local scope = props.scope
		local controls = props.controls
		local theme = ThemeProvider()

		return ScrollView {
			scope = scope,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.fromScale(1, 0),
			scroll = {
				AutomaticSize = Enum.AutomaticSize.Y,
				ScrollingDirection = Enum.ScrollingDirection.Y,
			},
			tag = "padding-medium back-clear",
			children = scope:Computed(function(use: Use, innerScope: Scope)
				local renderedStories = {
					innerScope:New "UIListLayout" {
						FillDirection = Enum.FillDirection.Vertical,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 16),
					}
				}

				local tokens = unwrap(theme.Tokens, use)
				local colorNamespace = unwrap(controls.colorNamespace, use)
				local extendedColors = tokens.Color.Extended

				-- Playground section: single interactive button
				local playgroundButton = Button {
					scope = innerScope,
					icon = innerScope:Computed(function(use)
						local iconVal = unwrap(controls.icon, use)
						return if iconVal == "" then nil else iconVal
					end),
					text = controls.text,
					variant = innerScope:Computed(function(use)
						return unwrap(controls.variant, use)
					end),
					isLoading = controls.isLoading,
					isDisabled = controls.isDisabled,
					size = innerScope:Computed(function(use)
						return unwrap(controls.size, use)
					end),
					fillBehavior = innerScope:Computed(function(use)
						local fill = unwrap(controls.fillBehavior, use)
						return if fill == "None" then nil else fill
					end),
					inputDelay = controls.inputDelay,
					colorNamespace = controls.colorNamespace,
					onActivated = function()
						print(`{colorNamespace} {unwrap(controls.variant)} Button activated`)
					end,
				}

				local playgroundRow = View {
					scope = innerScope,
					AutomaticSize = Enum.AutomaticSize.XY,
					LayoutOrder = 2,
					tag = "row gap-medium align-y-center padding-medium radius-medium",
					backgroundStyle = if colorNamespace then tokens[colorNamespace].Surface.Surface_100 else nil,
					children = {
						[Children] = { playgroundButton }
					}
				}

				table.insert(renderedStories, StorySection {
					scope = innerScope,
					title = "Playground",
					description = "Interactive button with all controls.",
					children = { playgroundRow }
				})

				-- Per-variant sections: show all sizes for each variant
				for _, variant in BUTTON_VARIANTS do
					local buttonsForSizes = {}

					local sizes = { InputSize.Large, InputSize.Medium, InputSize.Small, InputSize.XSmall }
					for _, size in sizes do
						table.insert(buttonsForSizes, Button {
							scope = innerScope,
							icon = innerScope:Computed(function(use)
								local iconVal = unwrap(controls.icon, use)
								return if iconVal == "" then nil else iconVal
							end),
							text = controls.text,
							variant = variant,
							isLoading = controls.isLoading,
							isDisabled = controls.isDisabled,
							size = size,
							fillBehavior = innerScope:Computed(function(use)
								local fill = unwrap(controls.fillBehavior, use)
								return if fill == "None" then nil else fill
							end),
							inputDelay = controls.inputDelay,
							colorNamespace = controls.colorNamespace,
							onActivated = function()
								print(`{colorNamespace} {variant} Button ({size}) activated`)
							end,
						})
					end

					local variantRow = View {
						scope = innerScope,
						AutomaticSize = Enum.AutomaticSize.XY,
						LayoutOrder = 2,
						tag = "row gap-medium align-y-center padding-medium radius-medium",
						backgroundStyle = if variant == ButtonVariant.OverMedia
							then tokens.Color.Extended.White.White_100
							elseif colorNamespace then tokens[colorNamespace].Surface.Surface_100
							else nil,
						children = {
							Gradient = if variant == ButtonVariant.OverMedia
								then innerScope:New "UIGradient" {
									Color = ColorSequence.new({
										ColorSequenceKeypoint.new(0, extendedColors["Green"]["Green_500"].Color3),
										ColorSequenceKeypoint.new(1, extendedColors["Blue"]["Blue_500"].Color3),
									}),
								}
								else nil,

							[Children] = buttonsForSizes
						}
					}

					table.insert(renderedStories, StorySection {
						scope = innerScope,
						title = variant,
						children = { variantRow }
					})
				end

				-- Width section: default, fixed width, fillBehavior precedence
				local widthChildren = {}

				-- Default (AutomaticSize.X)
				table.insert(widthChildren, Text {
					scope = innerScope,
					LayoutOrder = 1,
					Text = "Default (AutomaticSize.X)",
					tag = "auto-xy text-body-small",
				})
				table.insert(widthChildren, View {
					scope = innerScope,
					LayoutOrder = 2,
					tag = "row gap-medium auto-xy",
					children = {
						Button {
							scope = innerScope,
							text = "Auto",
							variant = ButtonVariant.Emphasis,
							onActivated = function() end,
							size = InputSize.Medium,
						}
					}
				})

				-- Fixed width
				table.insert(widthChildren, Text {
					scope = innerScope,
					LayoutOrder = 3,
					Text = "Fixed width (0, 200px)",
					tag = "auto-xy text-body-small",
				})
				table.insert(widthChildren, View {
					scope = innerScope,
					LayoutOrder = 4,
					tag = "row gap-medium auto-xy",
					children = {
						Button {
							scope = innerScope,
							text = "200px",
							variant = ButtonVariant.Emphasis,
							onActivated = function() end,
							size = InputSize.Medium,
							width = UDim.new(0, 200),
						}
					}
				})

				-- FillBehavior takes precedence
				table.insert(widthChildren, Text {
					scope = innerScope,
					LayoutOrder = 5,
					Text = "fillBehavior.Fill takes precedence over width=200px",
					tag = "auto-xy text-body-small",
				})
				table.insert(widthChildren, View {
					scope = innerScope,
					LayoutOrder = 6,
					tag = "row size-full-0 auto-xy",
					Size = UDim2.new(1, 0, 0, 60),
					children = {
						Button {
							scope = innerScope,
							text = "Fill wins",
							variant = ButtonVariant.Emphasis,
							onActivated = function() end,
							size = InputSize.Medium,
							width = UDim.new(0, 200),
							fillBehavior = FillBehavior.Fill,
						}
					}
				})

				table.insert(renderedStories, StorySection {
					scope = innerScope,
					title = "Width",
					description = "Width, fillBehavior, and precedence. Default uses AutomaticSize.X. Width (scale or offset) overrides. fillBehavior.Fill takes precedence over width.",
					children = widthChildren
				})

				-- FillBehavior section: None, Fit, Fill side by side
				-- Wrap buttons in a View with row tag (matches React version)
				local fillRow = View {
					scope = innerScope,
					AutomaticSize = Enum.AutomaticSize.Y,
					Size = UDim2.fromScale(1, 0),
					LayoutOrder = 2,
					tag = "row gap-medium size-full-0 auto-y padding-medium radius-medium",
					children = {
						Button {
							scope = innerScope,
							text = "Default",
							variant = ButtonVariant.Emphasis,
							onActivated = function() end,
							size = InputSize.Medium,
							LayoutOrder = 1,
						},
						Button {
							scope = innerScope,
							text = "Fit",
							variant = ButtonVariant.Emphasis,
							onActivated = function() end,
							size = InputSize.Medium,
							fillBehavior = FillBehavior.Fit,
							LayoutOrder = 2,
						},
						Button {
							scope = innerScope,
							text = "Fill",
							variant = ButtonVariant.Emphasis,
							onActivated = function() end,
							size = InputSize.Medium,
							fillBehavior = FillBehavior.Fill,
							LayoutOrder = 3,
						},
					}
				}

				table.insert(renderedStories, StorySection {
					scope = innerScope,
					title = "FillBehavior",
					description = "The same button rendered with each fillBehavior.",
					children = { fillRow }
				})

				return renderedStories
			end)
		}
	end),
	controls = {
		icon = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Icons[1],
			List = Icons,
			DefIndex = 1
		},
		text = "Lorem ipsum",
		variant = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = BUTTON_VARIANTS[1],
			List = BUTTON_VARIANTS,
			DefIndex = 1,
		},
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = InputSize.Medium,
			List = { InputSize.Large, InputSize.Medium, InputSize.Small, InputSize.XSmall },
			DefIndex = 2,
		},
		isDisabled = false,
		isLoading = false,
		colorNamespace = CommonControls.colorNamespace,
		fillBehavior = CommonControls.fillBehavior,
		inputDelay = 0,
		theme = CommonControls.theme,
	},
}
