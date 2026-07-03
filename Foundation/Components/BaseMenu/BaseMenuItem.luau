local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")
local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Utility = Foundation.Utility
local Enums = Foundation.Enums
local TypesSource = Utility.Types

local Icon = require(Foundation.Components.Icon)
local Image = require(Foundation.Components.Image)
local Popover = require(Foundation.Components.Popover)
local Text = require(Foundation.Components.Text)
local View = require(Foundation.Components.View)

local useBaseMenuItemVariants = require(script.Parent.useBaseMenuItemVariants)
local useMenuItemHover = require(script.Parent.useMenuItemHover)

local iconMigrationUtils = require(Utility.iconMigrationUtils)
local withCommonProps = require(Utility.withCommonProps)
local withDefaults = require(Utility.withDefaults)
local unwrap = require(Utility.unwrap)
local stripProps = require(Utility.stripProps)

local InputSize = require(Enums.InputSize)
local PopoverAlign = require(Enums.PopoverAlign)
local PopoverSide = require(Enums.PopoverSide)
local Radius = require(Enums.Radius)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local Constants = require(Foundation.Constants)
local Types = require(TypesSource.Types)

local Children = Fusion.Children
local isBuilderIconOrMigrated = iconMigrationUtils.isBuilderOrMigratedIcon

-- Flag replacements
local FOUNDATION_BASE_MENU_SUBMENU_SUPPORT = true
local FOUNDATION_FIX_NESTED_SUB_MENU_ON_CLICK = true
local FOUNDATION_GUI_OBJECT_INPUT_SINK_PROPERTY = true

local COMPONENT_ONLY_PROPERTIES = {
	"id",
	"icon",
	"isChecked",
	"isDisabled",
	"text",
	"onActivated",
	"size",
	"children",
	"hasLeading",
	"depth",
	"hoverOpenPath",
	"hoverOpenAtDepth",
	"hoverCloseAtDepth",
	"hoverReset",
	"onActivatedContext",
	"onNestedLeafActivated",
	"setHasLeading"
}

local defaultProps = {
	isChecked = false,
	isDisabled = false,
}

local function getInputSinkAll()
	if not FOUNDATION_GUI_OBJECT_INPUT_SINK_PROPERTY then
		return nil
	end

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

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child
type ItemId = Types.ItemId
type OnItemActivated = Types.OnItemActivated

type InputSize = InputSize.InputSize

export type BaseMenuContextProps = {
	onActivatedContext: OnItemActivated?,
	onNestedLeafActivated: (() -> ())?,
	size: UsedAs<InputSize>?,
	hasLeading: UsedAs<boolean>?,
	setHasLeading: (() -> ())?,
	hoverOpenPath: UsedAs<{ ItemId }>?,
	hoverOpenAtDepth: ((depth: number, id: ItemId, immediate: boolean?) -> ())?,
	hoverCloseAtDepth: ((depth: number) -> ())?,
	hoverReset: (() -> ())?,
	depth: number?,
}

export type BaseMenuItemProps = {
	scope: Scope,
	id: UsedAs<ItemId>,
	icon: UsedAs<string>?,
	isChecked: UsedAs<boolean>?,
	isDisabled: UsedAs<boolean>?,
	text: UsedAs<string>,
	onActivated: OnItemActivated?,
	size: UsedAs<InputSize>?,
	children: { Child }?,
} & BaseMenuContextProps & Types.SelectionProps & Types.CommonProps

return function(menuItemProps: BaseMenuItemProps)
	local Scope = menuItemProps.scope
	local Theme = ThemeProvider()
	assert(Scope, "A scope has not been provided for the BaseMenuItem component.")

	local props = withDefaults(menuItemProps, defaultProps)
	local itemRef = Scope:Value(nil)

	local submenuHasLeading = Scope:Value(false)
	local function setSubmenuHasLeading()
		submenuHasLeading:set(true)
	end

	if props.icon and props.setHasLeading then
		props.setHasLeading()
	end

	return Scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(Theme.Tokens, use)
		local currentId = unwrap(props.id, use)
		local currentSize = unwrap(props.size, use)
		local currentDepth = props.depth or 1
		local currentIcon = unwrap(props.icon, use)
		local currentText = unwrap(props.text, use)
		local isDisabled = unwrap(props.isDisabled, use)
		local isChecked = unwrap(props.isChecked, use)
		local hasLeading = unwrap(props.hasLeading, use)

		local isSubmenu = FOUNDATION_BASE_MENU_SUBMENU_SUPPORT and props.children ~= nil
		local hoverPath = unwrap(props.hoverOpenPath, use) or {}
		local isOpen = isSubmenu and hoverPath[currentDepth] == currentId

		local variantProps = useBaseMenuItemVariants(innerScope, tokens, currentSize, if isSubmenu then false else isChecked)

		if FOUNDATION_BASE_MENU_SUBMENU_SUPPORT then
			useMenuItemHover(innerScope, {
				itemRef = itemRef,
				id = currentId,
				depth = currentDepth,
				isSubmenu = isSubmenu,
				isDisabled = isDisabled,
				hoverOpenAtDepth = props.hoverOpenAtDepth,
				hoverCloseAtDepth = props.hoverCloseAtDepth,
			})
		end

		local function onActivated()
			if isSubmenu then
				if isDisabled then return end
				if props.hoverOpenAtDepth and not isOpen then
					props.hoverOpenAtDepth(currentDepth, currentId, true)
				end
			else
				if FOUNDATION_BASE_MENU_SUBMENU_SUPPORT and props.hoverReset then
					props.hoverReset()
				end

				local callback = props.onActivated or props.onActivatedContext
				if not callback then
					warn("Menu should have either onActivated on itself or on all of its children") -- This can be converted back to Logger Utility if Lumberyak is added as a package.
				else
					callback(currentId)
				end

				if FOUNDATION_FIX_NESTED_SUB_MENU_ON_CLICK and currentDepth > 1 and props.onNestedLeafActivated then
					props.onNestedLeafActivated()
				end
			end
		end

		local function onSubmenuPressedOutside()
			if FOUNDATION_BASE_MENU_SUBMENU_SUPPORT and props.hoverReset then
				props.hoverReset()
			end
		end

		local cursor = {
			radius = UDim.new(0, tokens.Radius.Small),
			offset = tokens.Size.Size_200,
			borderWidth = tokens.Stroke.Thicker,
		}

		local migratedIcon = if currentIcon then BuilderIcons.Migration["uiblox"][currentIcon] else nil
		local currentVariantProps = unwrap(variantProps, use)

		local viewChildren = {}

		if currentIcon or hasLeading then
			if currentIcon and isBuilderIconOrMigrated(currentIcon) then
				viewChildren.IconWrapper = View {
					scope = innerScope,
					LayoutOrder = 1,
					tag = `align-x-center align-y-center {currentVariantProps.icon.tag}`,
					children = {
						Icon = Icon {
							scope = innerScope,
							name = if migratedIcon then migratedIcon.name else currentIcon,
							style = currentVariantProps.icon.style,
							size = currentVariantProps.icon.size,
						}
					}
				}
			else
				viewChildren.Image = Image {
					scope = innerScope,
					LayoutOrder = 1,
					Image = currentIcon,
					tag = currentVariantProps.icon.tag,
				}
			end
		end

		viewChildren.Text = Text {
			scope = innerScope,
			LayoutOrder = 2,
			Text = currentText,
			tag = currentVariantProps.text.tag,
		}

		if isSubmenu then
			viewChildren.Chevron = Icon {
				scope = innerScope,
				LayoutOrder = 3,
				name = BuilderIcons.Icon.ChevronSmallRight,
				style = currentVariantProps.check.style,
				size = currentVariantProps.chevron.size,
				testId = `{props.testId}--chevron`,
			}
		elseif isChecked then
			viewChildren.Check = Icon {
				scope = innerScope,
				LayoutOrder = 3,
				name = BuilderIcons.Icon.Check,
				style = currentVariantProps.check.style,
				size = currentVariantProps.check.size,
				testId = `{props.testId}--checkmark`,
			}
		end

		local itemElementProps = withCommonProps(props, {
			scope = innerScope,
			GroupTransparency = if isDisabled then Constants.DISABLED_TRANSPARENCY else nil,
			isDisabled = isDisabled,
			onActivated = onActivated,
			selection = { Selectable = not isDisabled },
			cursor = cursor,
			tag = currentVariantProps.container.tag,
			ref = itemRef,
			children = viewChildren,
		})

		local itemElement = View(itemElementProps)

		if not isSubmenu then
			return innerScope:Hydrate(itemElement)(stripProps(props, COMPONENT_ONLY_PROPERTIES))
		end

		local strokeThickness = tokens.Stroke.Standard
		local groupPadding = currentVariantProps.groupPadding.size

		local wrappedChildren = {}
		if props.children then
			for key, child in pairs(props.children) do
				if type(child) == "table" and child.props then
					child.props.onActivatedContext = props.onActivatedContext
					child.props.onNestedLeafActivated = props.onNestedLeafActivated
					child.props.size = currentSize
					child.props.hasLeading = submenuHasLeading
					child.props.setHasLeading = setSubmenuHasLeading
					child.props.hoverOpenPath = props.hoverOpenPath
					child.props.hoverOpenAtDepth = props.hoverOpenAtDepth
					child.props.hoverCloseAtDepth = props.hoverCloseAtDepth
					child.props.hoverReset = props.hoverReset
					child.props.depth = currentDepth + 1
				end
				wrappedChildren[key] = child
			end
		end

		local fragmentChildren = {
			Item = innerScope:Hydrate(itemElement)(stripProps(props, COMPONENT_ONLY_PROPERTIES)),
			Submenu = Popover.Root {
				scope = innerScope,
				isOpen = isOpen,
				testId = `{props.testId}--submenu`,
				children = {
					Anchor = Popover.Anchor {
						scope = innerScope,
						anchorRef = itemRef,
					},
					Content = Popover.Content {
						scope = innerScope,
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
						backgroundStyle = tokens.Color.Surface.Surface_100,
						radius = Radius.Medium,
						children = {
							MenuContainer = View {
								scope = innerScope,
								tag = "col auto-xy stroke-standard stroke-default radius-medium",
								InputSink = InputSinkAll,
								children = wrappedChildren
							}
						}
					}
				}
			}
		}

		return innerScope:New "Folder" {
			[Children] = fragmentChildren
		}
	end)
end