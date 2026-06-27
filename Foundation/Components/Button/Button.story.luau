--!nonstrict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Children = Fusion.Children

local Button = require(Foundation.Components.Button)
local View = require(Foundation.Components.View)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local unwrap = require(Foundation.Utility.unwrap)
local Types = require(Foundation.Utility.Types.Types)

local ColorMode = require(Foundation.Enums.ColorMode)
local InputSize = require(Foundation.Enums.InputSize)
local ButtonVariant = require(Foundation.Enums.ButtonVariant)
local FillBehavior = require(Foundation.Enums.FillBehavior)

local ControlModes = Dash.values(ColorMode)
local FillBehaviors = {
	"None",
	FillBehavior.Fit,
	FillBehavior.Fill,
}

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

type InputSize = InputSize.InputSize
type FillBehavior = FillBehavior.FillBehavior

type Scope = Types.Scope
type Use = Types.Use

return {
	fusion = Fusion,
	summary = "Button",
	story = function(props)
		local scope = props.scope
		local controls = props.controls

		local theme, cleanup = ThemeProvider()
		table.insert(scope, cleanup)

		return View {
			scope = scope,
			AutomaticSize = Enum.AutomaticSize.XY,
			tag = "padding-medium radius-medium back-clear",
			children = scope:Computed(function(use: Use, innerScope: Scope)
				-- Establish a vertical layout to cleanly separate each variant row
				local renderedStories = {
					innerScope:New "UIListLayout" {
						FillDirection = Enum.FillDirection.Vertical,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 16),
					},
					innerScope:New "StyleLink" {
						StyleSheet = theme.RegistryStyleSheet
					}
				}

				local extendedColors = unwrap(theme:GetTokenData("Color", "Extended"), use)
				local colorMode = unwrap(controls.colorMode, use)

				-- Loop through every ButtonVariant to create a multi-story layout dynamically
				for _, variant in ButtonVariant do
					local buttonsForSizes = {
						innerScope:New "UIListLayout" {
							FillDirection = Enum.FillDirection.Horizontal,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0, 12),
						}
					}

					-- Map all sizing combinations for the current variant row
					local sizes = { InputSize.Large, InputSize.Medium, InputSize.Small, InputSize.XSmall }
					for _, size in sizes do
						table.insert(buttonsForSizes, Button {
							scope = innerScope,
							icon = innerScope:Computed(function(innerUse)
								local iconVal = innerUse(controls.icon)
								return if iconVal == "" then nil else iconVal
							end),
							text = controls.text,
							variant = variant,
							isLoading = controls.isLoading,
							isDisabled = controls.isDisabled,
							size = size,
							fillBehavior = innerScope:Computed(function(innerUse)
								local fill = innerUse(controls.fillBehavior)
								return if fill == "None" then nil else fill
							end),
							inputDelay = controls.inputDelay,
							colorMode = controls.colorMode,
							onActivated = function()
								print(`{unwrap(controls.colorMode)} {variant} Button ({size}) activated`)
							end,
						})
					end

					-- Construct the container row for this specific variant configuration
					local variantRow = View {
						scope = innerScope,
						AutomaticSize = Enum.AutomaticSize.XY,
						tag = "row gap-medium align-y-center padding-medium radius-medium",
						backgroundStyle = if variant == ButtonVariant.OverMedia
							then theme:GetStyle("Extended", "White", "White_100")
							elseif colorMode then theme:GetTokenData(colorMode, "Surface", "Surface_100")
							else nil,
						children = {
							-- Apply an decorative background gradient strictly for OverMedia presentation rows
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

					table.insert(renderedStories, variantRow)
				end

				return renderedStories
			end),
		}
	end,
	controls = {
		icon = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Icons[1],
			List = Icons,
			DefIndex = 1
		},
		text = "Lorem ipsum",
		isDisabled = false,
		isLoading = false,
		colorMode = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = ControlModes[1],
			List = ControlModes,
			DefIndex = 1
		},
		fillBehavior = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = FillBehaviors[1],
			List = FillBehaviors,
			DefIndex = 1
		},
		inputDelay = 0,
	},
}