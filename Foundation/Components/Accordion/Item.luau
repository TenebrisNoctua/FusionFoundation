local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useAccordion = require(script.Parent.useAccordion)
local useAccordionItemVariants = require(script.Parent.useAccordionItemVariants)

local Divider = require(Components.Divider)
local Icon = require(Components.Icon)
local Text = require(Components.Text)
local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local isState = require(Utility.isState)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local PreferencesProvider = require(Foundation.Providers.PreferencesProvider)

local defaultProps = {
	hasDivider = true,
	isExpanded = false
}

-- tokens.Ease.StandardOut is a cubic-bezier curve ({0.2, 0, 0, 1}), which Fusion's
-- native TweenInfo cannot consume directly (it only accepts Enum.EasingStyle values).
-- Enum.EasingStyle.Quad + Enum.EasingDirection.Out is used here as the closest
-- built-in approximation of the original StandardOut curve.
local EASE_STYLE = Enum.EasingStyle.Quad
local EASE_DIRECTION = Enum.EasingDirection.Out

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

type InputSize = InputSize.InputSize
type IconVariant = typeof(BuilderIcons.IconVariant)
type ItemId = Types.ItemId

export type AccordionItemProps = {
	-- The scope the component will be created in.
	scope: Scope,
	-- leading BuilderIcon and it's variant
	leadingIcon: UsedAs<string | {
		name: string,
		variant: IconVariant,
	}>?,
	-- Text to display in the AccordionItem header
	text: UsedAs<string>,
	-- Determine if the AccordionItem has a divider at its bottom
	hasDivider: UsedAs<boolean>?,
	-- onActivated function that takes precedence over the default and onAccordionItemActivated passed by parent Accordion
	onActivated: (() -> ())?,
	-- id to distinguish the AccordionItem instance
	id: ItemId,
	-- isExpanded to control expansion
	isExpanded: UsedAs<boolean>?,
	children: UsedAs<{Child} | ((scope: Scope) -> {Child})>?,
} & Types.CommonProps

return function(accordionItemProps: AccordionItemProps)
	local scope = accordionItemProps.scope
	assert(scope, "A scope has not been provided for the AccordionItem component.")
	
	local theme = ThemeProvider()
	local preferencesProvider = PreferencesProvider()
	
	local props = withDefaults(accordionItemProps, defaultProps)
	local reducedMotionEnabled = preferencesProvider.preferences.reducedMotion

	local initialTokens = unwrap(theme.Tokens)
	local easeTweenInfo = TweenInfo.new(
		if reducedMotionEnabled then 0 else initialTokens.Time.Time_300,
		EASE_STYLE,
		EASE_DIRECTION
	)
	
	local isExpandedInternal = scope:Value(unwrap(props.isExpanded) or false)
	local isClosing = false

	local heightGoal = scope:Value(0)
	local chevronGoal = scope:Value(0)

	local currentHeight = scope:Tween(heightGoal, easeTweenInfo)
	local chevronRotation = scope:Tween(chevronGoal, easeTweenInfo)

	local function onClose()
		isClosing = true
		heightGoal:set(0)
		chevronGoal:set(0)
	end

	scope:Observer(currentHeight):onChange(function()
		if isClosing and unwrap(currentHeight) <= 0 then
			isClosing = false
			isExpandedInternal:set(false)
		end
	end)

	local function onContentSizeChange(newSize: Vector2)
		if unwrap(isExpandedInternal) and not isClosing then
			heightGoal:set(newSize.Y)
		end
	end

	local function setExpanded(newIsExpanded: boolean)
		local wasExpanded = unwrap(isExpandedInternal)
		if wasExpanded and not newIsExpanded then
			onClose()
		elseif not wasExpanded and newIsExpanded then
			isExpandedInternal:set(true)
			chevronGoal:set(-180)
		end
	end
	
	local isExpanded = unwrap(props.isExpanded)
	if isState(props.isExpanded) then
		scope:Observer(props.isExpanded):onChange(function()
			setExpanded(unwrap(props.isExpanded))
		end)
	else
		setExpanded(isExpanded)
	end
	
	if isExpanded then
		chevronGoal:set(-180)
	end

	local accordionContext = useAccordion()

	local function defaultOnActivated()
		setExpanded(not unwrap(isExpandedInternal))
	end

	local function onActivated()
		local handler
		if props.onActivated then
			handler = props.onActivated
		elseif accordionContext.onAccordionItemActivated then
			handler = accordionContext.onAccordionItemActivated(props.id, unwrap(isExpandedInternal))
		else
			handler = defaultOnActivated
		end
		if handler then
			handler()
		end
	end

	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local itemSize = unwrap(accordionContext.itemSize, use)
		local variantProps = useAccordionItemVariants(unwrap(theme.Theme, use), tokens, itemSize, false)

		local isExpanded = unwrap(isExpandedInternal, use)
		local leadingIcon = unwrap(props.leadingIcon, use)
		local hasDivider = unwrap(props.hasDivider, use)

		return View(withCommonProps(props, {
			scope = innerScope,
			tag = variantProps.container.tag,
			AutomaticSize = Enum.AutomaticSize.Y,
			stateLayer = variantProps.container.stateLayer,
			children = {
				Header = View {
					scope = innerScope,
					LayoutOrder = 1,
					tag = variantProps.header.tag,
					onActivated = onActivated,
					children = {
						LeadingIcon = if leadingIcon
							then Icon {
								scope = innerScope,
								LayoutOrder = 1,
								name = if type(leadingIcon) == "table" then leadingIcon.name else leadingIcon,
								variant = if type(leadingIcon) == "table" then leadingIcon.variant else nil,
								style = variantProps.icon.style,
								size = variantProps.icon.size
							}
							else nil,
						Title = Text {
							scope = innerScope,
							LayoutOrder = 2,
							Text = props.text,
							tag = variantProps.text.tag
						},
						CollapseIcon = View {
							scope = innerScope,
							tag = "auto-xy",
							LayoutOrder = 3,
							children = {
								Icon = Icon {
									scope = innerScope,
									name = "chevron-large-down",
									Rotation = chevronRotation,
									style = variantProps.icon.style,
									size = variantProps.icon.size
								}
							}
						}
					}
				},
				Content = if isExpanded
					then View {
						scope = innerScope,
						tag = "col",
						LayoutOrder = 2,
						Size = innerScope:Computed(function(use: Use)
							return UDim2.new(1, 0, 0, unwrap(currentHeight, use))
						end),
						ClipsDescendants = true,
						children = {
							AnimatedContainer = View {
								scope = innerScope,
								tag = variantProps.content.tag,
								onAbsoluteSizeChanged = onContentSizeChange,
								flexItem = {
									FlexMode = Enum.UIFlexMode.None,
								},
								children = props.children
							}
						}
					}
					else nil,
				Divider = if hasDivider
					then Divider {
						scope = innerScope,
						LayoutOrder = 3
					}
					else nil
			}
		}))
	end)
end