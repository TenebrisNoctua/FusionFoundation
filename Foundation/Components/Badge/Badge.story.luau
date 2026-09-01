local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")
local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Badge = require(script.Parent)
local View = require(Components.View)
local Text = require(Components.Text)
local ScrollView = require(Components.ScrollView)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local StorySection = require(Utility.Stories.StorySection)
local CommonControls = require(Utility.Stories.CommonControls)

local BadgeVariant = require(Enums.BadgeVariant)
local BadgeShape = require(Enums.BadgeShape)
local BadgeSize = require(Enums.BadgeSize)
local IconPosition = require(Enums.IconPosition)

local Icons = BuilderIcons.Icon

type Scope = Types.Scope
type Use = Types.Use
type UsedAs<T> = Types.UsedAs<T>

type BadgeVariant = BadgeVariant.BadgeVariant
type BadgeShape = BadgeShape.BadgeShape
type BadgeSize = BadgeSize.BadgeSize
type IconPosition = IconPosition.IconPosition

-- DEPRECATED Primary, Secondary, and Neutral variants are scheduled for removal in the next major release (2.0)
local nonDeprecatedVariants = Dash.filter(Dash.values(BadgeVariant), function(item)
	return item ~= BadgeVariant.Primary and item ~= BadgeVariant.Secondary and item ~= BadgeVariant.Neutral
end) :: { BadgeVariant }

local ICON_CHOICES = {
	Icons.CirclePlus,
	Icons.Diamond,
	Icons.DiamondSimplified,
	Icons.House,
	"icons/placeholder/placeholderOn_small",
	"icons/menu/clothing/limited_on",
	"",
}

local function PlaygroundStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls

	local icon = scope:Computed(function(use: Use)
		local iconName = unwrap(controls.icon, use)
		if iconName == nil or iconName == "" then
			return nil
		end
		local pos = unwrap(controls.iconPosition, use)
		return { name = iconName, position = pos } :: any
	end)

	return Badge {
		scope = scope,
		text = controls.text,
		icon = icon,
		size = controls.size,
		isDisabled = controls.isDisabled,
		variant = controls.variant,
		shape = controls.shape,
		LayoutOrder = props.layoutOrder,
	}
end

local function AllVariantsStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls

	local icon = scope:Computed(function(use: Use)
		local iconName = unwrap(controls.icon, use)
		if iconName == nil or iconName == "" then
			return nil
		end
		local pos = unwrap(controls.iconPosition, use)
		return { name = iconName, position = pos } :: any
	end)

	local children: { [string]: any } = {}
	for index, variant in nonDeprecatedVariants do
		children[variant .. "_label"] = Text {
			scope = scope,
			Text = variant :: string,
			tag = "auto-xy text-caption-small text-align-x-center",
			LayoutOrder = index * 2 - 1,
		}
		children[variant .. "_badge"] = View {
			scope = scope,
			tag = "col align-x-center gap-small auto-xy",
			LayoutOrder = index * 2,
			children = {
				Badge {
					scope = scope,
					text = controls.text,
					icon = icon,
					size = controls.size,
					isDisabled = controls.isDisabled,
					variant = variant :: BadgeVariant,
					shape = controls.shape,
					LayoutOrder = 2,
				},
			},
		}
	end

	return View {
		scope = scope,
		tag = "row wrap gap-xxlarge auto-xy",
		LayoutOrder = props.layoutOrder,
		children = children,
	}
end

local function AllShapesStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls

	local icon = scope:Computed(function(use: Use)
		local iconName = unwrap(controls.icon, use)
		if iconName == nil or iconName == "" then
			return nil
		end
		local pos = unwrap(controls.iconPosition, use)
		return { name = iconName, position = pos } :: any
	end)

	local children: { [string]: any } = {}
	for index, shape in Dash.values(BadgeShape) do
		children[shape .. "_label"] = Text {
			scope = scope,
			Text = shape :: string,
			tag = "auto-xy text-caption-small text-align-x-center",
			LayoutOrder = index * 2 - 1,
		}
		children[shape .. "_badge"] = View {
			scope = scope,
			tag = "col align-x-center gap-small auto-xy",
			LayoutOrder = index * 2,
			children = {
				Badge {
					scope = scope,
					text = controls.text,
					icon = icon,
					size = controls.size,
					isDisabled = controls.isDisabled,
					variant = controls.variant,
					shape = shape :: BadgeShape,
					LayoutOrder = 2,
				},
			},
		}
	end

	return View {
		scope = scope,
		tag = "row wrap gap-xxlarge auto-xy",
		LayoutOrder = props.layoutOrder,
		children = children,
	}
end

local function DeprecatedVariantsStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls

	local icon = scope:Computed(function(use: Use)
		local iconName = unwrap(controls.icon, use)
		if iconName == nil or iconName == "" then
			return nil
		end
		local pos = unwrap(controls.iconPosition, use)
		return { name = iconName, position = pos } :: any
	end)

	local deprecatedVariants = {
		BadgeVariant.Primary :: BadgeVariant,
		BadgeVariant.Secondary,
		BadgeVariant.Neutral,
	}

	local children: { [string]: any } = {}
	for index, variant in deprecatedVariants do
		children[variant .. "_label"] = Text {
			scope = scope,
			Text = variant :: string,
			tag = "auto-xy text-caption-small text-align-x-center",
			LayoutOrder = index * 2 - 1,
		}
		children[variant .. "_badge"] = View {
			scope = scope,
			tag = "col align-x-center gap-small auto-xy",
			LayoutOrder = index * 2,
			children = {
				Badge {
					scope = scope,
					text = controls.text,
					icon = icon,
					size = controls.size,
					isDisabled = controls.isDisabled,
					variant = variant :: BadgeVariant,
					shape = controls.shape,
					LayoutOrder = 2,
				},
			},
		}
	end

	return View {
		scope = scope,
		tag = "row wrap gap-xxlarge auto-xy",
		LayoutOrder = props.layoutOrder,
		children = children,
	}
end

return {
	fusion = Fusion,
	summary = "Badge",
	controls = {
		text = "Label",
		icon = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = ICON_CHOICES[1],
			List = ICON_CHOICES,
			DefIndex = 1,
		},
		variant = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = nonDeprecatedVariants[1],
			List = nonDeprecatedVariants,
			DefIndex = 1,
		},
		shape = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(BadgeShape)[1],
			List = Dash.values(BadgeShape),
			DefIndex = 1,
		},
		iconPosition = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(IconPosition)[1],
			List = Dash.values(IconPosition),
			DefIndex = 1,
		},
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(BadgeSize)[1],
			List = Dash.values(BadgeSize),
			DefIndex = 1,
		},
		isDisabled = false,
		theme = CommonControls.theme,
	},
	story = StoryMiddleware(function(props)
		local scope = props.scope
		local controls = props.controls

		return scope:Computed(function(use: Use, innerScope: Scope)
			unwrap(controls.theme, use)

			return ScrollView {
				scope = innerScope,
				tag = "auto-x size-full padding-x-large padding-top-large col",
				scroll = {
					AutomaticCanvasSize = Enum.AutomaticSize.XY
				},
				children = {
					StorySection {
						scope = innerScope,
						title = "Playground",
						layoutOrder = 1,
						children = {
							PlaygroundStory {
								scope = innerScope,
								controls = controls,
								layoutOrder = 2,
							},
						},
					},

					StorySection {
						scope = innerScope,
						title = "All variants",
						layoutOrder = 2,
						children = {
							AllVariantsStory {
								scope = innerScope,
								controls = controls,
								layoutOrder = 2,
							},
						},
					},

					StorySection {
						scope = innerScope,
						title = "All shapes",
						layoutOrder = 3,
						children = {
							AllShapesStory {
								scope = innerScope,
								controls = controls,
								layoutOrder = 2,
							},
						},
					},

					StorySection {
						scope = innerScope,
						title = "Deprecated variants",
						description = "Primary, Secondary, and Neutral are deprecated and scheduled for removal in 2.0",
						layoutOrder = 4,
						children = {
							DeprecatedVariantsStory {
								scope = innerScope,
								controls = controls,
								layoutOrder = 2,
							},
						},
					},
				}
			}
		end)
	end)
}