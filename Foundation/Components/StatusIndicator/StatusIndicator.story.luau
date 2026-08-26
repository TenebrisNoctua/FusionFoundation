local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local StatusIndicator = require(script.Parent)

local View = require(Components.View)
local Text = require(Components.Text)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local StorySection = require(Utility.Stories.StorySection)
local CommonControls = require(Utility.Stories.CommonControls)

local StatusIndicatorVariant = require(Enums.StatusIndicatorVariant)
local StatusIndicatorShape = require(Enums.StatusIndicatorShape)
local StatusIndicatorSize = require(Enums.StatusIndicatorSize)

type Scope = Types.Scope

type StatusIndicatorVariant = StatusIndicatorVariant.StatusIndicatorVariant
type StatusIndicatorShape = StatusIndicatorShape.StatusIndicatorShape
type StatusIndicatorSize = StatusIndicatorSize.StatusIndicatorSize

local function getVariants(): { StatusIndicatorVariant }
	local variants: { StatusIndicatorVariant } = {}
	for _, variant in StatusIndicatorVariant do
		table.insert(variants, variant :: StatusIndicatorVariant)
	end
	return variants
end

local shapes: { StatusIndicatorShape } = {
	StatusIndicatorShape.Circle,
	StatusIndicatorShape.Ring,
	StatusIndicatorShape.Square,
}

local function PlaygroundStory(props)
	local scope = props.scope

	return View {
		scope = scope,
		tag = "col gap-large size-full-0 auto-y",
		LayoutOrder = props.layoutOrder,
		children = {
			StatusIndicator {
				scope = scope,
				variant = props.variant,
				shape = props.shape,
				size = props.size,
				value = props.value,
				max = props.max
			}
		}
	}
end

local function AllVariantsStory(props)
	local scope = props.scope

	local order = 0
	local children = {}

	for _, variant: StatusIndicatorVariant in getVariants() do
		order += 1
		children[variant .. "_label"] = Text {
			scope = scope,
			Text = variant :: string,
			tag = "auto-xy text-label-medium content-muted",
			LayoutOrder = order,
		}

		local indicators = Dash.map(shapes, function(shape, i)
			return StatusIndicator {
				scope = scope,
				variant = variant :: StatusIndicatorVariant,
				shape = shape :: StatusIndicatorShape,
				LayoutOrder = i,
			}
		end)
		
		table.insert(indicators, StatusIndicator {
			scope = scope,
			variant = variant,
			value = 5,
			LayoutOrder = #indicators + 1,
		})

		order += 1
		children[variant .. "_row"] = View {
			scope = scope,
			tag = "row align-y-center gap-medium auto-xy",
			LayoutOrder = order,
			children = indicators,
		}
	end

	return View {
		scope = scope,
		tag = "col gap-small size-full-0 auto-y",
		LayoutOrder = props.layoutOrder,
		children = children,
	}
end

return {
	fusion = Fusion,
	controls = {
		variant = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(StatusIndicatorVariant)[1],
			List = Dash.values(StatusIndicatorVariant),
			DefIndex = 1,
		},
		shape = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = shapes[1],
			List = shapes,
			DefIndex = 1,
		},
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(StatusIndicatorSize)[1],
			List = Dash.values(StatusIndicatorSize),
			DefIndex = 1,
		},
		value = 0,
		max = 99,
		theme = CommonControls.theme,
	},
	story = StoryMiddleware(function(props)
		local scope = props.scope
		local controls = props.controls

		return scope:Computed(function(use, innerScope: Scope)
			unwrap(controls.theme, use)

			return View {
				scope = innerScope,
				tag = "auto-xy",
				children = {
					innerScope:New "UIListLayout" {
						Padding = UDim.new(0, 16),
						SortOrder = Enum.SortOrder.LayoutOrder
					},

					StorySection {
						scope = innerScope,
						title = "Playground",
						children = {
							PlaygroundStory {
								scope = innerScope,
								variant = controls.variant,
								shape = controls.shape,
								size = controls.size,
								value = controls.value,
								max = controls.max,
								layoutOrder = 2
							}
						}
					},

					StorySection {
						scope = innerScope,
						title = "All Variants",
						description = "All variant x shape permutations, plus numeric where supported",
						layoutOrder = 2,
						children = {
							AllVariantsStory {
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