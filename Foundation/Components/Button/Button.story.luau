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

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local CommonControls = require(Utility.Stories.CommonControls)
local StorySection = require(Utility.Stories.StorySection)

local InputSize = require(Enums.InputSize)
local ButtonVariant = require(Enums.ButtonVariant)

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

type Scope = Types.Scope
type Use = Types.Use

type InputSize = InputSize.InputSize

return {
	fusion = Fusion,
	summary = "Button",
	story = StoryMiddleware(function(props)
		local scope = props.scope
		local controls = props.controls
		local theme = ThemeProvider()

		return ScrollView {
			scope = scope,
			AutomaticSize = Enum.AutomaticSize.XY,
			scroll = {
				AutomaticSize = Enum.AutomaticSize.XY
			},
			tag = "padding-medium radius-medium back-clear",
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

				for _, variant in ButtonVariant do
					local buttonsForSizes = {
						innerScope:New "UIListLayout" {
							FillDirection = Enum.FillDirection.Horizontal,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0, 12),
						}
					}

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
					
					local variantStory = StorySection {
						scope = innerScope,
						title = variant,
						children = {variantRow}
					}

					table.insert(renderedStories, variantStory)
				end

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
		colorNamespace = CommonControls.colorNamespace,
		fillBehavior = CommonControls.fillBehavior,
		theme = CommonControls.theme,
		text = "Lorem ipsum",
		isDisabled = false,
		isLoading = false,
		inputDelay = 0
	},
}