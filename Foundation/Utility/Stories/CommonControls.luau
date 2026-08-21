local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Dash = PackageManager.getPackage("Dash")

local Enums = Foundation.Enums

local ColorNamespace = require(Enums.ColorNamespace)
local FillBehavior = require(Enums.FillBehavior)
local Device = require(Enums.Device)

local ColorNamespaces = Dash.values(ColorNamespace)

local FillBehaviors = {
	"None",
	FillBehavior.Fit,
	FillBehavior.Fill
}

local Devices = Dash.values(Device)

return {
	colorNamespace = {
		EntryType = "Control",
		Type = "Choose",
		ControlValue = ColorNamespaces[1],
		List = ColorNamespaces,
		DefIndex = 1
	},
	fillBehavior = {
		EntryType = "Control",
		Type = "Choose",
		ControlValue = FillBehaviors[1],
		List = FillBehaviors,
		DefIndex = 1
	},
	theme = {
		EntryType = "Control",
		Type = "Choose",
		ControlValue = "Dark",
		List = {"Dark", "Light"},
		DefIndex = 1
	},
	device = {
		EntryType = "Control",
		Type = "Choose",
		ControlValue = Devices[1],
		List = Devices,
		DefIndex = 1
	},
	preferredTextSize = {
		EntryType = "Control",
		Type = "Choose",
		ControlValue = Enum.PreferredTextSize.Medium,
		List = Dash.values(Enum.PreferredTextSize:GetEnumItems()),
		DefIndex = 1
	},
	preferredTransparency = {
		EntryType = "Control",
		Type = "Slider",
		ControlValue = 1,
		Min = 0,
		Max = 1,
		Step = 0.05
	},
	reducedMotion = {
		EntryType = "Control",
		Type = "Toggle",
		ControlValue = false
	},
	scale = {
		EntryType = "Control",
		Type = "Slider",
		ControlValue = 1,
		Min = 0.5,
		Max = 2,
		Step = 0.05
	}
}