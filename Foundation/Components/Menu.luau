local Foundation = script.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local BaseMenu = require(Components.BaseMenu)
local Popover = require(Components.Popover)

local unwrap = require(Utility.unwrap)
local withCommonProps = require(Utility.withCommonProps)
local withDefaults = require(Utility.withDefaults)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)
local PopoverAlign = require(Enums.PopoverAlign)
local PopoverSide = require(Enums.PopoverSide)
local Radius = require(Enums.Radius)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local defaultProps = {
	size = InputSize.Medium,
	side = PopoverSide.Bottom,
	align = PopoverAlign.Start
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Child = Types.Child
type Use = Types.Use

type InputSize = InputSize.InputSize
type PopoverSide = PopoverSide.PopoverSide
type PopoverAlign = PopoverAlign.PopoverAlign
type OnItemActivated = Types.OnItemActivated
type PopoverAnchor = Types.PopoverAnchor

-- Such a complex export is due to our export types checker imperfections
type BaseMenuItem = BaseMenu.BaseMenuItem
type BaseMenuItems = BaseMenu.BaseMenuItems
export type MenuItem = BaseMenuItem
export type MenuItems = BaseMenuItems

export type MenuProps = {
	-- The scope the component will be created in
	scope: Scope,
	-- Whether the menu is open
	isOpen: UsedAs<boolean>,
	-- List of items to display in the menu
	items: MenuItems,
	-- Size of the menu and its items
	size: UsedAs<InputSize>?,
	-- Width of the component. If not specified, the menu is sized based on the content.
	width: UsedAs<UDim>?,
	-- The side the popover should be anchored to
	side: UsedAs<PopoverSide>?,
	-- The alignment of the popover relative to the anchor
	align: UsedAs<PopoverAlign>?,
	-- Callback for when the backdrop is pressed
	onPressedOutside: (() -> ())?,
	-- Callback for when a menu item is activated.
	-- Should be defined either for the whole Menu, or separately for all the MenuItems
	onActivated: OnItemActivated?,
	-- Reference to the element that will serve as an anchor
	anchorInstance: UsedAs<PopoverAnchor>?,
	-- Children to render as the anchor
	children: Child?,
	-- Selection behavior
	selection: Types.Selection?,
	selectionGroup: UsedAs<boolean>? | Types.SelectionGroup?,
} & Types.CommonProps

return function(menuProps: MenuProps)
	local scope = menuProps.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the Menu component.")
	
	local props = withDefaults(menuProps, defaultProps)
	
	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local strokeThickness = tokens.Stroke.Standard
		local anchorProps = withCommonProps(props, {
			scope = innerScope, 
			anchorInstance = props.anchorInstance,
			children = if props.anchorInstance then nil else props.children
		})
		
		return Popover.Root {
			scope = innerScope,
			isOpen = props.isOpen,
			children = {
				Popover.Anchor(anchorProps),
				Popover.Content {
					scope = innerScope,
					side = {
						position = props.side,
						offset = strokeThickness + tokens.Padding.Small,
					},
					align = props.align,
					hasArrow = false,
					onPressedOutside = props.onPressedOutside,
					backgroundStyle = tokens.Color.Surface.Surface_100,
					radius = Radius.Medium,
					selection = props.selection,
					selectionGroup = props.selectionGroup,
					children = {
						BaseMenu.Root {
							scope = innerScope,
							items = props.items,
							size = props.size,
							width = props.width,
							onActivated = props.onActivated,
							onNestedLeafActivated = props.onPressedOutside,
							radius = Radius.Medium
						}
					}
				}
			}
		}
	end)
end