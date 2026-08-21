--!nonstrict

local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local EducationalTooltip = require(script.Parent)

local Text = require(Components.Text)
local View = require(Components.View)
local Button = require(Components.Button)
local Fragment = require(Components.Fragment)
local IconButton = require(Components.IconButton)
local ScrollView = require(Components.ScrollView)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local StorySection = require(Utility.Stories.StorySection)
local CommonControls = require(Utility.Stories.CommonControls)

local ButtonVariant = require(Enums.ButtonVariant)
local InputSize = require(Enums.InputSize)
local PopoverAlign = require(Enums.PopoverAlign)
local PopoverSide = require(Enums.PopoverSide)
local ColorNamespace = require(Enums.ColorNamespace)

type Scope = Types.Scope
type Use = Types.Use
type ActionProps = Types.ActionProps

type StepConfig = {
	id: number,
	text: string,
	hasActions: boolean,
	side: PopoverSide.PopoverSide,
	align: PopoverAlign.PopoverAlign,
}

local function generateActions(hasSecondaryButton: boolean)
	local actions: { ActionProps } = {
		{
			text = "Got it",
			onActivated = function()
				print("Primary button clicked")
			end,
			variant = ButtonVariant.Emphasis,
		}
	}

	if hasSecondaryButton then
		table.insert(actions, {
			text = "Skipppp",
			onActivated = function()
				print("Secondary button clicked")
			end,
			variant = ButtonVariant.Standard,
			colorNamespace = ColorNamespace.Inverse
		})
	end

	return actions
end

local stepConfigs: { StepConfig } = {
	{
		id = 1,
		text = "Step 1: Side=Right, Align=Start, anchor with action button",
		hasActions = true,
		side = PopoverSide.Right,
		align = PopoverAlign.Start,
	},
	{
		id = 2,
		text = "Step 2: Side=Left, Align=Start, NO actions",
		hasActions = false,
		side = PopoverSide.Left,
		align = PopoverAlign.Start,
	},
	{
		id = 3,
		text = "Step 3: Side=Top, Align=End, with action button",
		hasActions = true,
		side = PopoverSide.Top,
		align = PopoverAlign.End,
	},
	{
		id = 4,
		text = "Step 4: Side=Top, Align=Start, NO actions",
		hasActions = false,
		side = PopoverSide.Top,
		align = PopoverAlign.Start,
	},
	{
		id = 5,
		text = "Step 5: Side=Bottom, Align=Center, with action button",
		hasActions = false,
		side = PopoverSide.Bottom,
		align = PopoverAlign.Center,
	},
}

local function StoryPlayground(props)
	local scope = props.scope
	local controls = props.controls

	return scope:Computed(function(use: Use, innerScope: Scope)
		local hasCloseAffordance = unwrap(controls.hasCloseAffordance, use)
		local showSteps = unwrap(controls.showSteps, use)
		local hasActions = unwrap(controls.hasActions, use)
		local hasSecondaryButton = unwrap(controls.hasSecondaryButton, use)

		return View {
			scope = innerScope,
			tag = "row align-x-center align-y-center",
			Size = UDim2.new(1, 0, 0, 300),
			LayoutOrder = props.layoutOrder,
			children = {
				EducationalTooltip {
					scope = innerScope,
					title = controls.title,
					side = controls.side,
					align = controls.align,
					text = controls.text,
					isOpen = controls.isOpen,
					onClose = if hasCloseAffordance
						then function()
							print("Close affordance clicked")
						end
						else nil,
					steps = if showSteps
						then { current = 2, total = 5 }
						else nil,
					actions = if hasActions
						then generateActions(hasSecondaryButton)
						else nil,
					children = Fragment {
						{IconButton, {
							icon = "reactions/heart",
							size = InputSize.Medium,
							onActivated = function()
								print("Icon button clicked")
							end,
						}}
					}
				}
			}
		}
	end)
end

local function StoryMultiStepTutorial(props)
	local scope = props.scope

	local step = scope:Value(1)
	return scope:Computed(function(use: Use, innerScope: Scope)
		local currentStep = unwrap(step, use)
		local currentConfig = stepConfigs[currentStep]

		return View {
			scope = innerScope,
			tag = "col gap-small",
			Size = UDim2.new(1, 0, 0, 300),
			LayoutOrder = props.layoutOrder,
			children = {
				View {
					scope = innerScope,
					tag = "row align-y-center gap-small size-full-0 auto-y",
					LayoutOrder = 1,
					children = {
						Button {
							scope = innerScope,
							text = "Previous",
							onActivated = function()
								step:set(math.max(1, unwrap(step) - 1))
							end,
							variant = ButtonVariant.Standard,
							isDisabled = currentStep == 1,
							LayoutOrder = 1,
						},
						Button {
							scope = innerScope,
							text = "Next",
							onActivated = function()
								step:set(math.min(#stepConfigs, unwrap(step) + 1))
							end,
							variant = ButtonVariant.Standard,
							isDisabled = currentStep == #stepConfigs,
							LayoutOrder = 2,
						},
						Button {
							scope = innerScope,
							text = "Reset",
							onActivated = function()
								step:set(1)
							end,
							variant = ButtonVariant.Standard,
							LayoutOrder = 3,
						},
						Text {
							scope = innerScope,
							tag = "auto-xy text-body-medium",
							Text = `Step {currentStep} of {#stepConfigs} - Side: {currentConfig.side} - Actions: {if currentConfig.hasActions then "Yes" else "nil"}`,
							LayoutOrder = 4,
						},
					}
				},
				View {
					scope = innerScope,
					tag = "col align-x-center align-y-center auto-xy",
					Size = UDim2.new(1, 0, 1, 300),
					LayoutOrder = 2,
					children = {
						EducationalTooltip {
							scope = innerScope,
							title = `Tutorial Step {currentStep}`,
							text = currentConfig.text,
							isOpen = true,
							side = currentConfig.side,
							align = currentConfig.align,
							steps = {
								current = currentStep,
								total = #stepConfigs,
							},
							actions = if currentConfig.hasActions
								then {
									{
										text = "Next",
										variant = ButtonVariant.Emphasis,
										onActivated = function()
											step:set(math.min(#stepConfigs, unwrap(step) + 1))
										end
									}
								}
								else nil,
							children = Fragment {
								{Button, {
									size = InputSize.Large,
									text = "Button",
									width = UDim.new(1, 100),
									onActivated = function()
										print(`Anchor {currentStep} clicked`)
									end
								}}
							}
						}
					}
				}
			}
		}
	end)
end

return {
	fusion = Fusion,
	controls = {
		title = "Title",
		text = "EducationalTooltip body text",
		side = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(PopoverSide)[1],
			List = Dash.values(PopoverSide),
			DefIndex = 1
		},
		align = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(PopoverAlign)[1],
			List = Dash.values(PopoverAlign),
			DefIndex = 1
		},
		theme = CommonControls.theme,
		hasSecondaryButton = false,
		hasCloseAffordance = false,
		hasActions = true,
		isOpen = true,
		showSteps = true
	},
	story = StoryMiddleware(function(props)
		local scope = props.scope
		local controls = props.controls
		local theme = controls.theme
		
		return scope:Computed(function(use: Use, innerScope: Scope)
			unwrap(theme, use)
			return ScrollView {
				scope = innerScope,
				backgroundStyle = {
					Transparency = 1
				},
				tag = "auto-xy",
				children = {
					innerScope:New "UIListLayout" {
						Padding = UDim.new(0, 16),
						SortOrder = Enum.SortOrder.LayoutOrder,
					},
					StorySection {
						scope = innerScope,
						title = "Playground",
						children = {
							StoryPlayground {
								scope = innerScope,
								controls = controls,
								layoutOrder = 2
							}
						}
					},
					StorySection {
						scope = innerScope,
						title = "Multi-Step Tutorial",
						layoutOrder = 2,
						children = {
							StoryMultiStepTutorial {
								scope = innerScope,
								layoutOrder = 2
							}
						}
					}
				}
			}
		end) 
	end)
}
