local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local AvatarIcon = require(script.Parent)
local View = require(Components.View)
local Text = require(Components.Text)
local ScrollView = require(Components.ScrollView)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StorySection = require(Utility.Stories.StorySection)
local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local CommonControls = require(Utility.Stories.CommonControls)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local AvatarIconSize = require(Enums.AvatarIconSize)
type AvatarIconSize = AvatarIconSize.AvatarIconSize

type Scope = Types.Scope
type Use = Types.Use

local orderedSizes: { AvatarIconSize } = {
	AvatarIconSize.XSmall,
	AvatarIconSize.Small,
	AvatarIconSize.Medium,
	AvatarIconSize.Large,
	AvatarIconSize.XLarge,
}

local surfaceColorKeys = { "None", "Surface_0", "Surface_100", "Surface_200", "Surface_300" }

local function getSurfaceColors(tokens)
	return {
		None = nil,
		Surface_0 = tokens.Color.Surface.Surface_0,
		Surface_100 = tokens.Color.Surface.Surface_100,
		Surface_200 = tokens.Color.Surface.Surface_200,
		Surface_300 = tokens.Color.Surface.Surface_300,
	}
end

local function StoryPlayground(props)
	local scope = props.scope
	local controls = props.controls
	local theme = ThemeProvider()

	return View {
		scope = scope,
		Size = UDim2.new(1, 0, 0, 200),
		tag = "row align-x-center align-y-center",
		LayoutOrder = props.layoutOrder,
		children = {
			scope:Computed(function(use: Use, innerScope: Scope)
				local tokens = unwrap(theme.Tokens, use)
				local surfaceColors = getSurfaceColors(tokens)
				local bpKey = unwrap(controls.backplate, use)
				local bgKey = unwrap(controls.background, use)

				return AvatarIcon {
					scope = innerScope,
					userId = unwrap(controls.userId, use),
					size = unwrap(controls.size, use),
					backplateStyle = surfaceColors[bpKey],
					backgroundStyle = surfaceColors[bgKey],
				}
			end)
		}
	}
end

local function StorySizes(props)
	local scope = props.scope

	local children = {}
	for index, size in orderedSizes do
		table.insert(children, View {
			scope = scope,
			tag = "col gap-medium auto-xy",
			LayoutOrder = index,
			children = {
				Text {
					scope = scope,
					Text = size,
					tag = "text-body-small content-default auto-xy",
					LayoutOrder = 1,
				},
				AvatarIcon {
					scope = scope,
					userId = 24813339,
					size = size,
					LayoutOrder = 2,
				}
			},
		})
	end

	return View {
		scope = scope,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		tag = "row gap-xlarge auto-xy align-y-center",
		LayoutOrder = props.layoutOrder,
		children = children,
	}
end

return {
	fusion = Fusion,
	summary = "AvatarIcon",
	controls = {
		userId = 24813339,
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = AvatarIconSize.Medium,
			List = Dash.values(AvatarIconSize),
			DefIndex = 3,
		},
		backplate = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = "None",
			List = surfaceColorKeys,
			DefIndex = 1,
		},
		background = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = "None",
			List = surfaceColorKeys,
			DefIndex = 1,
		},
		theme = CommonControls.theme,
	},
	story = StoryMiddleware(function(props)
		local scope = props.scope
		local controls = props.controls

		return ScrollView {
			scope = scope,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.fromScale(1, 0),
			scroll = {
				AutomaticSize = Enum.AutomaticSize.Y,
				ScrollingDirection = Enum.ScrollingDirection.Y,
			},
			tag = "back-clear",
			children = {
				scope:New "UIListLayout" {
					Padding = UDim.new(0, 16),
					SortOrder = Enum.SortOrder.LayoutOrder,
				},

				StorySection {
					scope = scope,
					title = "Playground",
					description = "Interactive avatar icon with configurable size, backplate, and background.",
					layoutOrder = 1,
					children = {
						StoryPlayground {
							scope = scope,
							controls = controls,
							layoutOrder = 3,
						}
					}
				},

				StorySection {
					scope = scope,
					title = "Sizes",
					description = "Avatar icon rendered across all supported sizes.",
					layoutOrder = 2,
					children = {
						StorySizes {
							scope = scope,
							layoutOrder = 3,
						}
					}
				},
			}
		}
	end)
}