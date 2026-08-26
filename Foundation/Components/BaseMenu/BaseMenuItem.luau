local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useMenuItemHover = require(script.Parent.useMenuItemHover)
local useBaseMenuItemVariants = require(script.Parent.useBaseMenuItemVariants)

local Accessory = require(script.Parent.BaseMenuItemAccessory)
local BaseMenuContext = require(script.Parent.BaseMenuContext)
local BaseMenuScrollContainer = require(script.Parent.BaseMenuScrollContainer)

local Icon = require(Foundation.Components.Icon)
local Text = require(Foundation.Components.Text)
local View = require(Foundation.Components.View)
local Popover = require(Foundation.Components.Popover)

local unwrap = require(Utility.unwrap)
local stripProps = require(Utility.stripProps)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local iconMigrationUtils = require(Utility.iconMigrationUtils)
local Types = require(Utility.Types)

local Radius = require(Enums.Radius)
local InputSize = require(Enums.InputSize)
local PopoverSide = require(Enums.PopoverSide)
local PopoverAlign = require(Enums.PopoverAlign)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local Constants = require(Foundation.Constants)

local Children = Fusion.Children

local COMPONENT_ONLY_PROPERTIES = {
	"id",
	"icon",
	"leading",
	"trailing",
	"isChecked",
	"isDisabled",
	"text",
	"onActivated",
	"isOpen"
}

local defaultProps = {
	isChecked = false,
	isDisabled = false
}

local function getInputSinkAll()
	local hasFeature, enabled = pcall(game.GetEngineFeature, game, "GuiObjectInputSink")
	if not hasFeature or not enabled then
		return nil
	end

	local ok, value = pcall(function()
		return (Enum :: any).InputSink.All
	end)

	return if ok then value else nil
end

local InputSinkAll = getInputSinkAll()

local function resolveAccessory(
	prop: (string | LeadingAccessory | TrailingAccessory)?
): LeadingAccessory | TrailingAccessory | nil
	if prop == nil or prop == "" then
		return nil
	end
	if type(prop) == "string" then
		return { iconName = prop }
	end
	return prop
end

local function getContainerPadding(container: any, menuHasCheck: boolean): Types.PaddingTable
	local left = if menuHasCheck then container.paddingLeftWithCheck else container.paddingLeftWithoutCheck
	return {
		left = UDim.new(0, left or 0),
		right = UDim.new(0, container.paddingRight or 0)
	}
end

--// Type Definitions

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child
type ItemId = Types.ItemId
type OnItemActivated = Types.OnItemActivated

type InputSize = InputSize.InputSize

export type LeadingAccessory = Accessory.LeadingAccessory
export type TrailingAccessory = Accessory.TrailingAccessory

-- Re-export for consumers
export type LeadingAccessoryProp = string | LeadingAccessory
export type TrailingAccessoryProp = TrailingAccessory

export type BaseMenuItemProps = {
	scope: Scope,
	id: UsedAs<ItemId>,
	icon: UsedAs<string>?,
	leading: UsedAs<LeadingAccessoryProp>?,
	trailing: UsedAs<TrailingAccessoryProp>?,
	isChecked: UsedAs<boolean>?,
	isDisabled: UsedAs<boolean>?,
	text: UsedAs<string>,
	onActivated: OnItemActivated?,
	children: Child?,
	isOpen: UsedAs<boolean>?,
} & Types.CommonProps

--// Component Implementation

return function(menuItemProps: BaseMenuItemProps)
	local scope = menuItemProps.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the BaseMenuItem component.")

	local props = withDefaults(menuItemProps, defaultProps)
	local context = BaseMenuContext:now()
	local itemRef = scope:Value(nil :: GuiObject?)

	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local currentId = unwrap(props.id, use)
		local currentSize = unwrap(context.size, use)
		local currentDepth = context.depth
		local currentIcon = unwrap(props.icon, use)

		local hasLeading = unwrap(context.hasLeading, use)
		local currentLeading = unwrap(props.leading, use)
		local currentTrailing = unwrap(props.trailing, use)
		local menuHasLeading = unwrap(context.menuHasLeading, use)
		local menuHasCheck = unwrap(context.menuHasCheck, use)
		local currentMaxHeight = unwrap(context.maxHeight, use)

		local rawChildren = unwrap(props.children, use)
		local isSubmenu = rawChildren ~= nil

		local currentIsDisabled = unwrap(props.isDisabled, use)
		local currentIsChecked = unwrap(props.isChecked, use)
		local groupTransparency = if currentIsDisabled then Constants.DISABLED_TRANSPARENCY else nil
		local selectable = not currentIsDisabled
		local checkVisible = currentIsChecked == true and rawChildren == nil

		local resolvedLeading = resolveAccessory(currentLeading or currentIcon)
		local resolvedTrailing = resolveAccessory(currentTrailing)

		local alignmentHasLeading = if menuHasLeading ~= nil then menuHasLeading else hasLeading == true
		local checkMenuHasCheck = if menuHasCheck ~= nil then menuHasCheck else currentIsChecked == true

		local isSubmenuScrollable = currentMaxHeight ~= nil
		local variantProps = useBaseMenuItemVariants(unwrap(theme.Theme), tokens, currentSize, isSubmenuScrollable)

		useMenuItemHover(innerScope, {
			itemRef = itemRef,
			id = currentId,
			depth = currentDepth,
			isSubmenu = isSubmenu,
			isDisabled = props.isDisabled,
			hoverOpenAtDepth = context.hoverOpenAtDepth,
			hoverCloseAtDepth = context.hoverCloseAtDepth,
		})

		local function onActivated()
			if isSubmenu then
				if currentIsDisabled then return end
				local currentIsOpen = unwrap(props.isOpen)
				if context.hoverOpenAtDepth and not currentIsOpen then
					context.hoverOpenAtDepth(currentDepth, currentId, true)
				end
			else
				if context.hoverReset then
					context.hoverReset()
				end

				local callback = props.onActivated or context.onActivated
				if not callback then
					warn("[FusionFoundation]: Menu should have either onActivated on itself or on all of its children")
				else
					callback(currentId)
				end

				if currentDepth > 1 and context.onNestedLeafActivated then
					context.onNestedLeafActivated()
				end
			end
		end

		local function onSubmenuPressedOutside()
			if context.hoverReset then
				context.hoverReset()
			end
		end

		local cursor = {
			radius = UDim.new(0, tokens.Radius.Small),
			offset = tokens.Size.Size_200,
			borderWidth = tokens.Stroke.Thicker
		}

		local containerPadding = getContainerPadding(variantProps.container, checkMenuHasCheck)
		local containerLayout = {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}
		local wrapperGap: number = (variantProps.wrapper and variantProps.wrapper.gap) or 0

		local viewChildren = {}

		-- Check column
		if checkMenuHasCheck then
			local checkChildren = {
				Check = Icon {
					scope = innerScope,
					name = BuilderIcons.Icon.Check,
					style = variantProps.check.style,
					size = variantProps.check.size,
					Visible = checkVisible,
				}
			}
			viewChildren.Check = View {
				scope = innerScope,
				LayoutOrder = 1,
				tag = `{variantProps.slotAlign.tag} {variantProps.check.tag}`,
				children = checkChildren,
			}
		end

		-- Build wrapper children
		local wrapperChildren = {}

		-- Leading node
		if resolvedLeading ~= nil then
			wrapperChildren.Leading = Accessory {
				scope = innerScope,
				LayoutOrder = 1,
				accessory = resolvedLeading :: LeadingAccessory,
				iconVariant = variantProps.icon,
				size = currentSize,
				tokens = tokens,
			}
		elseif alignmentHasLeading then
			wrapperChildren.Leading = View {
				scope = innerScope,
				LayoutOrder = 1,
				tag = `{variantProps.slotAlign.tag} {variantProps.icon.tag}`,
			}
		end

		-- Title node
		wrapperChildren.Title = Text {
			scope = innerScope,
			Text = props.text,
			LayoutOrder = 2,
			tag = variantProps.text.tag,
		}

		-- Trailing node
		if isSubmenu then
			wrapperChildren.Trailing = Icon {
				scope = innerScope,
				name = BuilderIcons.Icon.ChevronSmallRight,
				LayoutOrder = 3,
				style = variantProps.check.style,
				size = variantProps.chevron.size,
			}
		elseif resolvedTrailing ~= nil then
			wrapperChildren.Trailing = Accessory {
				scope = innerScope,
				LayoutOrder = 3,
				accessory = resolvedTrailing :: TrailingAccessory,
				iconVariant = variantProps.icon,
				size = currentSize,
				tokens = tokens,
			}
		end

		-- Wrapper
		viewChildren.Wrapper = View {
			scope = innerScope,
			LayoutOrder = 2,
			tag = "auto-xy",
			flexItem = { FlexMode = Enum.UIFlexMode.Fill },
			layout = {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, wrapperGap),
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
			children = wrapperChildren
		}

		local viewProps = withCommonProps(props, {
			scope = innerScope,
			GroupTransparency = groupTransparency,
			isDisabled = props.isDisabled,
			onActivated = onActivated,
			selection = { Selectable = selectable },
			cursor = cursor,
			tag = variantProps.container.tag,
			padding = containerPadding,
			layout = containerLayout,
			children = viewChildren
		})

		local itemElement = unwrap(View(viewProps))
		itemRef:set(itemElement)

		if not isSubmenu then
			return innerScope:Hydrate(itemElement)(stripProps(props, COMPONENT_ONLY_PROPERTIES))
		end

		local strokeThickness = tokens.Stroke.Standard
		local groupPadding = variantProps.groupPadding.size

		-- We lazily construct the submenu here, and only when the submenu is actually open.
		local submenuPopover = innerScope:Computed(function(use: Use, submenuScope: Scope)
			if not unwrap(props.isOpen, use) then return end

			return Popover.Root {
				scope = submenuScope,
				isOpen = props.isOpen,
				-- We have to provide children as a function, because doing otherwise in a table
				-- would evaluate the children first automatically by Luau.
				-- We also need to have the children constructed on the same scope as the Root.
				children = function(popoverScope: Scope)
					local submenuContent
					if isSubmenuScrollable then
						submenuContent = BaseMenuScrollContainer {
							scope = popoverScope,
							maxHeight = currentMaxHeight,
							scrollViewProps = {
								tag = variantProps.submenuContent.tag,
								InputSink = InputSinkAll,
							},
							children = rawChildren
						}
					else
						local submenuChildren = rawChildren
						if type(submenuChildren) == "function" then
							submenuChildren = submenuChildren(popoverScope)
						end
						submenuContent = View {
							scope = popoverScope,
							tag = variantProps.submenuContent.tag,
							InputSink = InputSinkAll,
							children = submenuChildren,
						}
					end

					return {
						Anchor = Popover.Anchor {
							scope = popoverScope,
							anchorInstance = itemRef,
						},
						Content = Popover.Content {
							scope = popoverScope,
							side = {
								position = PopoverSide.Right,
								offset = groupPadding / 2 + strokeThickness,
							},
							align = {
								position = PopoverAlign.Start,
								offset = -groupPadding,
							},
							hasArrow = false,
							onPressedOutside = onSubmenuPressedOutside,
							backgroundStyle = tokens.Color.Surface.Surface_200,
							radius = Radius.Medium,
							children = {
								MenuContainer = submenuContent
							}
						}
					}
				end
			}
		end)
		
		return {
			Item = innerScope:Hydrate(itemElement)(stripProps(props, COMPONENT_ONLY_PROPERTIES)),
			Submenu = submenuPopover
		}
	end)
end