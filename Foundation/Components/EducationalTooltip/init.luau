local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Dash = PackageManager.getPackage("Dash")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Text = require(Components.Text)
local View = require(Components.View)
local Button = require(Components.Button)
local Popover = require(Components.Popover)
local Fragment = require(Components.Fragment)
local CloseAffordance = require(Components.CloseAffordance)

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local useScaledValue = require(Utility.useScaledValue)
local Types = require(Utility.Types)
local Translator = require(Utility.Localization.Translator)

local Radius = require(Enums.Radius)
local InputSize = require(Enums.InputSize)
local PopoverSide = require(Enums.PopoverSide)
local PopoverAlign = require(Enums.PopoverAlign)
local FillBehavior = require(Enums.FillBehavior)
local ColorNamespace = require(Enums.ColorNamespace)
local CloseAffordanceVariant = require(Enums.CloseAffordanceVariant)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local defaultProps = {
	isOpen = false,
	align = PopoverAlign.Start,
	side = PopoverSide.Right
}

local MAX_BUTTON_COUNT = 2

local function stepsText(current: number, total: number)
	return Translator:FormatByKey("CommonUI.Controls.Label.PageCount", { current = current, total = total })
end

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

type ActionProps = Types.ActionProps
type Selection = Types.Selection
type SelectionGroup = Types.SelectionGroup
type PopoverAnchor = Types.PopoverAnchor
type PopoverAlign = PopoverAlign.PopoverAlign
type PopoverSide = PopoverSide.PopoverSide
type PopoverAnchorProps = Popover.PopoverAnchorProps

export type EducationalTooltipProps = {
	-- The scope the component will be created in.
	scope: Scope,
	-- A title for the educational tooltip. To omit, set it to an empty string.
	title: UsedAs<string>,
	-- Body text for the educational tooltip.
	text: UsedAs<string?>,
	-- Media displayed at the top of the educational tooltip
	media: Child?,
	-- Actions array (up to 2 buttons supported)
	actions: UsedAs<{ ActionProps }?>,
	isOpen: UsedAs<boolean?>,
	-- Close callback (optional) - if provided, displays a close affordance in the header
	onClose: (() -> ())?,
	-- Step indicator (optional) - shows "X of Y" above the header
	steps: {
		current: number,
		total: number,
	}?,
	align: UsedAs<PopoverAlign?>,
	side: UsedAs<PopoverSide?>,
	-- Reference to the element that will serve as an anchor
	anchorInstance: UsedAs<PopoverAnchor>?,
	children: UsedAs<Child | ((scope: Scope) -> {Child})>?,
	-- Selection behavior
	selection: Selection?,
	selectionGroup: (UsedAs<boolean> | SelectionGroup)?,
} & Types.CommonProps

return function(educationalTooltipProps: EducationalTooltipProps)
	local scope = educationalTooltipProps.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the EducationalTooltip component.")
	
	local props = withDefaults(educationalTooltipProps, defaultProps)
	return scope:Computed(function(use: Use, innerScope: Scope) 
		local tokens = unwrap(theme.Tokens, use)
		local maxXSize = useScaledValue(320, use)
		local side = unwrap(props.side, use)
		local children = unwrap(props.children, use)
		
		-- Size constraint for text elements when close affordance is present
		local textSizeConstraint = if props.onClose
			then {
				MaxSize = Vector2.new(maxXSize - tokens.Size.Size_1200, math.huge),
			}
			else nil
		
		local buttonChildren = innerScope:Computed(function(use: Use, innerScope: Scope) 
			local buttons: Child = {}
			local actions = unwrap(props.actions, use)
			if not actions then return buttons end
			
			for i, action in actions do
				if i > MAX_BUTTON_COUNT then
					-- This can be converted back to Logger Utility if Lumberyak is added as a package.
					warn(`Coachmark only supports up to {MAX_BUTTON_COUNT} actions`)
					break
				end

				local actionProps = {
					scope = innerScope,
					LayoutOrder = i,
					size = InputSize.Medium,
					fillBehavior = FillBehavior.Fill
				}
				
				local buttonProps = Dash.union(action, actionProps)
				table.insert(buttons, Button(buttonProps))
			end
			
			return buttons
		end)
		
		if type(children) == "function" then
			children = children(innerScope)
		end

		return Popover.Root {
			scope = innerScope,
			isOpen = props.isOpen,
			children = Fragment {
				{Popover.Anchor, {
					anchorInstance = props.anchorInstance,
					children = children and { children } or nil,
				}},
				{Popover.Content, {
					hasArrow = true,
					align = props.align,
					side = {
						position = side,
						offset = tokens.Size.Size_200
					},
					radius = Radius.Medium,
					backgroundStyle = tokens.Inverse.Surface.Surface_0,
					selection = props.selection,
					selectionGroup = props.selectionGroup,
					children = {
						if props.onClose then 
							CloseAffordance {
								scope = innerScope,
								onActivated = props.onClose,
								size = InputSize.Small,
								variant = CloseAffordanceVariant.Utility,
								colorNamespace = ColorNamespace.Inverse,
								Position = UDim2.new(1, -tokens.Padding.Small, 0, tokens.Padding.Small),
								AnchorPoint = Vector2.new(1, 0), -- Top-right anchor
								ZIndex = 2
							}
							else nil,
						View {
							scope = innerScope,
							tag = "col gap-medium auto-xy padding-bottom-medium",
							sizeConstraint = {
								MaxSize = Vector2.new(maxXSize, math.huge),
							},
							children = {
								if props.media then
									View {
										scope = innerScope,
										LayoutOrder = 1,
										tag = "size-full-0 auto-y",
										children = props.media
									}
									else nil,
								if props.actions and #props.actions > 0 then
									View {
										scope = innerScope,
										LayoutOrder = 3,
										tag = "row gap-small size-full-0 auto-y padding-x-medium",
										children = buttonChildren
									}
									else nil,
								View {
									scope = innerScope,
									LayoutOrder = 2,
									tag = "col gap-xsmall auto-xy padding-x-medium padding-bottom-xsmall padding-top-medium",
									children = {
										if props.steps then
											Text {
												scope = innerScope,
												LayoutOrder = 1,
												Text = stepsText(props.steps.current, props.steps.total),
												tag = "auto-xy text-label-small text-align-x-left text-truncate-end content-inverse-default",
												sizeConstraint = textSizeConstraint
											}
											else nil,
										if props.title ~= "" then
											Text {
												scope = innerScope,
												LayoutOrder = 2,
												Text = props.title,
												tag = "auto-xy text-title-large text-align-x-left text-truncate-split content-inverse-emphasis",
												sizeConstraint = textSizeConstraint
											}
											else nil,
										if props.text and props.text ~= "" then
											Text {
												scope = innerScope,
												LayoutOrder = 3,
												Text = props.text,
												tag = "size-full-0 auto-y text-body-medium text-wrap text-align-x-left content-inverse-default"
											}
											else nil
									}
								}
							}
						}
					}
				}}
			}
		}
	end)
end