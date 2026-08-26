local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local AvatarGroup = require(script.Parent)

local View = require(Components.View)
local Text = require(Components.Text)
local ScrollView = require(Components.ScrollView)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StorySection = require(Utility.Stories.StorySection)
local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local CommonControls = require(Utility.Stories.CommonControls)

local InputSize = require(Enums.InputSize)
local UserPresence = require(Enums.UserPresence)
local AvatarGroupType = require(Enums.AvatarGroupType)

type Scope = Types.Scope
type Use = Types.Use

type AvatarGroupType = AvatarGroupType.AvatarGroupType
type InputSize = InputSize.InputSize
type UserPresence = UserPresence.UserPresence

local AVATAR_USER_IDS = {
	24813339,
	24813338,
	24813333,
	24813337,
	24813336,
	24813335,
	24813334,
	24813332,
	24813331
}

local orderedSizes: { InputSize } = { InputSize.XSmall, InputSize.Small, InputSize.Medium, InputSize.Large }

local avatars: { { userId: number, userPresence: UserPresence } | number } = {}
for index = 1, #AVATAR_USER_IDS do
	local userId = AVATAR_USER_IDS[index]
	if index % 3 == 1 then
		table.insert(avatars, { userId = userId, userPresence = UserPresence.InExperience })
	else
		table.insert(avatars, userId)
	end
end

local function StoryPlayground(props)
	local scope = props.scope
	local controls = props.controls

	return View {
		scope = scope,
		Size = UDim2.new(1, 0, 0, 200),
		tag = "row align-x-center align-y-center",
		LayoutOrder = props.layoutOrder,
		children = {
			scope:Computed(function(use: Use, innerScope: Scope)
				local count = unwrap(controls.avatars, use)
				local result: { { userId: number, userPresence: UserPresence } | number } = {}
				for index = 1, count do
					local userId = AVATAR_USER_IDS[(index - 1) % #AVATAR_USER_IDS + 1]
					if index % 3 == 1 then
						table.insert(result, { userId = userId, userPresence = UserPresence.InExperience })
					else
						table.insert(result, userId)
					end
				end

				return AvatarGroup {
					scope = innerScope,
					avatars = result,
					type = controls.type,
					max = controls.max,
					size = controls.size
				}
			end)
		}
	}
end
local function StorySize(props)
	local scope = props.scope

	local children = {}
	for index, size in orderedSizes do
		table.insert(children, View {
			scope = scope,
			tag = "col align-x-center gap-small auto-xy",
			LayoutOrder = index,
			children = {
				Text {
					scope = scope,
					tag = "auto-xy text-caption-small text-align-x-center",
					Text = size,
					LayoutOrder = 1,
				},
				AvatarGroup {
					scope = scope,
					avatars = avatars,
					size = size,
					LayoutOrder = 2,
				}
			}
		})
	end

	return View {
		scope = scope,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		tag = "col wrap gap-xxlarge auto-xy",
		LayoutOrder = props.layoutOrder,
		children = children
	}
end

local function StoryType(props)
	local scope = props.scope

	local children = {}
	for index, groupType in Dash.values(AvatarGroupType) do
		table.insert(children, View {
			scope = scope,
			tag = "col align-x-center gap-small auto-xy",
			LayoutOrder = index,
			children = {
				Text {
					scope = scope,
					tag = "auto-xy text-caption-small text-align-x-center",
					Text = groupType,
					LayoutOrder = 1
				},
				AvatarGroup {
					scope = scope,
					avatars = avatars,
					type = groupType,
					LayoutOrder = 2
				}
			}
		})
	end

	return View {
		scope = scope,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		tag = "row wrap gap-xxlarge auto-xy",
		LayoutOrder = props.layoutOrder,
		children = children
	}
end

local function StoryContent(props)
	local scope = props.scope

	return View {
		scope = scope,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		tag = "row wrap gap-xxlarge auto-xy",
		LayoutOrder = props.layoutOrder,
		children = {
			View {
				scope = scope,
				tag = "col align-x-center gap-small auto-xy",
				LayoutOrder = 1,
				children = {
					Text {
						scope = scope,
						tag = "auto-xy text-caption-small text-align-x-center",
						Text = "Truncated (max 3)",
						LayoutOrder = 1
					},
					AvatarGroup {
						scope = scope,
						avatars = avatars,
						max = 3,
						LayoutOrder = 2
					}
				}
			},
			View {
				scope = scope,
				tag = "col align-x-center gap-small auto-xy",
				LayoutOrder = 2,
				children = {
					Text {
						scope = scope,
						tag = "auto-xy text-caption-small text-align-x-center",
						Text = "Full display",
						LayoutOrder = 1
					},
					AvatarGroup {
						scope = scope,
						avatars = avatars,
						LayoutOrder = 2
					}
				}
			}
		}
	}
end

return {
	fusion = Fusion,
	summary = "AvatarGroup",
	controls = {
		type = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = AvatarGroupType.Spread,
			List = Dash.values(AvatarGroupType),
			DefIndex = 2,
		},
		avatars = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = 9,
			List = { 1, 2, 3, 4, 5, 6, 7, 8, 9 },
			DefIndex = 9,
		},
		max = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = 5,
			List = { 1, 2, 3, 4, 5, 6, 7, 8, 9 },
			DefIndex = 5,
		},
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = InputSize.Medium,
			List = Dash.values(InputSize),
			DefIndex = 3,
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
					description = "Interactive avatar group with configurable type, count, max, and size.",
					layoutOrder = 1,
					children = {
						StoryPlayground {
							scope = scope,
							controls = controls,
							layoutOrder = 3
						}
					}
				},

				StorySection {
					scope = scope,
					title = "Size",
					description = "Avatar group rendered across all supported sizes.",
					layoutOrder = 2,
					children = {
						StorySize {
							scope = scope,
							layoutOrder = 3
						}
					}
				},

				StorySection {
					scope = scope,
					title = "Type",
					description = "Avatar group rendered with each group type (Stacked and Spread).",
					layoutOrder = 3,
					children = {
						StoryType {
							scope = scope,
							layoutOrder = 3
						}
					}
				},

				StorySection {
					scope = scope,
					title = "Content",
					description = "Truncated (max 3) vs full display of avatars.",
					layoutOrder = 4,
					children = {
						StoryContent {
							scope = scope,
							layoutOrder = 3
						}
					}
				}
			}
		}
	end)
}