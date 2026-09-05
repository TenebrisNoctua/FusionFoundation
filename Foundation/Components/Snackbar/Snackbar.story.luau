local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Utility = Foundation.Utility

local Snackbar = require(script.Parent)
local View = require(Foundation.Components.View)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local StorySection = require(Utility.Stories.StorySection)
local CommonControls = require(Utility.Stories.CommonControls)

type Scope = Types.Scope
type Use = Types.Use

local function PlaygroundStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls

	return scope:Computed(function(use: Use, innerScope: Scope)
		local hasCloseAffordance = unwrap(controls.hasCloseAffordance, use)
		return Snackbar {
			scope = innerScope,
			action = innerScope:Computed(function(use2: Use)
				local actionText = unwrap(controls.actionText, use2)
				if actionText == "" then return nil end
				return {
					text = actionText,
					onActivated = function()
						print("action activated")
					end,
				}
			end),
			icon = innerScope:Computed(function(use2: Use)
				local icon = unwrap(controls.icon, use2)
				return if icon ~= "" then icon else nil
			end),
			onClose = if hasCloseAffordance
				then function()
					print("close clicked!")
				end
				else nil,
			title = controls.title,
			LayoutOrder = props.layoutOrder
		}
	end)
end

local function NoButtonSnackbarStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls

	return Snackbar {
		scope = scope,
		icon = scope:Computed(function(use: Use)
			local icon = unwrap(controls.icon, use)
			return if icon ~= "" then icon else nil
		end),
		title = controls.title,
		LayoutOrder = props.layoutOrder
	}
end

return {
	fusion = Fusion,
	summary = "Snackbar",
	controls = {
		icon = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = "diamond-simplified",
			List = { "diamond-simplified", "" },
			DefIndex = 1,
		},
		title = "This is a snackbar!",
		actionText = "Primary",
		hasCloseAffordance = true,
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
						title = "No Button Snackbar",
						layoutOrder = 2,
						children = { NoButtonSnackbarStory { scope = innerScope, controls = controls, layoutOrder = 2 } },
					}
				}
			}
		end)
	end)
}
