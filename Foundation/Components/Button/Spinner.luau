local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Utility = Foundation.Utility
local TypesSource = Utility.Types

local Image = require(Foundation.Components.Image)
local View = require(Foundation.Components.View)

local withDefaults = require(Utility.withDefaults)
local stripProps = require(Utility.stripProps)
local unwrap = require(Utility.unwrap)
local useRotation = require(Utility.useRotation)
local Types = require(TypesSource.Types)

local defaultProps = {
	style = {}
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
	local scale = props.scale
	
	return Image {
		scope = scope,
		Image = "icons/status/loading_large",
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		imageStyle = props.style,
		Rotation = rotation,
		children = {
			scope:New "UIScale" {
				--Scale = scale
			}
		}
	}
end

local function Path2DSpinner(props: InternalSpinnerProps, scope: Scope)
	local pathRef = scope:Value(nil :: Path2D?)
	local rotation = useRotation(2, scope)
	
	scope:Observer(pathRef):onChange(function() 
		local path = unwrap(pathRef)
		if path ~= nil then
			path:SetControlPoints(SPINNER_CONTROL_POINTS)
		end	
	end)
	
	return View {
		scope = scope,
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Rotation = rotation,
		children = {
			pathRef:set(scope:New "Path2D" {
				Closed = false,
				Color3 = scope:Tween(scope:Computed(function(use) 
					local styleValues = unwrap(props.style, use)
					return styleValues.Color3
				end), TweenInfo.new(0.2, Enum.EasingStyle.Linear)),
				Transparency = scope:Tween(scope:Computed(function(use) 
					local styleValues = unwrap(props.style, use)
					return styleValues.Transparency
				end), TweenInfo.new(0.2, Enum.EasingStyle.Linear)),
				Thickness = props.thickness
			}),
			
			scope:New "UIScale" {
				Scale = props.Scale
			}
		}
	}
end

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

type InternalSpinnerProps = {
	scope: Scope,
	style: UsedAs<Types.ColorStyleValue>,
	scale: UsedAs<number>,
	thickness: number,
}

type SpinnerProps = {
	scope: Scope,
	scale: UsedAs<number>,
	style: UsedAs<Types.ColorStyle>,
	size: UsedAs<UDim2>,
	usePath2DSpinner: boolean?
}

return function(spinnerProps: SpinnerProps)
	local Scope = spinnerProps.scope
	assert(Scope, "A scope has not been provided for the Spinner component.")
	
	local props = withDefaults(spinnerProps, defaultProps)
	local scaleTween = Scope:Tween(props.scale, TweenInfo.new(0.2, Enum.EasingStyle.Quad))
	
	return View {
		scope = Scope,
		Size = props.Size,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		
		children = {
			if props.usePath2DSpinner then
				Path2DSpinner {
					scope = Scope,
					scale = scaleTween,
					style = props.style,
					thickness = math.max(math.floor(props.Size.X.Offset / 8), 1)
				}
			else
				IconSpinner {
					scope = Scope,
					scale = scaleTween,
					style = props.style
				}
		}
	}
end