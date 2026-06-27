local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Padding = require(Foundation.Components.Padding)
local AspectRatio = require(Foundation.Components.AspectRatio)

local unwrap = require(script.Parent.unwrap)
local Types = require(script.Parent.Types.Types)

local Children = Fusion.Children

type GuiObjectProps = Types.GuiObjectProps
type CommonProps = Types.CommonProps

local function GuiObjectChildren(props: GuiObjectProps & CommonProps): {Instance}
	local Scope = props.scope
	return if unwrap(props.children) ~= props.children then props.children else Dash.join({
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
		if props.stroke ~= nil then 
			Scope:New("UIStroke")(props.stroke) 
		else nil
		
	}, if props.children ~= nil then unwrap(props.children) else {})
end

return GuiObjectChildren
