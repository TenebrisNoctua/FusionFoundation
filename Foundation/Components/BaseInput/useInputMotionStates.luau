local Foundation = script.Parent.Parent.Parent

local unwrap = require(Foundation.Utility.unwrap)
local Types = require(Foundation.Utility.Types)

type UsedAs<T> = Types.UsedAs<T>
type Tween<T> = Types.Tween<T>
type Scope = Types.Scope
type Use = Types.Use

type ColorStyleValue = Types.ColorStyleValue

export type InputColors = {
	backgroundStyle: ColorStyleValue?,
	hoverStyle: ColorStyleValue?,
	checkedStyle: ColorStyleValue?,
	labelStyle: ColorStyleValue?,
	labelHoverStyle: ColorStyleValue?,
}

export type InputMotion = {
	backgroundColor: Tween<Color3>,
	backgroundTransparency: Tween<number>,
	strokeColor: Tween<Color3>,
	strokeTransparency: Tween<number>,
	labelColor: Tween<Color3>,
	labelTransparency: Tween<number>,
}

type InputState = "Default" | "Hover" | "Checked"

local function useInputMotionStates(
	scope: Scope,
	tokens: {[string]: any},
	colorsOrCheckedStyle: (InputColors | ColorStyleValue)?,
	currentState: UsedAs<InputState>
): InputMotion
	local colors: InputColors? = colorsOrCheckedStyle :: InputColors?

	local defaultStyle: ColorStyleValue = if colors and colors.backgroundStyle
		then colors.backgroundStyle
		else tokens.Color.Content.Default
	local hoverStyle: ColorStyleValue = if colors and colors.hoverStyle
		then colors.hoverStyle
		else tokens.Color.Content.Emphasis
	local checkedStyle: ColorStyleValue = if colors and colors.checkedStyle
		then colors.checkedStyle
		else tokens.Color.ActionSubEmphasis.Background
	local labelStyle: ColorStyleValue = if colors and colors.labelStyle
		then colors.labelStyle
		else tokens.Color.Content.Default
	local labelHoverStyle: ColorStyleValue = if colors and colors.labelHoverStyle
		then colors.labelHoverStyle
		else tokens.Color.Content.Emphasis

	local targetBgColor = scope:Value(defaultStyle.Color3 or Color3.new())
	local targetBgTransparency = scope:Value(if colors and colors.backgroundStyle then colors.backgroundStyle.Transparency or 1 else 1)
	local targetStrokeColor = scope:Value(defaultStyle.Color3 or Color3.new())
	local targetStrokeTransparency = scope:Value(defaultStyle.Transparency or 0)
	local targetLabelColor = scope:Value(labelStyle.Color3 or Color3.new())
	local targetLabelTransparency = scope:Value(labelStyle.Transparency or 0)

	local function updateMotionTargets(state: InputState)
		if state == "Checked" then
			targetBgColor:set(checkedStyle.Color3 or Color3.new())
			targetBgTransparency:set(checkedStyle.Transparency or 0)
			targetStrokeColor:set(checkedStyle.Color3 or Color3.new())
			targetStrokeTransparency:set(checkedStyle.Transparency or 0)
			targetLabelColor:set(labelHoverStyle.Color3 or Color3.new())
			targetLabelTransparency:set(labelHoverStyle.Transparency or 0)
		elseif state == "Hover" then
			targetBgColor:set(hoverStyle.Color3 or Color3.new())
			targetBgTransparency:set(if colors and colors.hoverStyle then colors.hoverStyle.Transparency or 1 else 1)
			targetStrokeColor:set(hoverStyle.Color3 or Color3.new())
			targetStrokeTransparency:set(hoverStyle.Transparency or 0)
			targetLabelColor:set(labelHoverStyle.Color3 or Color3.new())
			targetLabelTransparency:set(labelHoverStyle.Transparency or 0)
		else
			targetBgColor:set(defaultStyle.Color3 or Color3.new())
			targetBgTransparency:set(if colors and colors.backgroundStyle then colors.backgroundStyle.Transparency or 1 else 1)
			targetStrokeColor:set(defaultStyle.Color3 or Color3.new())
			targetStrokeTransparency:set(defaultStyle.Transparency or 0)
			targetLabelColor:set(labelStyle.Color3 or Color3.new())
			targetLabelTransparency:set(labelStyle.Transparency or 0)
		end
	end

	local initialState = unwrap(currentState)
	if initialState then
		updateMotionTargets(initialState)
	end

	scope:Observer(currentState):onChange(function()
		local newState = unwrap(currentState)
		if newState then
			updateMotionTargets(newState)
		end
	end)

	local tweenInfo = scope:Computed(function(use: Use)
		local state = unwrap(currentState, use)
		local duration = if state == "Hover" then 0 else 0.2
		return TweenInfo.new(duration, Enum.EasingStyle.Linear)
	end)

	return {
		backgroundColor = scope:Tween(targetBgColor, tweenInfo),
		backgroundTransparency = scope:Tween(targetBgTransparency, tweenInfo),
		strokeColor = scope:Tween(targetStrokeColor, tweenInfo),
		strokeTransparency = scope:Tween(targetStrokeTransparency, tweenInfo),
		labelColor = scope:Tween(targetLabelColor, tweenInfo),
		labelTransparency = scope:Tween(targetLabelTransparency, tweenInfo)
	}
end

return useInputMotionStates