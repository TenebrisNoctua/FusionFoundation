local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local StorySection = require(Utility.Stories.StorySection)
local CommonControls = require(Utility.Stories.CommonControls)

local InputSize = require(Enums.InputSize)
local ButtonVariant = require(Enums.ButtonVariant)
local FillBehavior = require(Enums.FillBehavior)

local Button = require(Foundation.Components.Button)
local View = require(Foundation.Components.View)

type InputSize = InputSize.InputSize
type ButtonVariant = ButtonVariant.ButtonVariant
type FillBehavior = FillBehavior.FillBehavior

type Scope = Types.Scope
type Use = Types.Use

local buttonProps: { { text: string, variant: ButtonVariant } } = {
	{ text = "Cancel", variant = ButtonVariant.Standard :: ButtonVariant },
	{ text = "Continue without accepting", variant = ButtonVariant.SoftEmphasis },
	{ text = "Accept", variant = ButtonVariant.Emphasis },
}

local function BasicStory(props)
	local scope = props.scope
	local controls = props.controls
	
	return View {
		scope = scope,
		LayoutOrder = props.layoutOrder,
		tag = scope:Computed(function(use)
			local fill = unwrap(controls.fillBehavior, use)
			return "row wrap gap-small size-full-0 auto-y" .. (if fill == FillBehavior.Fill then " fill-x" else "")
		end),
		children = {
			Button {
				scope = scope,
				text = "BUT WAIT NO CLICK ME!!!",
				icon = "icons/common/robux",
				variant = ButtonVariant.Emphasis,
				onActivated = function()
					print("PrimaryButton clicked!")
				end,
				fillBehavior = controls.fillBehavior,
				size = controls.size,
				LayoutOrder = 2,
			},
			Button {
				scope = scope,
				text = controls.text,
				variant = ButtonVariant.Standard,
				onActivated = function()
					print("SecondaryButton clicked!")
				end,
				fillBehavior = controls.fillBehavior,
				size = controls.size,
				LayoutOrder = 1,
			},
		}
	}
end

local function EqualWidthsStory(props)
	local scope = props.scope

	return View {
		scope = scope,
		LayoutOrder = props.layoutOrder,
		tag = "row gap-small size-full-0 auto-y",
		children = scope:Computed(function(use, innerScope)
			return Dash.map(buttonProps, function(btnProps)
				return Button {
					scope = innerScope,
					text = btnProps.text,
					variant = btnProps.variant,
					onActivated = function()
						print(btnProps.text .. " clicked!")
					end,
					fillBehavior = FillBehavior.Fill,
					size = InputSize.Medium,
					width = UDim.new(1, 0),
				}
			end)
		end)
	}
end

return {
	fusion = Fusion,
	summary = "Button Group",
	controls = {
		text = "Click me!",
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(InputSize)[1],
			List = Dash.values(InputSize),
			DefIndex = 1,
		},
		fillBehavior = CommonControls.fillBehavior,
		theme = CommonControls.theme
	},
	story = StoryMiddleware(function(props)
		local scope = props.scope
		local controls = props.controls

		return View {
			scope = scope,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.fromScale(1, 0),
			BackgroundTransparency = 1,
			children = {
				scope:New "UIListLayout" {
					Padding = UDim.new(0, 16),
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				
				StorySection {
					scope = scope,
					title = "Basic",
					description = "Button size based on their content, either filling the container or fitting the content.",
					children = {
						BasicStory {
							scope = scope,
							controls = controls,
							layoutOrder = 3
						}
					}
				},
				
				StorySection {
					scope = scope,
					title = "Evenly sized buttons",
					description = "All buttons are the same width, regardless of their content.",
					layoutOrder = 2,
					children = {
						EqualWidthsStory {
							scope = scope,
							controls = controls,
							layoutOrder = 3
						}
					}
				}
			}
		}
	end)
}