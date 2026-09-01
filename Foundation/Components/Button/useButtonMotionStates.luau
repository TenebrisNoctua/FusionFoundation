local Foundation = script.Parent.Parent.Parent

local unwrap = require(Foundation.Utility.unwrap)
local Types = require(Foundation.Utility.Types)

type UsedAs<T> = Types.UsedAs<T>
type Tween<T> = Types.Tween<T>
type Scope = Types.Scope
type Use = Types.Use

export type ButtonMotion = {
	-- Driven solely by isDisabled.
	transparency: Tween<number>,
	-- Driven solely by isLoading.
	textTransparency: Tween<number>,
}

local function useButtonMotionStates(
	scope: Scope,
	isLoading: UsedAs<boolean>,
	isDisabled: UsedAs<boolean>,
	defaultTransparency: number?,
	disabledTransparency: number
): ButtonMotion
	local defTransp = unwrap(defaultTransparency) or 0
	
	-- isLoading and isDisabled can also be simple booleans, rather than state objects.
	-- Putting them in Computeds workaround this issue. 
	-- We could have used isState with Observers here, but that would increase complexity for no real benefit.
	local isLoadingState = scope:Computed(function(use: Use)
		return unwrap(isLoading, use)
	end)
	local isDisabledState = scope:Computed(function(use: Use)
		return unwrap(isDisabled, use)
	end)

	local targetTextTransparency = scope:Value(if unwrap(isLoadingState) then 1 else defTransp)
	scope:Observer(isLoadingState):onChange(function()
		targetTextTransparency:set(if unwrap(isLoadingState) then 1 else defTransp)
	end)

	local targetTransparency = scope:Value(if unwrap(isDisabledState) then disabledTransparency else defTransp)
	scope:Observer(isDisabledState):onChange(function()
		targetTransparency:set(if unwrap(isDisabledState) then disabledTransparency else defTransp)
	end)

	local transparencyTweenInfo = scope:Computed(function(use: Use)
		local duration = if unwrap(isDisabledState, use) then 0.1 else 0.2
		return TweenInfo.new(duration, Enum.EasingStyle.Linear)
	end)

	return {
		transparency = scope:Tween(targetTransparency, transparencyTweenInfo),
		textTransparency = scope:Tween(targetTextTransparency, TweenInfo.new(0.2, Enum.EasingStyle.Linear))
	}
end

return useButtonMotionStates