local Foundation = script.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Text = require(Components.Text)
local View = require(Components.View)
local Popover = require(Components.Popover)
local Fragment = require(Components.Fragment)

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local useScaledValue = require(Utility.useScaledValue)
local withCommonProps = require(Utility.withCommonProps)

local Types = require(Utility.Types)
local Wrappers = require(Utility.Wrappers)

local UserInputService = Wrappers.Services.UserInputService

local Radius = require(Enums.Radius)
local PopoverSide = require(Enums.PopoverSide)
local PopoverAlign = require(Enums.PopoverAlign)
local ControlState = require(Enums.ControlState)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local defaultProps = {
	align = PopoverAlign.Start,
	side = PopoverSide.Right
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

type PopoverAlign = PopoverAlign.PopoverAlign
type PopoverSide = PopoverSide.PopoverSide
type ControlState = ControlState.ControlState

export type TooltipProps = {
	-- The scope the component will be created in.
	scope: Scope,
	-- A title for the tooltip. To omit, set it to an empty string.
	title: UsedAs<string>,
	-- Body text for the tooltip.
	text: UsedAs<string>?,
	-- Shortcut associated with the action owning the tooltip
	shortcut: UsedAs<{ Enum.KeyCode }>?,
	align: UsedAs<PopoverAlign>?,
	side: UsedAs<PopoverSide>?,
	children: UsedAs<{Child} | ((scope: Scope) -> {Child})>?,
} & Types.CommonProps

return function(tooltipProps: TooltipProps)
	local scope = tooltipProps.scope
	assert(scope, "A scope has not been provided for the Tooltip component.")

	local theme = ThemeProvider()
	local props = withDefaults(tooltipProps, defaultProps)

	local isOpen = scope:Value(false)
	local function onAnchorStateChanged(newState: ControlState)
		isOpen:set(newState == ControlState.Hover)
	end

	return scope:Computed(function(use: Use, innerScope: Scope)
		local maxXSize = useScaledValue(320, use)
		local tokens = unwrap(theme.Tokens, use)
		local side = unwrap(props.side, use)
		local title = unwrap(props.title, use)
		local text = unwrap(props.text, use)
		local shortcut = unwrap(props.shortcut, use)
		local children = unwrap(props.children, use)

		local shortcutText = if shortcut
			then innerScope:Computed(function(use: Use)
				local keys = unwrap(shortcut, use)
				local segments = {}
				for _, keyCode in keys do
					local key = UserInputService:GetStringForKeyCode(keyCode)
					if key == nil or key == "" then
						key = keyCode.Name
					end
					table.insert(segments, key)
				end
				return table.concat(segments, " + ")
			end)
			else nil

		local hasHeader = title ~= "" or shortcut ~= nil

		return Popover.Root {
			scope = innerScope,
			isOpen = isOpen,
			children = Fragment {
				{Popover.Anchor, withCommonProps(props, {
					children = {
						View {
							scope = innerScope,
							tag = "auto-xy",
							onStateChanged = onAnchorStateChanged,
							children = children,
						},
					},
				}) },
				{Popover.Content, {
					hasArrow = false,
					align = props.align,
					side = {
						position = side,
						offset = tokens.Size.Size_200
					},
					radius = Radius.Small,
					backgroundStyle = tokens.Inverse.Surface.Surface_0,
					selectionGroup = false,
					children = {
						View {
							scope = innerScope,
							tag = {
								["col gap-xsmall auto-xy"] = true,
								["padding-x-medium padding-y-small"] = text ~= nil,
								["padding-x-small padding-y-xsmall"] = text == nil
							},
							sizeConstraint = {
								MaxSize = Vector2.new(maxXSize, math.huge)
							},
							children = {
								Header = if hasHeader
									then View {
										scope = innerScope,
										LayoutOrder = 1,
										tag = "row flex-between gap-small size-full-0 auto-y",
										children = {
											Title = if title ~= ""
											then Text {
												scope = innerScope,
												LayoutOrder = 1,
												Text = title,
												tag = "shrink auto-xy text-title-small text-truncate-end content-inverse-emphasis",
											}
											else nil,
											Shortcut = if shortcut
											then Text {
												scope = innerScope,
												LayoutOrder = 2,
												Text = shortcutText,
												tag = "auto-xy text-body-small content-inverse-muted",
											}
											else nil
										}
									}
									else nil,
								Text = if text and text ~= ""
									then Text {
										scope = innerScope,
										LayoutOrder = 2,
										Text = text,
										tag = "auto-xy text-body-small text-wrap text-align-x-left content-inverse-default"
									}
									else nil
							}
						}
					}
				}}
			}
		}
	end)
end
