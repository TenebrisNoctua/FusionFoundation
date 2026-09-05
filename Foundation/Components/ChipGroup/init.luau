local Foundation = script.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Chip = require(Components.Chip)
local ScrollView = require(Components.ScrollView)
local View = require(Components.View)

local Accessory = require(Components.Chip.Accessory)
type Accessory = Accessory.Accessory

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)

local useChipGroupVariants = require(script.useChipGroupVariants)

local ChipGroupVariant = require(Enums.ChipGroupVariant)
type ChipGroupVariant = ChipGroupVariant.ChipGroupVariant

local ChipSize = require(Enums.ChipSize)
type ChipSize = ChipSize.ChipSize
type ChipGroupSize = useChipGroupVariants.ChipGroupSize

local ChipVariant = require(Enums.ChipVariant)
type ChipVariant = ChipVariant.ChipVariant

local Visibility = require(Enums.Visibility)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type ColorStyleValue = Types.ColorStyleValue

local START_GRADIENT = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.5, 0),
	NumberSequenceKeypoint.new(1, 1),
})

local END_GRADIENT = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.5, 0),
	NumberSequenceKeypoint.new(1, 0),
})

export type ChipGroupItem = {
	text: string?,
	leading: (string | Accessory)?,
	trailing: (string | Accessory)?,
	onActivated: () -> (),
	isChecked: boolean?,
	variant: ChipVariant?,
}

export type ChipGroupProps = {
	-- The chips to render in the group.
	chips: { ChipGroupItem },
	-- Size applied to every Chip in the group. Overrides each Chip's own
	-- `size`.
	size: UsedAs<ChipGroupSize>?,
	-- Controls how chips are laid out. Row renders chips in a single
	-- scrollable row with edge scrims that spills outside the group bounds.
	-- Wrap flows chips onto multiple rows and clips to the group bounds.
	variant: UsedAs<ChipGroupVariant>?,
	-- The color the scrims fade into.
	scrimBackgroundStyle: UsedAs<ColorStyleValue>?
} & Types.CommonProps

local defaultProps = {
	size = ChipSize.Medium,
	variant = ChipGroupVariant.Row :: ChipGroupVariant,
}

local function Scrim(scope: Scope, props: {
	gradient: NumberSequence,
	width: number,
	backgroundStyle: UsedAs<ColorStyleValue>,
	LayoutOrder: number?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
})
	return View {
		scope = scope,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.new(0, props.width, 1, 0),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		backgroundStyle = props.backgroundStyle,
		children = {
			UIGradient = scope:New "UIGradient" {
				Transparency = props.gradient,
			},
		},
	}
end

return function(chipGroupProps: ChipGroupProps)
	local scope = chipGroupProps.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the ChipGroup component.")

	local props = withDefaults(chipGroupProps, defaultProps)

	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local size = unwrap(props.size, use) :: ChipGroupSize
		local groupVariant = unwrap(props.variant, use)
		local scrimBackgroundStyle = unwrap(props.scrimBackgroundStyle, use) or tokens.Color.Surface.Surface_0

		local variant = useChipGroupVariants(unwrap(theme.Theme, use), tokens, groupVariant, size)

		local isStartVisible = innerScope:Value(false)
		local isEndVisible = innerScope:Value(false)
		local viewportWidth = innerScope:Value(0)

		local function updateScrimGeometry(newData: Vector2, scrollingFrame: ScrollingFrame)
			if not variant.hasScrim or scrollingFrame.AbsoluteWindowSize.X == 0 then return end
			viewportWidth:set(scrollingFrame.AbsoluteWindowSize.X)
			isStartVisible:set(scrollingFrame.CanvasPosition.X ~= 0)
			isEndVisible:set(
				(scrollingFrame.AbsoluteWindowSize.X + scrollingFrame.CanvasPosition.X)
					< (scrollingFrame.AbsoluteCanvasSize.X - 1)
			)
		end

		local chips = {}
		for i, chipItem in props.chips do
			chips[`Chip{i}`] = Chip {
				scope = innerScope,
				text = chipItem.text,
				leading = chipItem.leading,
				trailing = chipItem.trailing,
				onActivated = chipItem.onActivated,
				isChecked = chipItem.isChecked,
				variant = chipItem.variant,
				size = size,
				LayoutOrder = i,
			}
		end

		local scrollView = ScrollView {
			scope = innerScope,
			tag = "size-full-0 auto-y",
			scroll = {
				AutomaticSize = Enum.AutomaticSize.Y,
				AutomaticCanvasSize = Enum.AutomaticSize.X,
				CanvasSize = UDim2.fromScale(0, 1),
				ScrollingDirection = Enum.ScrollingDirection.X,
				ScrollingEnabled = not variant.isWrapped,
				scrollBarVisibility = Visibility.None,
			},
			layout = {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, variant.gap),
				Wraps = variant.isWrapped,
			},
			ClipsDescendants = variant.isWrapped,
			onCanvasPositionChanged = if variant.hasScrim then updateScrimGeometry else nil,
			onAbsoluteCanvasSizeChanged = if variant.hasScrim then updateScrimGeometry else nil,
			onAbsoluteWindowSizeChanged = if variant.hasScrim then updateScrimGeometry else nil,
			children = chips,
		}

		local scrimGroup = nil
		if variant.hasScrim then
			local scrimWidth = variant.scrimWidth

			scrimGroup = View {
				scope = innerScope,
				BackgroundTransparency = 1,
				Size = innerScope:Computed(function(use: Use)
					local width = unwrap(viewportWidth, use)
					return UDim2.fromOffset(width, scrimWidth)
				end),
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0),
				ZIndex = 2,
				children = {
					ScrimStart = innerScope:Computed(function(use: Use)
						if not unwrap(isStartVisible, use) then
							return nil
						end
						return Scrim(innerScope, {
							LayoutOrder = 1,
							gradient = START_GRADIENT,
							width = scrimWidth,
							backgroundStyle = scrimBackgroundStyle,
							Position = UDim2.fromScale(0, 0),
							AnchorPoint = Vector2.new(0, 0),
						})
					end),
					ScrimEnd = innerScope:Computed(function(use: Use)
						if not unwrap(isEndVisible, use) then
							return nil
						end
						return Scrim(innerScope, {
							LayoutOrder = 2,
							gradient = END_GRADIENT,
							width = scrimWidth,
							backgroundStyle = scrimBackgroundStyle,
							Position = UDim2.fromScale(1, 0),
							AnchorPoint = Vector2.new(1, 0),
						})
					end),
				},
			}
		end

		return View(withCommonProps(props, {
			scope = innerScope,
			tag = "size-full-0 auto-y",
			children = {
				ScrollView = scrollView,
				ScrimWrapper = scrimGroup,
			},
		}))
	end)
end
