local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local unwrap = require(Foundation.Utility.unwrap)
local Types = require(Foundation.Utility.Types.Types)

type Scope = Types.Scope
type Use = Types.Use
type Tween<T> = Types.Tween<T>
type UsedAs<T> = Types.UsedAs<T>

export type ButtonState = "Default" | "Loading" | "Disabled"

export type ButtonMotion = {
	transparency: Tween<number>,
	textTransparency: Tween<number>,
	iconTransparency: Tween<number>,
	iconScale: Tween<number>,
}

local function useButtonMotionStates(
	scope: Scope, 
	currentState: UsedAs<ButtonState>, 
	defaultTransparency: number?, 
	disabledTransparency: number
): ButtonMotion
	local defTransp = unwrap(defaultTransparency) or 0

	local targetTransparency = scope:Value(defTransp)
	local targetTextTransparency = scope:Value(defTransp)
	local targetIconTransparency = scope:Value(1)
	local targetIconScale = scope:Value(1)

	local function updateMotionTargets(state: ButtonState)
		if state == "Disabled" then
			targetTransparency:set(disabledTransparency)
			targetTextTransparency:set(0)
			targetIconTransparency:set(1)
			targetIconScale:set(1)
		elseif state == "Loading" then
			targetTransparency:set(0)
			targetTextTransparency:set(1)
			targetIconTransparency:set(0)
			targetIconScale:set(0)
		else
			targetTransparency:set(defTransp)
			targetTextTransparency:set(defTransp)
			targetIconTransparency:set(1)
			targetIconScale:set(1)
		end
	end

	local initialStatus = unwrap(currentState)
	if initialStatus then
		updateMotionTargets(initialStatus)
	end

	scope:Observer(currentState):onChange(function()
		local newState = unwrap(currentState)
		if newState then
			updateMotionTargets(newState)
		end
	end)

	local generalTweenInfo = scope:Computed(function(use: Use)
		local state = unwrap(currentState, use)
		local duration = if state == "Disabled" then 0.1 else 0.2
		return TweenInfo.new(duration, Enum.EasingStyle.Linear)
	end)

	local iconTweenInfo = scope:Computed(function(use: Use)
		local state = unwrap(currentState, use)
		local duration = if state == "Default" then 0.5 else 1
		return TweenInfo.new(duration, Enum.EasingStyle.Linear)
	end)

	return {
		transparency = scope:Tween(targetTransparency, generalTweenInfo),
		textTransparency = scope:Tween(targetTextTransparency, generalTweenInfo),
		iconTransparency = scope:Tween(targetIconTransparency, iconTweenInfo),
		iconScale = scope:Tween(targetIconScale, generalTweenInfo), 
	}
end

return useButtonMotionStates