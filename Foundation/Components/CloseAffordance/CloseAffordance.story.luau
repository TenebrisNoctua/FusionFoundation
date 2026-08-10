local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local CloseAfforadance = require(Components.CloseAffordance)
local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)
local StorySection = require(Utility.Stories.StorySection)

local ColorMode = require(Enums.ColorMode)
local InputSize = require(Enums.InputSize)
local CloseAffordanceVariant = require(Enums.CloseAffordanceVariant)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local Children = Fusion.Children

type Scope = Types.Scope
type Use = Types.Use

type InputSize = InputSize.InputSize
type CloseAffordanceVariant = CloseAffordanceVariant.CloseAffordanceVariant

return {
	fusion = Fusion,
	summary = "CloseAffordance",
	story = function(props)
		local scope = props.scope
		local controls = props.controls

		local theme, cleanup = ThemeProvider({
			theme = props.controls.theme
		})
		table.insert(scope, cleanup)
		theme.Presentation.colorMode = controls.colorMode
		
		return View {
			scope = scope,
			AutomaticSize = Enum.AutomaticSize.XY,
			tag = "padding-medium radius-medium back-clear",
			children = scope:Computed(function(use: Use, innerScope: Scope)
				local renderedStories = {
					innerScope:New "UIListLayout" {
						FillDirection = Enum.FillDirection.Vertical,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 16),
					},
					theme.StyleLink
				}
				
				local colorMode = unwrap(controls.colorMode, use)
				local tokens = unwrap(theme.Tokens, use)
				
				for _, variant in CloseAffordanceVariant do
					local variantsForSizes = {
						innerScope:New "UIListLayout" {
							FillDirection = Enum.FillDirection.Horizontal,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0, 12),
						}
					}

					local sizes = { InputSize.Medium, InputSize.Small, InputSize.XSmall }
					for _, size in sizes do
						table.insert(variantsForSizes, CloseAfforadance {
							scope = innerScope,
							onActivated = function()
								print(`{colorMode} {variant} Button ({size}) activated`)
							end,
							isDisabled = unwrap(controls.isDisabled, use),
							size = size,
							variant = variant
						})
					end
					
					local variantRow = View {
						scope = innerScope,
						tag = "row align-y-center gap-medium size-0-0 auto-xy padding-medium radius-medium",
						LayoutOrder = 2,
						backgroundStyle = if variant == CloseAffordanceVariant.OverMedia
							then tokens.Color.Extended.White.White_100
							elseif colorMode then tokens[colorMode].Surface.Surface_100
							else nil,
						children = {
							if variant == CloseAffordanceVariant.OverMedia
								then innerScope:New "UIGradient" {
									Color = ColorSequence.new({
										ColorSequenceKeypoint.new(0, tokens.Color.Extended.Green.Green_500.Color3),
										ColorSequenceKeypoint.new(1, tokens.Color.Extended.Blue.Blue_500.Color3),
									}),
								} else nil,
							
							[Children] = variantsForSizes
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
	end,
	controls = {
		theme = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = "Dark",
			List = {"Dark", "Light"},
			DefIndex = 1
		},
		colorMode = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(ColorMode)[1],
			List = Dash.values(ColorMode),
			DefIndex = 1
		},
		isDisabled = false
	}
}