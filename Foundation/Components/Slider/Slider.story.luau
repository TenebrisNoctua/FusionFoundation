local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Slider = require(script.Parent)

local Icon = require(Components.Icon)
local Knob = require(Components.Knob)
local View = require(Components.View)
local Button = require(Components.Button)
local ScrollView = require(Components.ScrollView)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local StorySection = require(Utility.Stories.StorySection)
local CommonControls = require(Utility.Stories.CommonControls)

local IconSize = require(Enums.IconSize)
local InputSize = require(Enums.InputSize)
local Visibility = require(Enums.Visibility)
local SliderVariant = require(Enums.SliderVariant)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local Children = Fusion.Children

type Scope = Types.Scope
type Use = Types.Use

local function PlaygroundStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls
	local value = scope:Value(0.5)

	return Slider {
		scope = scope,
		value = value,
		range = scope:Computed(function(use: Use)
			return NumberRange.new(unwrap(controls.rangeMin, use), unwrap(controls.rangeMax, use))
		end),
		size = controls.size,
		knobVisibility = controls.knobVisibility,
		variant = controls.variant,
		isDisabled = controls.isDisabled,
		isContained = controls.isContained,
		step = controls.step,
		onValueChanged = function(newValue: number)
			value:set(newValue)
		end,
		knob = scope:Computed(function(use: Use, iconScope: Scope)
			if not unwrap(controls.hasCustomKnob, use) then return nil end
			return Icon {
				scope = iconScope,
				name = "icons/graphic/logomark-gradient_xlarge",
				size = IconSize.Medium,
			}
		end),
		onDragStarted = function()
			print("Drag started. Previous value:", unwrap(value))
		end,
		onDragEnded = function()
			print("Drag ended. Final value:", unwrap(value))
		end,
		LayoutOrder = props.layoutOrder,
	}
end

local function MediaTimelineStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	local value = scope:Value(0.25)
	local isPlaying = scope:Value(false)
	local wasPlaying = false
	local playbackThread: thread? = nil

	local function stopPlaybackThread()
		if playbackThread then
			task.cancel(playbackThread)
			playbackThread = nil
		end
	end

	local function startPlaybackThread()
		stopPlaybackThread()
		playbackThread = task.spawn(function()
			while true do
				value:set(unwrap(value) + 1 / 600)
				task.wait(1 / 16)
			end
		end)
	end

	table.insert(scope, stopPlaybackThread)

	local function onDragStarted()
		if unwrap(isPlaying) then
			wasPlaying = true
		end
		isPlaying:set(false)
		stopPlaybackThread()
	end

	local function onDragEnded()
		if wasPlaying then
			isPlaying:set(true)
			startPlaybackThread()
		end
		wasPlaying = false
	end

	local function onTogglePlayback()
		local newIsPlaying = not unwrap(isPlaying)
		isPlaying:set(newIsPlaying)
		if newIsPlaying then
			startPlaybackThread()
		else
			stopPlaybackThread()
		end
	end

	return View {
		scope = scope,
		tag = "col gap-small size-full-0 auto-y",
		LayoutOrder = props.layoutOrder,
		children = {
			Slider = Slider {
				scope = scope,
				value = value,
				size = InputSize.XSmall,
				knobVisibility = Visibility.Auto,
				variant = SliderVariant.Standard,
				onValueChanged = function(newValue: number)
					value:set(newValue)
				end,
				onDragStarted = onDragStarted,
				onDragEnded = onDragEnded,
				LayoutOrder = 1,
			},
			Playback = Button {
				scope = scope,
				text = scope:Computed(function(use: Use)
					return if unwrap(isPlaying, use) then "Pause" else "Play"
				end),
				onActivated = onTogglePlayback,
				LayoutOrder = 2,
			},
		},
	}
end

local function CustomStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	local theme = ThemeProvider()
	local value = scope:Value(0.5)

	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local startColor = tokens.Color.Extended.Blue.Blue_1400
		local endColor = tokens.Color.Extended.Blue.Blue_100

		local knobStyle = innerScope:Computed(function(use: Use)
			local alpha = unwrap(value, use)
			return {
				Color3 = startColor.Color3:Lerp(endColor.Color3, alpha),
				Transparency = startColor.Transparency + (endColor.Transparency - startColor.Transparency) * alpha,
			}
		end)

		return View {
			scope = innerScope,
			tag = "size-full-0 auto-y stroke-standard stroke-emphasis radius-circle",
			backgroundStyle = tokens.Color.Extended.White.White_100,
			LayoutOrder = props.layoutOrder,
			children = {
				Gradient = innerScope:New "UIGradient" {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, startColor.Color3),
						ColorSequenceKeypoint.new(1, endColor.Color3),
					}),
				},
				ColorSlider = Slider {
					scope = innerScope,
					value = value,
					size = InputSize.Medium,
					variant = SliderVariant.Utility,
					isContained = true,
					knob = Knob {
						scope = innerScope,
						size = InputSize.Large,
						style = knobStyle,
						stroke = {
							Color = tokens.Color.System.Neutral.Color3,
							Transparency = tokens.Color.System.Neutral.Transparency,
							Thickness = math.round(tokens.Stroke.Thick),
						},
						hasShadow = true,
					},
					knobVisibility = Visibility.Always,
					onValueChanged = function(newValue: number)
						value:set(newValue)
					end,
					width = UDim.new(1, 0),
				},
			},
		}
	end)
end

local NUM_ROTATED_SLIDERS = 7

local function RotatedStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	local value = scope:Value(0.5)

	local sliders = {}
	for index = 1, NUM_ROTATED_SLIDERS do
		local rotation = (index - 1) * (360 / NUM_ROTATED_SLIDERS)
		sliders[index] = View {
			scope = scope,
			Size = UDim2.fromScale(1 / NUM_ROTATED_SLIDERS, 0),
			LayoutOrder = index,
			children = {
				Folder = scope:New "Folder" {
					[Children] = View {
						scope = scope,
						tag = "size-full",
						Rotation = rotation,
						children = {
							Slider = Slider {
								scope = scope,
								value = value,
								onValueChanged = function(newValue: number)
									value:set(newValue)
								end
							}
						}
					}
				}
			}
		}
	end

	return View {
		scope = scope,
		tag = "row align-y-center size-full-3000",
		LayoutOrder = props.layoutOrder,
		children = sliders
	}
end

return {
	fusion = Fusion,
	summary = 'If dragging does not work make sure to deselect any tools in Studio! By default the "Select" tool is selected and will interfere with dragging behavior',
	controls = {
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = InputSize.Medium,
			List = Dash.values(InputSize),
			DefIndex = 3,
		},
		knobVisibility = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Visibility.Auto,
			List = Dash.values(Visibility),
			DefIndex = 1,
		},
		isDisabled = false,
		isContained = false,
		variant = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = SliderVariant.Standard,
			List = Dash.values(SliderVariant),
			DefIndex = 1,
		},
		hasCustomKnob = false,
		rangeMin = -50,
		rangeMax = 100,
		step = 0,
		theme = CommonControls.theme
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
					AutomaticCanvasSize = Enum.AutomaticSize.XY	
				},
				children = {
					StorySection {
						scope = innerScope,
						title = "Playground",
						layoutOrder = 1,
						children = { PlaygroundStory { scope = innerScope, controls = controls, layoutOrder = 2 } },
					},
					StorySection {
						scope = innerScope,
						title = "Media timeline",
						description = "Press the Play button to simulate media playback, then click and drag to seek around the timeline",
						layoutOrder = 2,
						children = { MediaTimelineStory { scope = innerScope, layoutOrder = 3 } },
					},
					StorySection {
						scope = innerScope,
						title = "Custom",
						description = "Color slider with gradient background",
						layoutOrder = 3,
						children = { CustomStory { scope = innerScope, layoutOrder = 3 } },
					},
					StorySection {
						scope = innerScope,
						title = "Rotated",
						description = "Sliders in containers rotated",
						layoutOrder = 4,
						children = { RotatedStory { scope = innerScope, layoutOrder = 3 } },
					}
				}
			}
		end)
	end)
}
