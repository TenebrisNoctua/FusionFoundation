local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local CloseAffordance = require(Components.CloseAffordance)
local ScrollView = require(Components.ScrollView)
local Text = require(Components.Text)
local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local StorySection = require(Utility.Stories.StorySection)

local InputSize = require(Enums.InputSize)
local CloseAffordanceVariant = require(Enums.CloseAffordanceVariant)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

type InputSize = InputSize.InputSize
type CloseAffordanceVariant = CloseAffordanceVariant.CloseAffordanceVariant

type Controls = {
	variant: CloseAffordanceVariant,
	size: typeof(InputSize.Medium) | typeof(InputSize.Small) | typeof(InputSize.XSmall),
	isCircular: boolean,
	hasPadding: boolean,
	isDisabled: boolean,
}

type Theme = typeof(ThemeProvider())

local SIZES: { InputSize } = { InputSize.Medium, InputSize.Small, InputSize.XSmall }

local function activated(label: string)
	return function()
		print(`CloseAffordance: "{label}" activated`)
	end
end

local function Label(props: { scope: Scope, text: string, LayoutOrder: number }): Child
	return Text {
		scope = props.scope,
		Text = props.text,
		tag = "auto-xy text-label-small content-muted padding-bottom-xsmall",
		LayoutOrder = props.LayoutOrder
	}
end

local function Section(props: {
	scope: Scope,
	label: string,
	LayoutOrder: number,
	children: Child?,
}): Child
	return View {
		scope = props.scope,
		tag = "col gap-xsmall auto-xy align-y-center",
		LayoutOrder = props.LayoutOrder,
		children = {
			Label { scope = props.scope, text = props.label, LayoutOrder = 1 },
			View { scope = props.scope, tag = "row gap-small auto-xy align-y-center", LayoutOrder = 2, children = props.children }
		}
	}
end

local function MediaBackground(props: { scope: Scope, children: Child?, theme: Theme }): Child
	local tokens = unwrap(props.theme.Tokens)
	return View {
		scope = props.scope,
		tag = "row align-y-center gap-medium size-0 auto-xy padding-large radius-medium",
		backgroundStyle = tokens.Color.Extended.White.White_100,
		children = props.children
	}
end

local function PlaygroundStory(props: { scope: Scope, controls: Controls, theme: Theme, layoutOrder: number }): Child
	local controls = props.controls
	local tokens = unwrap(props.theme.Tokens)
	local isOverMedia = controls.variant == CloseAffordanceVariant.OverMedia
	
	return View {
		scope = props.scope,
		tag = "row align-x-center align-y-center size-0 auto-xy padding-xlarge radius-medium",
		backgroundStyle = if isOverMedia then tokens.Color.Extended.White.White_100 else nil,
		LayoutOrder = props.layoutOrder,
		children = {
			CloseAffordance {
				scope = props.scope,
				size = controls.size,
				variant = controls.variant,
				hasPadding = controls.hasPadding,
				isCircular = controls.isCircular,
				isDisabled = controls.isDisabled,
				onActivated = function()
					print(`CloseAffordance activated: {controls.variant} {controls.size}`)
				end
			}
		}
	}
end

local function OverMediaStory(props: { scope: Scope, theme: Theme, layoutOrder: number }): Child
	return View {
		scope = props.scope,
		tag = "col gap-large auto-xy",
		LayoutOrder = props.layoutOrder,
		children = {
			Section {
				scope = props.scope,
				label = "hasPadding = true",
				LayoutOrder = 1,
				children = MediaBackground {
					scope = props.scope,
					theme = props.theme,
					children = Dash.map(SIZES, function(size)
						return CloseAffordance {
							scope = props.scope,
							size = size,
							variant = CloseAffordanceVariant.OverMedia,
							hasPadding = true,
							onActivated = activated(`OverMedia padded {size}`),
						}
					end)
				}
			},
			Section {
				scope = props.scope,
				label = "hasPadding = false",
				LayoutOrder = 2,
				children = MediaBackground {
					scope = props.scope,
					theme = props.theme,
					children = Dash.map(SIZES, function(size)
						return CloseAffordance {
							scope = props.scope,
							size = size,
							variant = CloseAffordanceVariant.OverMedia,
							hasPadding = false,
							onActivated = activated(`OverMedia tight {size}`),
						}
					end)
				}
			},
		}
	}
end

local function UtilityStory(props: { scope: Scope, theme: Theme, layoutOrder: number }): Child
	return View {
		scope = props.scope,
		tag = "col gap-large auto-xy",
		LayoutOrder = props.layoutOrder,
		children = {
			Section {
				scope = props.scope,
				label = "isCircular = false",
				LayoutOrder = 1,
				children = Dash.map(SIZES, function(size)
					return CloseAffordance {
						scope = props.scope,
						size = size,
						variant = CloseAffordanceVariant.Utility,
						isCircular = false,
						hasPadding = true,
						onActivated = activated(`Utility rounded {size}`)
					}
				end)
			},
			Section {
				scope = props.scope,
				label = "isCircular = true",
				LayoutOrder = 2,
				children = Dash.map(SIZES, function(size)
					return CloseAffordance {
						scope = props.scope,
						size = size,
						variant = CloseAffordanceVariant.Utility,
						isCircular = true,
						hasPadding = true,
						onActivated = activated(`Utility circular {size}`)
					}
				end)
			},
			Section {
				scope = props.scope,
				label = "hasPadding = false, isCircular = false",
				LayoutOrder = 3,
				children = Dash.map(SIZES, function(size)
					return CloseAffordance {
						scope = props.scope,
						size = size,
						variant = CloseAffordanceVariant.Utility,
						isCircular = false,
						hasPadding = false,
						onActivated = activated(`Utility tight rounded {size}`)
					}
				end)
			},
			Section {
				scope = props.scope,
				label = "hasPadding = false, isCircular = true",
				LayoutOrder = 4,
				children = Dash.map(SIZES, function(size)
					return CloseAffordance {
						scope = props.scope,
						size = size,
						variant = CloseAffordanceVariant.Utility,
						isCircular = true,
						hasPadding = false,
						onActivated = activated(`Utility tight circular {size}`)
					}
				end)
			}
		}
	}
end

local function DisabledStory(props: { scope: Scope, theme: Theme, layoutOrder: number }): Child
	return View {
		scope = props.scope,
		tag = "col gap-large auto-xy",
		LayoutOrder = props.layoutOrder,
		children = {
			Section {
				scope = props.scope,
				label = "OverMedia",
				LayoutOrder = 1,
				children = MediaBackground {
					scope = props.scope,
					theme = props.theme,
					children = Dash.map(SIZES, function(size)
						return CloseAffordance {
							scope = props.scope,
							size = size,
							variant = CloseAffordanceVariant.OverMedia,
							isDisabled = true,
							onActivated = activated(`OverMedia disabled {size}`)
						}
					end)
				}
			},
			Section {
				scope = props.scope,
				label = "Utility",
				LayoutOrder = 2,
				children = Dash.map(SIZES, function(size)
					return CloseAffordance {
						scope = props.scope,
						size = size,
						variant = CloseAffordanceVariant.Utility,
						isDisabled = true,
						onActivated = activated(`Utility disabled {size}`)
					}
				end)
			}
		}
	}
end

return {
	fusion = Fusion,
	summary = "CloseAffordance",
	story = StoryMiddleware(function(props)
		local scope = props.scope
		local controls = props.controls
		local themeProvider = ThemeProvider()
		
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
				
				local tokens = unwrap(themeProvider.Tokens, use)
				
				local controls = {
					size = unwrap(controls.size, use),
					variant = unwrap(controls.variant, use),
					isCircular = unwrap(controls.isCircular, use),
					hasPadding = unwrap(controls.hasPadding, use),
					isDisabled = unwrap(controls.isDisabled, use)
					
				}

				table.insert(renderedStories, StorySection {
					scope = innerScope,
					title = "Playground",
					children = {PlaygroundStory {
						scope = innerScope,
						controls = controls,
						theme = themeProvider,
						layoutOrder = 2
					}}
				})
				
				table.insert(renderedStories, StorySection {
					scope = innerScope,
					title = "OverMedia",
					layoutOrder = 2,
					children = {OverMediaStory {
						scope = innerScope,
						theme = themeProvider,
						layoutOrder = 2
					}}
				})
				
				table.insert(renderedStories, StorySection {
					scope = innerScope,
					title = "Utility",
					layoutOrder = 3,
					children = {UtilityStory {
						scope = innerScope,
						theme = themeProvider,
						layoutOrder = 2
					}}
				})
				
				table.insert(renderedStories, StorySection {
					scope = innerScope,
					title = "Disabled",
					layoutOrder = 4,
					children = {DisabledStory {
						scope = innerScope,
						theme = themeProvider,
						layoutOrder = 2
					}}
				})
				
				return renderedStories
			end)
		}
	end),
	controls = {
		theme = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = "Dark",
			List = {"Dark", "Light"},
			DefIndex = 1
		},
		variant = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(CloseAffordanceVariant)[1],
			List = Dash.values(CloseAffordanceVariant),
			DefIndex = 1
		},
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(SIZES)[1],
			List = Dash.values(SIZES),
			DefIndex = 1
		},
		isCircular = true,
		hasPadding = true,
		isDisabled = false
	}
}