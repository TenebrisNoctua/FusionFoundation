local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Skeleton = require(script.Parent)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local StorySection = require(Utility.Stories.StorySection)
local CommonControls = require(Utility.Stories.CommonControls)

local Radius = require(Enums.Radius)

type Scope = Types.Scope
type Use = Types.Use

local function PlaygroundStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls

	return Skeleton {
		scope = scope,
		radius = controls.radius,
		Size = UDim2.fromOffset(100, 100),
		LayoutOrder = props.layoutOrder,
	}
end

return {
	fusion = Fusion,
	summary = "Skeleton component",
	controls = {
		radius = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Radius.None,
			List = Dash.values(Radius),
			DefIndex = 1,
		},
		theme = CommonControls.theme,
	},
	story = StoryMiddleware(function(props)
		local scope = props.scope
		local controls = props.controls

		return scope:Computed(function(use: Use, innerScope: Scope)
			unwrap(controls.theme, use)
			return StorySection {
				scope = innerScope,
				title = "Playground",
				children = { PlaygroundStory { scope = innerScope, controls = controls, layoutOrder = 2 } },
			}
		end)
	end),
}
