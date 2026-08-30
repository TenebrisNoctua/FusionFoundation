local Foundation = script.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local DropdownControl = require(script.DropdownControl)
local markSelectedItem = require(script.markSelectedItem)

local Popover = require(Components.Popover)
local BaseMenu = require(Components.BaseMenu)
local Fragment = require(Components.Fragment)

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)

local Radius = require(Enums.Radius)
local InputSize = require(Enums.InputSize)
local PopoverSide = require(Enums.PopoverSide)
local InputVariant = require(Enums.InputVariant)
local PopoverAlign = require(Enums.PopoverAlign)

local defaultProps = {
	variant = InputVariant.Standard,
	width = UDim.new(0, 400),
	size = InputSize.Medium
}

local sideConfig = { position = PopoverSide.Bottom, offset = 5 }

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

type InputVariant = InputVariant.InputVariant
type InputSize = InputSize.InputSize
type Radius = Radius.Radius

type ItemId = Types.ItemId
type OnItemActivated = Types.OnItemActivated
type BaseMenuItem = BaseMenu.BaseMenuItem
type BaseMenuItems<Item> = BaseMenu.BaseMenuItems<Item>
type BaseMenuItemGroup<Item> = BaseMenu.BaseMenuItemGroup<Item>

export type LeadingAccessory = BaseMenu.LeadingAccessory
export type TrailingAccessory = BaseMenu.TrailingAccessory
export type DropdownItem = {
	id: ItemId,
	icon: string?,
	leading: (string | LeadingAccessory)?,
	trailing: TrailingAccessory?,
	isDisabled: boolean?,
	isChecked: boolean?,
	text: string,
}
export type DropdownItemGroup = BaseMenuItemGroup<DropdownItem>
export type DropdownItems = BaseMenuItems<DropdownItem>

export type DropdownProps = {
	-- The scope the component will be created in.
	scope: Scope,
	-- The value of the currently selected dropdown item.
	-- If `nil`, the dropdown will be considered uncontrolled.
	value: UsedAs<ItemId>?,
	placeholder: UsedAs<string>?,
	items: UsedAs<DropdownItems>,
	onItemChanged: OnItemActivated,
	-- Whether the dropdown is in an error state
	hasError: UsedAs<boolean>?,
	-- Style variant of the dropdown
	variant: UsedAs<InputVariant>?,
	-- Whether the dropdown is disabled
	isDisabled: UsedAs<boolean>?,
	-- Width of the component
	width: UsedAs<UDim>?,
	-- A label for the dropdown. To omit, set it to an empty string.
	label: UsedAs<string>,
	hint: UsedAs<string>?,
	size: UsedAs<InputSize>?,
	-- Maximum height after which the menu starts scrolling
	maxHeight: UsedAs<number>?,
	-- Selection behavior applied to the open menu's popover surface (focus trap configuration).
	selection: UsedAs<Types.Selection>?,
	selectionGroup: UsedAs<boolean>? | Types.SelectionGroup?,
} & Types.SelectionProps & Types.CommonProps

return function(dropdownProps: DropdownProps)
	local scope = dropdownProps.scope
	assert(scope, "A scope has not been provided for the Dropdown component.")

	local props = withDefaults(dropdownProps, defaultProps)

	local isMenuOpen = scope:Value(false)
	local inputRef = scope:Value(nil :: GuiObject?)
	local absoluteWidth = scope:Value(unwrap(props.width))

	local markedItems = scope:Computed(function(use: Use)
		local newItems, selectedItem = markSelectedItem(unwrap(props.items, use), unwrap(props.value, use))
		return { items = newItems, selectedItem = selectedItem }
	end)

	local items = scope:Computed(function(use: Use)
		return unwrap(markedItems, use).items
	end)

	local selectedItem = scope:Computed(function(use: Use)
		return unwrap(markedItems, use).selectedItem
	end)

	local function onActivated(id: ItemId)
		isMenuOpen:set(false)
		props.onItemChanged(id)
	end

	-- We do the copy of props in withDefaults already, no need to make it once more.
	props.onAbsoluteSizeChanged = function(absoluteSize: Vector2, frame: GuiObject)
		if dropdownProps.onAbsoluteSizeChanged then
			dropdownProps.onAbsoluteSizeChanged(frame)
		end
		absoluteWidth:set(UDim.new(0, absoluteSize.X))
	end

	return Popover.Root {
		scope = scope,
		isOpen = isMenuOpen,
		children = Fragment {
			{DropdownControl, withCommonProps(props, {
				Name = props.Name,
				variant = props.variant,
				onActivated = function()
					isMenuOpen:set(not unwrap(isMenuOpen))
				end,
				hasError = props.hasError,
				isDisabled = props.isDisabled,
				item = selectedItem,
				placeholder = props.placeholder,
				isMenuOpen = isMenuOpen,
				width = props.width,
				size = props.size,
				label = props.label,
				hint = props.hint,
				inputRef = inputRef,
				Selectable = props.Selectable,
				NextSelectionUp = props.NextSelectionUp,
				NextSelectionDown = props.NextSelectionDown,
				NextSelectionLeft = props.NextSelectionLeft,
				NextSelectionRight = props.NextSelectionRight
			})},
			{Popover.Anchor, {
				anchorInstance = inputRef
			}},
			{Popover.Content, {
				hasArrow = false,
				align = PopoverAlign.End,
				side = sideConfig,
				onPressedOutside = function()
					isMenuOpen:set(false)
				end,
				radius = Radius.Medium,
				selection = props.selection,
				selectionGroup = props.selectionGroup,
				children = {
					BaseMenu.Root {
						scope = scope,
						size = props.size,
						couldGrow = true,
						width = absoluteWidth,
						items = items,
						maxHeight = props.maxHeight,
						onActivated = onActivated,
						radius = Radius.Medium
					}
				}
			}}
		}
	}
end