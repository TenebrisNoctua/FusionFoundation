local Foundation = script.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local useClock = require(Utility.useClock)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local usePulseBinding = require(Utility.usePulseBinding)
local Types = require(Utility.Types)

local Radius = require(Enums.Radius)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local PreferencesProvider = require(Foundation.Providers.PreferencesProvider)

local TRANSPARENCY_DELTA = 0.1
local GRADIENT_OFFSET = 3
local ANIMATION_SPEED = 2

local defaultProps = {
	radius = Radius.None,
	Size = UDim2.fromScale(1, 1)
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type Radius = Radius.Radius

export type SkeletonProps = {
	radius: UsedAs<Radius>?,
	Size: UsedAs<UDim2>?
} & Types.CommonProps

return function(skeletonProps: SkeletonProps)
	local scope = skeletonProps.scope
	assert(scope, "A scope has not been provided for the Skeleton component.")

	local theme = ThemeProvider()
	local preferencesProvider = PreferencesProvider()
	local reducedMotionEnabled = preferencesProvider.preferences.reducedMotion

	local props = withDefaults(skeletonProps, defaultProps)
	local clockValue = useClock(scope)
	local pulseValue = usePulseBinding(scope, ANIMATION_SPEED)

	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local radius = unwrap(props.radius, use)

		local cornerRadius = if radius ~= Radius.None then UDim.new(0, tokens.Radius[radius]) else nil
		local backgroundStyle
		
		if reducedMotionEnabled then
			local white10 = tokens.Color.Extended.White.White_10
			backgroundStyle = innerScope:Computed(function(use: Use)
				local alpha = unwrap(pulseValue, use)
				return {
					Color3 = tokens.Color.Shift.Shift_300.Color3,
					Transparency = white10.Transparency - TRANSPARENCY_DELTA * alpha,
				}
			end)
		else
			-- Full opacity background lets the gradient's transparency take accurate effect
			backgroundStyle = tokens.Color.Extended.White.White_100
		end

		return View(withCommonProps(props, {
			scope = innerScope,
			cornerRadius = cornerRadius,
			backgroundStyle = backgroundStyle,
			Size = props.Size,
			children = {
				Gradient = if not reducedMotionEnabled
					then innerScope:New "UIGradient" {
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, tokens.Color.Shift.Shift_300.Color3),
							ColorSequenceKeypoint.new(0.5, tokens.Color.Extended.White.White_30.Color3),
							ColorSequenceKeypoint.new(1, tokens.Color.Shift.Shift_300.Color3),
						}),
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, tokens.Color.Shift.Shift_300.Transparency),
							NumberSequenceKeypoint.new(0.5, tokens.Color.Extended.White.White_30.Transparency),
							NumberSequenceKeypoint.new(1, tokens.Color.Shift.Shift_300.Transparency),
						}),
						Offset = innerScope:Computed(function(use: Use)
							local value = unwrap(clockValue, use)
							return Vector2.new(value * ANIMATION_SPEED % GRADIENT_OFFSET - (GRADIENT_OFFSET / 2), 0)
						end),
						Rotation = 15
					}
					else nil
			}
		}))
	end)
end
