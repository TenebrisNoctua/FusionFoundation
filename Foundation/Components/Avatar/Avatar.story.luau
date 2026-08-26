local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Avatar = require(script.Parent)

local View = require(Components.View)
local Text = require(Components.Text)
local ScrollView = require(Components.ScrollView)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StorySection = require(Utility.Stories.StorySection)
local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local CommonControls = require(Utility.Stories.CommonControls)

local AvatarSize = require(Enums.AvatarSize)
local UserPresence = require(Enums.UserPresence)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

type Scope = Types.Scope
type Use = Types.Use

type AvatarSize = AvatarSize.AvatarSize
type UserPresence = UserPresence.UserPresence

local sizes: { AvatarSize } = {
	AvatarSize.Pictogram,
	AvatarSize.XLarge,
	AvatarSize.Large,
	AvatarSize.Medium,
	AvatarSize.Small
}

local surfaceColorKeys = { "None", "Surface_0", "Surface_100", "Surface_200", "Surface_300" }

local function getSurfaceColors(tokens)
	return {
		Surface_0 = tokens.Color.Surface.Surface_0,
		Surface_100 = tokens.Color.Surface.Surface_100,
		Surface_200 = tokens.Color.Surface.Surface_200,
		Surface_300 = tokens.Color.Surface.Surface_300
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
				local bgKey = unwrap(controls.background, use)
				local bpKey = unwrap(controls.backplate, use)

				return Avatar {
					scope = innerScope,
					userId = controls.userId,
					size = controls.size,
					userPresence = controls.userPresence,
					backgroundStyle = surfaceColors[bgKey],
					backplateStyle = surfaceColors[bpKey]
				}
			end)
		}
	}
end
local function StoryPresenceAndSizes(props)
	local scope = props.scope
	local theme = ThemeProvider()
	local tokens = unwrap(theme.Tokens)

	local children = {}
	local layoutOrder = 0

	for _, userPresence in Dash.values(UserPresence) do
		layoutOrder += 1
		table.insert(children, Text {
			scope = scope,
			Text = tostring(userPresence),
			tag = "align-x-left size-0-0 auto-xy text-caption-medium content-default",
			LayoutOrder = layoutOrder,
		})

		layoutOrder += 1
		local avatarChildren = {}
		for _, size in sizes do
			table.insert(avatarChildren, Avatar {
				scope = scope,
				userId = 24813339,
				userPresence = userPresence,
				size = size,
				backgroundStyle = tokens.Color.Shift.Shift_200,
			})
		end

		table.insert(children, View {
			scope = scope,
			tag = "row gap-xxlarge auto-xy",
			LayoutOrder = layoutOrder,
			children = avatarChildren,
		})
	end

	return View {
		scope = scope,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		tag = "col gap-large auto-xy",
		LayoutOrder = props.layoutOrder,
		children = children,
	}
end

return {
	fusion = Fusion,
	summary = "Avatar",
	controls = {
		userId = 24813339,
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = AvatarSize.Medium,
			List = Dash.values(AvatarSize),
			DefIndex = 2,
		},
		userPresence = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = UserPresence.None,
			List = Dash.values(UserPresence),
			DefIndex = 1,
		},
		background = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = "None",
			List = surfaceColorKeys,
			DefIndex = 1,
		},
		backplate = {
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
					description = "Interactive avatar with configurable size, presence, background, and backplate.",
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
					title = "Presence and sizes",
					description = "Every user presence rendered across the supported sizes",
					layoutOrder = 2,
					children = {
						StoryPresenceAndSizes {
							scope = scope,
							layoutOrder = 3,
						}
					}
				},
			}
		}
	end)
}