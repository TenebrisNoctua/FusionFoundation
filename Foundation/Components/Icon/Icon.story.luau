local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")
local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Enums = Foundation.Enums

local IconSize = require(Enums.IconSize)

local Icon = require(script.Parent)
local View = require(Foundation.Components.View)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local iconNames = Dash.values(BuilderIcons.Icon)
local iconVariants = Dash.values(BuilderIcons.IconVariant)

local function Story(props)
	local scope = props.scope
	local controls = props.controls
	
	local theme, cleanup = ThemeProvider()
	table.insert(scope, cleanup)

	local sizes: { IconSize.IconSize } = { IconSize.Large, IconSize.Medium, IconSize.Small, IconSize.XSmall }

	local children = {
		theme.StyleLink
	}
	for index, size in ipairs(sizes) do
		children["Icon" .. tostring(index)] = Icon {
			scope = scope,
			name = controls.name,
			size = size,
			variant = controls.variant,
			LayoutOrder = index,
		}
	end

	return View {
		scope = scope,
		tag = "row align-y-center gap-xxlarge auto-xy",
		children = children,
	}
end

return {
	summary = "Icon component for displaying icons",
	fusion = Fusion,
	story = Story,
	controls = {
		name = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = iconNames[1],
			List = iconNames,
			DefIndex = 1,
		},
		variant = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = iconVariants[1],
			List = iconVariants,
			DefIndex = 1,
		},
	},
}