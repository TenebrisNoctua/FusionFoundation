local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Loading = require(script.Parent)
local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local IconSize = require(Enums.IconSize)

local function Story(props)
	local scope = props.scope
	local controls = props.controls

	return Loading {
		scope = scope,
		size = controls.size,
		isDisabled = controls.isDisabled
	}
end

return {
	summary = "Loading component",
	fusion = Fusion,
	controls = {
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = IconSize.Large,
			List = { IconSize.Large, IconSize.Medium, IconSize.Small },
			DefIndex = 1,
		},
		isDisabled = false,
	},
	story = StoryMiddleware(Story)
}
