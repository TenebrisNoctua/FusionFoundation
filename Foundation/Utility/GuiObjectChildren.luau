local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Dash = PackageManager.getPackage("Dash")

local Padding = require(Foundation.Components.Padding)
local AspectRatio = require(Foundation.Components.AspectRatio)

local isState = require(script.Parent.isState)
local unwrap = require(script.Parent.unwrap)
local Types = require(script.Parent.Types)

type Use = Types.Use
type Child = Types.Child

type GuiObjectProps = Types.GuiObjectProps
type CommonProps = Types.CommonProps

local function GuiObjectChildren(props: GuiObjectProps & CommonProps): Child
	local Scope = props.scope
	local utilityChildren = {
		if props.aspectRatio ~= nil then
			AspectRatio { 
				value = props.aspectRatio, 
				scope = Scope 
			}
		else nil,
		if props.cornerRadius ~= nil then 
			Scope:New "UICorner" {
				CornerRadius = props.cornerRadius,
			}
		else nil,
		if props.flexItem ~= nil then 
			Scope:New "UIFlexItem" {
				FlexMode = props.flexItem.FlexMode,
				GrowRatio = props.flexItem.GrowRatio,
				ShrinkRatio = props.flexItem.ShrinkRatio,
				ItemLineAlignment = props.flexItem.ItemLineAlignment,
			}
		else nil,
		if props.layout ~= nil and props.layout.FillDirection ~= nil then 
			Scope:New "UIListLayout" {
				FillDirection = props.layout.FillDirection,
				ItemLineAlignment = props.layout.ItemLineAlignment,
				HorizontalAlignment = props.layout.HorizontalAlignment,
				HorizontalFlex = props.layout.HorizontalFlex,
				VerticalAlignment = props.layout.VerticalAlignment,
				VerticalFlex = props.layout.VerticalFlex,
				Padding = props.layout.Padding,
				SortOrder = props.layout.SortOrder,
				Wraps = props.layout.Wraps,
			}
		else nil,
		if props.sizeConstraint ~= nil then 
			Scope:New("UISizeConstraint")(props.sizeConstraint)
		else nil,
		if props.padding ~= nil then 
			Padding {
				value = props.padding,
				scope = Scope
			}
		else nil,
		if props.scale ~= nil then 
			Scope:New "UIScale" {
				Scale = props.scale,
			}
		else nil,
		if props.stroke ~= nil and not isState(props.stroke) then 
			Scope:New("UIStroke")(props.stroke) 
		elseif props.stroke ~= nil then 
			Scope:Computed(function(use: Use) 
				local strokeProps = unwrap(props.stroke, use)
				if not strokeProps then return end
				return Scope:New "UIStroke" {
					Color = strokeProps.Color,
					Transparency = strokeProps.Transparency,
					Thickness = strokeProps.Thickness,
					BorderStrokePosition = strokeProps.BorderStrokePosition
				}
			end)
		else nil,
	}

	if not props.children then
		return utilityChildren
	end

	if isState(props.children) then
		return Scope:Computed(function(use: Use)
			local dynamicChildren = unwrap(props.children, use)
			if not dynamicChildren then
				return utilityChildren
			end
			if typeof(dynamicChildren) == "Instance" then
				return Dash.join(utilityChildren, { dynamicChildren })
			end
			return Dash.join(utilityChildren, dynamicChildren)
		end)
	end

	return Dash.join(utilityChildren, unwrap(props.children) or {})
end

return GuiObjectChildren
