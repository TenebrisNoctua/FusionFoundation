local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
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
	local defTransp = defaultTransparency or 0

	local targetTransparency = scope:Computed(function(use: Use)
		local state = use(currentState)
		if state == "Disabled" then return disabledTransparency
		elseif state == "Loading" then return 0
		else return defTransp end
	end)

	local targetTextTransparency = scope:Computed(function(use: Use)
		local state = use(currentState)
		if state == "Disabled" then return disabledTransparency
		elseif state == "Loading" then return 1
		else return defTransp end
	end)

	local targetIconTransparency = scope:Computed(function(use: Use)
		local state = use(currentState)
		if state == "Loading" then return 1
		else return 0 end
	end)

	local targetIconScale = scope:Computed(function(use: Use)
		local state = use(currentState)
		if state == "Loading" then return 0
		else return 1 end
	end)

	local generalTweenInfo = scope:Computed(function(use: Use)
		local state = use(currentState)
		local duration = if state == "Disabled" then 0.1 else 0.2
		return TweenInfo.new(duration, Enum.EasingStyle.Linear)
	end)

	local iconTweenInfo = scope:Computed(function(use: Use)
		local state = use(currentState)
		local duration = if state == "Default" then 0.5 else 0.2
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