local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useSegmentedControlVariants = require(script.Parent.useSegmentedControlVariants)

local Icon = require(Components.Icon)
local Text = require(Components.Text)
local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type InputSize = InputSize.InputSize

export type Segment = {
	id: Types.ItemId,
	text: string?,
	icon: (string | {
		name: BuilderIcons.Icon,
		variant: BuilderIcons.IconVariant?,
	})?,
	-- Reference to the segment element.
	ref: UsedAs<GuiObject?>?
}

type SegmentProps = Segment & {
	-- The scope the component will be created in.
	scope: Scope,
	isActive: UsedAs<boolean>,
	onActivated: (id: Types.ItemId) -> (),
	size: UsedAs<InputSize>,
	isCircular: UsedAs<boolean>?,
} & Types.CommonProps

-- Returns a state holding the segment's GuiObject.
return function(props: SegmentProps): UsedAs<GuiObject>
	local scope = props.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the Segment component.")

	assert(
		props.text == nil or props.icon == nil,
		"Segment: `text` and `icon` are mutually exclusive. Only one can be provided."
	)

	local variantProps = scope:Computed(function(use: Use)
		return useSegmentedControlVariants(unwrap(theme.Theme, use), unwrap(theme.Tokens, use), unwrap(props.size, use), unwrap(props.isCircular, use))
	end)

	local content
	if props.icon ~= nil then
		local iconName: string
		local iconVariant: BuilderIcons.IconVariant?

		if typeof(props.icon) == "table" then
			local iconConfig = props.icon :: {
				name: BuilderIcons.Icon,
				variant: BuilderIcons.IconVariant?,
			}
			iconName = iconConfig.name :: string
			iconVariant = iconConfig.variant
		else
			iconName = props.icon :: string
		end

		content = Icon {
			scope = scope,
			name = iconName,
			variant = iconVariant,
			size = scope:Computed(function(use: Use)
				return unwrap(variantProps, use).icon.size
			end),
			style = scope:Computed(function(use: Use)
				return unwrap(variantProps, use).icon.style
			end)
		}
	else
		content = Text {
			scope = scope,
			tag = scope:Computed(function(use: Use)
				return unwrap(variantProps, use).text.tag
			end),
			Text = props.text :: string
		}
	end

	local viewProps = withCommonProps(props, {
		scope = scope,
		tag = scope:Computed(function(use: Use)
			return unwrap(variantProps, use).segment.tag
		end),
		onActivated = function()
			props.onActivated(props.id)
		end,
		children = {
			Text = content
		}
	})

	local segmentView = View(viewProps)

	local segmentRef = props.ref
	if segmentRef then
		segmentRef:set(unwrap(segmentView))
		scope:Observer(segmentView):onChange(function()
			segmentRef:set(unwrap(segmentView))
		end)
	end

	return segmentView
end
