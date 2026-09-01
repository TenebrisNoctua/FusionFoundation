local Foundation = script.Parent.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility

local Image = require(Components.Image)
local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local useRotation = require(Utility.useRotation)
local withDefaults = require(Utility.withDefaults)
local isPluginSecurity = require(Utility.isPluginSecurity)
local Types = require(Utility.Types)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type InternalSpinnerProps = {
	scope: Scope,
	style: UsedAs<{ Color3: Color3, Transparency: number }>,
	scale: UsedAs<number>,
	Thickness: number
}

type SpinnerProps = {
	scope: Scope,
	style: UsedAs<any>?,
	Size: UsedAs<UDim2>,
	isVisible: UsedAs<boolean>?
}

local FoundationUsePath2DSpinner = false

local defaultProps = {
	style = {},
	isVisible = false
}

-- Right, Top, Left, Bottom
local SPINNER_CONTROL_POINTS = {
	Path2DControlPoint.new(UDim2.fromScale(1, 0.5), UDim2.fromScale(0, 0.25), UDim2.fromScale(0, -0.25)),
	Path2DControlPoint.new(UDim2.fromScale(0.5, 0), UDim2.fromScale(0.25, 0), UDim2.fromScale(-0.25, 0)),
	Path2DControlPoint.new(UDim2.fromScale(0, 0.5), UDim2.fromScale(0, -0.33), UDim2.fromScale(0, 0.33)),
	Path2DControlPoint.new(UDim2.fromScale(0.5, 1), UDim2.fromScale(-0.25, 0), UDim2.fromScale(0.25, 0)),
}

local function IconSpinner(props: InternalSpinnerProps)
	local scope = props.scope
	local rotation = useRotation(2, scope)

	return Image {
		scope = scope,
		Image = "icons/status/loading_large",
		Rotation = rotation,
		tag = "position-center-center anchor-center-center size-full-full",
		imageStyle = props.style,
		children = {
			scope:New "UIScale" {
				Scale = props.scale
			}
		}
	}
end

local function Path2DSpinner(props: InternalSpinnerProps)
	local scope = props.scope
	local rotation = useRotation(2, scope)

	local circlePath = scope:New "Path2D" {
		Closed = false,
		Color3 = scope:Computed(function(use: Use)
			local styleValues = unwrap(props.style, use)
			return styleValues and styleValues.Color3
		end),
		Transparency = if isPluginSecurity()
			then scope:Computed(function(use: Use)
				local styleValues = unwrap(props.style, use)
				return styleValues and styleValues.Transparency
			end)
			else nil,
		Thickness = props.Thickness,
	}

	circlePath:SetControlPoints(SPINNER_CONTROL_POINTS)

	return View {
		scope = scope,
		tag = "position-center-center anchor-center-center size-full",
		Rotation = rotation,
		children = {
			Circle = circlePath,
			UIScale = scope:New "UIScale" {
				Scale = props.scale
			}
		}
	}
end

local function Spinner(spinnerProps: SpinnerProps)
	local scope = spinnerProps.scope
	assert(scope, "A scope must be provided to the Spinner component.")

	local props = withDefaults(spinnerProps, defaultProps)

	local initialVisible = unwrap(props.isVisible) or false
	local animScale = scope:Value(initialVisible and 1 or 0)
	local animTransparency = scope:Value(initialVisible and 0 or 1)

	local scaleTween = scope:Tween(animScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad))
	local transparencyTween = scope:Tween(animTransparency, TweenInfo.new(0.2, Enum.EasingStyle.Quad))

	local currentSize = unwrap(props.Size)
	local calculatedThickness = math.max(math.floor(currentSize.X.Offset / 8), 1)

	local mixedStyle = scope:Computed(function(use: Use)
		local baseStyle = unwrap(props.style, use) or {}
		local currentAnimTransparency = unwrap(transparencyTween, use)

		local baseColor = baseStyle.Color3 or Color3.new(1, 1, 1)
		local baseTransparency = baseStyle.Transparency or 0

		return {
			Color3 = baseColor,
			Transparency = math.clamp(currentAnimTransparency + baseTransparency, 0, 1)
		}
	end)

	local visibleState = scope:Computed(function(use: Use)
		return unwrap(props.isVisible, use)
	end)

	scope:Observer(visibleState):onChange(function()
		local isVisible = unwrap(visibleState)
		if isVisible then
			animScale:set(1)
			animTransparency:set(0)
		else
			animScale:set(0)
			animTransparency:set(1)
		end
	end)

	return View {
		scope = scope,
		tag = "position-center-center anchor-center-center",
		Size = props.Size,
		children = {
			Spinner = if FoundationUsePath2DSpinner
				then Path2DSpinner {
					scope = scope,
					scale = scaleTween,
					style = mixedStyle,
					Thickness = calculatedThickness
				}
				else IconSpinner {
					scope = scope,
					scale = scaleTween,
					style = mixedStyle,
					Thickness = calculatedThickness
				}
		}
	}
end

return Spinner