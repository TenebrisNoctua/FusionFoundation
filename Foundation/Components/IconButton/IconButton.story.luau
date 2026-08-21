--!nonstrict

local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local IconButton = require(Components.IconButton)
local ScrollView = require(Components.ScrollView)
local View = require(Components.View)
local Text = require(Components.Text)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local StorySection = require(Utility.Stories.StorySection)
local CommonControls = require(Utility.Stories.CommonControls)

local InputSize = require(Enums.InputSize)
local FillBehavior = require(Enums.FillBehavior)
local ButtonVariant = require(Enums.ButtonVariant)

local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local Children = Fusion.Children

type Scope = Types.Scope
type Use = Types.Use

type InputSize = InputSize.InputSize
type ButtonVariant = ButtonVariant.ButtonVariant

local IconNames = {
	"play-small",
	"play-large",
	"play-xlarge",
	"robux",
	"heart",
	"glasses",
}

local IconVariants = Dash.values(BuilderIcons.IconVariant)

-- Only show the supported variants for IconButton
local SUPPORTED_VARIANTS = {
	ButtonVariant.Utility,
	ButtonVariant.Standard,
	ButtonVariant.Emphasis,
	ButtonVariant.OverMedia,
	ButtonVariant.Alert,
}

return {
	fusion = Fusion,
	summary = "IconButton",
	story = StoryMiddleware(function(props)
		local scope = props.scope
		local controls = props.controls
		local theme = ThemeProvider()

		return ScrollView {
			scope = scope,
			AutomaticSize = Enum.AutomaticSize.XY,
			scroll = {
				AutomaticSize = Enum.AutomaticSize.XY,
				AutomaticCanvasSize = Enum.AutomaticSize.XY
			},
			tag = "padding-medium radius-medium back-clear",
			children = scope:Computed(function(use: Use, innerScope: Scope)
				local renderedStories = {
					innerScope:New "UIListLayout" {
						FillDirection = Enum.FillDirection.Vertical,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 16)
					}
				}

				local tokens = unwrap(theme.Tokens, use)
				local colorNamespace = unwrap(controls.colorNamespace, use)
				local currentFillBehavior = unwrap(controls.fillBehavior, use)
				local selectedBehavior = if currentFillBehavior == "None" then nil else currentFillBehavior

				local iconProp = innerScope:Computed(function(use: Use)
					return {
						name = unwrap(controls.name, use),
						variant = unwrap(controls.variant, use),
					}
				end)

				-- Variant stories
				for _, variant in SUPPORTED_VARIANTS do
					local iconButtonsForSizes = {
						innerScope:New "UIListLayout" {
							FillDirection = Enum.FillDirection.Horizontal,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0, 12),
						}
					}

					local sizes = { InputSize.Large, InputSize.Medium, InputSize.Small, InputSize.XSmall }
					for _, size in sizes do
						table.insert(iconButtonsForSizes, IconButton {
							scope = innerScope,
							icon = iconProp,
							variant = variant,
							onActivated = function()
								print(`{colorNamespace} {variant} IconButton ({size}) activated`)
							end,
							isDisabled = controls.isDisabled,
							size = size,
							isCircular = controls.isCircular,
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
							if variant == ButtonVariant.OverMedia
								then innerScope:New "UIGradient" {
									Color = ColorSequence.new({
										ColorSequenceKeypoint.new(0, tokens.Color.Extended.Green.Green_500.Color3),
										ColorSequenceKeypoint.new(1, tokens.Color.Extended.Blue.Blue_500.Color3),
									}),
								} else nil,
							[Children] = iconButtonsForSizes,
						}
					}

					local variantStory = StorySection {
						scope = innerScope,
						title = variant,
						children = {variantRow}
					}

					table.insert(renderedStories, variantStory)
				end

				-- Width story
				do
					local widthSubSections = {}

					-- Default (fixed square)
					table.insert(widthSubSections, View {
						scope = innerScope,
						LayoutOrder = 1,
						tag = "col gap-xxsmall auto-xy",
						children = {
							Text {
								scope = innerScope,
								Text = "Default (fixed square)",
								tag = "auto-xy text-body-small",
								LayoutOrder = 1,
							},
							View {
								scope = innerScope,
								tag = "row gap-medium auto-xy",
								LayoutOrder = 2,
								children = {
									IconButton {
										scope = innerScope,
										icon = iconProp,
										variant = ButtonVariant.Emphasis,
										onActivated = function() end,
										size = InputSize.Medium,
									}
								}
							}
						}
					})

					-- Fixed width
					table.insert(widthSubSections, View {
						scope = innerScope,
						LayoutOrder = 2,
						tag = "col gap-xxsmall auto-xy",
						children = {
							Text {
								scope = innerScope,
								Text = "Fixed width (0, 200px)",
								tag = "auto-xy text-body-small",
								LayoutOrder = 1,
							},
							View {
								scope = innerScope,
								tag = "row gap-medium auto-xy",
								LayoutOrder = 2,
								children = {
									IconButton {
										scope = innerScope,
										icon = iconProp,
										variant = ButtonVariant.Emphasis,
										onActivated = function() end,
										size = InputSize.Medium,
										width = UDim.new(0, 200),
									}
								}
							}
						}
					})

					-- FillBehavior takes precedence
					table.insert(widthSubSections, View {
						scope = innerScope,
						LayoutOrder = 3,
						tag = "col gap-xxsmall auto-xy",
						children = {
							Text {
								scope = innerScope,
								Text = "fillBehavior.Fill takes precedence over width=200px",
								tag = "auto-xy text-body-small",
								LayoutOrder = 1,
							},
							View {
								scope = innerScope,
								tag = "row size-full-0 auto-xy",
								LayoutOrder = 2,
								Size = UDim2.new(1, 0, 0, 60),
								children = {
									IconButton {
										scope = innerScope,
										icon = iconProp,
										variant = ButtonVariant.Emphasis,
										onActivated = function() end,
										size = InputSize.Medium,
										width = UDim.new(0, 200),
										fillBehavior = FillBehavior.Fill,
									}
								}
							}
						}
					})

					local widthRow = View {
						scope = innerScope,
						tag = "col gap-large size-full-0 auto-xy padding-large radius-medium",
						backgroundStyle = if colorNamespace then tokens[colorNamespace].Surface.Surface_100 else nil,
						LayoutOrder = 3,
						children = widthSubSections,
					}

					local widthStory = StorySection {
						scope = innerScope,
						title = "Width",
						description = "Width, fillBehavior, and precedence. Default uses the fixed square size from the variant system. Width (scale or offset) overrides. fillBehavior.Fill takes precedence over width.",
						children = {widthRow}
					}

					table.insert(renderedStories, widthStory)
				end

				-- FillBehavior story
				do
					local fillBehaviorChildren = {
						innerScope:New "UIListLayout" {
							FillDirection = Enum.FillDirection.Horizontal,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0, 12),
						}
					}

					table.insert(fillBehaviorChildren, IconButton {
						scope = innerScope,
						icon = iconProp,
						variant = ButtonVariant.Emphasis,
						onActivated = function()
							print(`{colorNamespace} IconButton row {selectedBehavior} activated`)
						end,
						isDisabled = controls.isDisabled,
						size = InputSize.Medium,
						isCircular = controls.isCircular,
						fillBehavior = selectedBehavior,
					})

					table.insert(fillBehaviorChildren, IconButton {
						scope = innerScope,
						icon = iconProp,
						variant = ButtonVariant.Utility,
						onActivated = function()
							print(`{colorNamespace} IconButton row {selectedBehavior} activated`)
						end,
						isDisabled = controls.isDisabled,
						size = InputSize.Medium,
						isCircular = controls.isCircular,
						fillBehavior = selectedBehavior,
					})

					table.insert(fillBehaviorChildren, IconButton {
						scope = innerScope,
						icon = iconProp,
						variant = ButtonVariant.Utility,
						onActivated = function()
							print(`{colorNamespace} IconButton row {selectedBehavior} activated`)
						end,
						isDisabled = controls.isDisabled,
						size = InputSize.Medium,
						isCircular = controls.isCircular,
						fillBehavior = selectedBehavior,
					})

					local fillBehaviorRow = View {
						scope = innerScope,
						tag = "row gap-medium size-full-0 auto-y padding-medium radius-medium",
						backgroundStyle = if colorNamespace then tokens[colorNamespace].Surface.Surface_100 else nil,
						LayoutOrder = 2,
						children = fillBehaviorChildren,
					}

					local fillBehaviorStory = StorySection {
						scope = innerScope,
						title = "FillBehavior",
						children = {fillBehaviorRow}
					}

					table.insert(renderedStories, fillBehaviorStory)
				end

				return renderedStories
			end)
		}
	end),
	controls = {
		name = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = IconNames[1],
			List = IconNames,
			DefIndex = 1
		},
		variant = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = IconVariants[1],
			List = IconVariants,
			DefIndex = 1
		},
		colorNamespace = CommonControls.colorNamespace,
		fillBehavior = CommonControls.fillBehavior,
		theme = CommonControls.theme,
		isDisabled = false,
		isCircular = false
	}
}
