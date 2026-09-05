local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Divider = require(script.Parent)

local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local StorySection = require(Utility.Stories.StorySection)
local CommonControls = require(Utility.Stories.CommonControls)

local DividerVariant = require(Enums.DividerVariant)
local Orientation = require(Enums.Orientation)

type Scope = Types.Scope
type Use = Types.Use

local function PlaygroundStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls

	return View {
		scope = scope,
		tag = "align-x-center align-y-center gap-large size-full-2000 padding-large bg-surface-0",
		LayoutOrder = props.layoutOrder,
		children = {
			Divider {
				scope = scope,
				variant = controls.variant,
				orientation = controls.orientation,
			},
		},
	}
end

local function HorizontalStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	local variants = Dash.values(DividerVariant)

	local children = {}
	for index, variant in variants do
		children["Divider-" .. tostring(variant)] = Divider {
			scope = scope,
			variant = variant,
			orientation = Orientation.Horizontal,
			LayoutOrder = index,
		}
	end

	return View {
		scope = scope,
		tag = "col align-y-center gap-xxlarge size-full-2000 padding-large bg-surface-0",
		LayoutOrder = props.layoutOrder,
		children = children,
	}
end

local function VerticalStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope

	return View {
		scope = scope,
		tag = "row align-x-center align-y-center gap-large size-full-2000 padding-large bg-surface-0",
		LayoutOrder = props.layoutOrder,
		children = {
			Divider {
				scope = scope,
				orientation = Orientation.Vertical,
			},
		},
	}
end

return {
	fusion = Fusion,
	summary = "Divider",
	controls = {
		variant = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = DividerVariant.Default,
			List = Dash.values(DividerVariant),
			DefIndex = 1,
		},
		orientation = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Orientation.Horizontal,
			List = Dash.values(Orientation),
			DefIndex = 1,
		},
		theme = CommonControls.theme,
	},
	story = StoryMiddleware(function(props)
		local scope = props.scope
		local controls = props.controls

		return scope:Computed(function(use: Use, innerScope: Scope)
			unwrap(controls.theme, use)

			return View {
				scope = innerScope,
				tag = "col size-full-0 auto-y padding-large gap-xxlarge",
				children = {
					StorySection {
						scope = innerScope,
						title = "Playground",
						layoutOrder = 1,
						children = { PlaygroundStory { scope = innerScope, controls = controls, layoutOrder = 2 } },
					},
					StorySection {
						scope = innerScope,
						title = "Horizontal",
						description = "All variants (Default, Heavy, Inset, InsetLeft, InsetRight)",
						layoutOrder = 2,
						children = { HorizontalStory { scope = innerScope, layoutOrder = 3 } },
					},
					StorySection {
						scope = innerScope,
						title = "Vertical",
						description = "Vertical divider (variant not applicable)",
						layoutOrder = 3,
						children = { VerticalStory { scope = innerScope, layoutOrder = 3 } },
					},
				},
			}
		end)
	end),
}
