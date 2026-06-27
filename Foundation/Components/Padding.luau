local Foundation = script.Parent.Parent
local Utility = Foundation.Utility

local PackageManager = require(Foundation.PackageManager)
local Types = require(Utility.Types.Types)
local unwrap = require(Utility.unwrap)

local Fusion = PackageManager.getPackage("Fusion")

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope

type Padding = Types.Padding
type PaddingTable = Types.PaddingTable

export type PaddingProps = {
	value: Padding,
	scope: Scope
}

local function getPadding(padding: Padding): {
	PaddingTop: UsedAs<UDim>?,
	PaddingBottom: UsedAs<UDim>?,
	PaddingLeft: UsedAs<UDim>?,
	PaddingRight: UsedAs<UDim>?,
}
	if unwrap(padding) ~= padding then
		return {
			PaddingTop = padding :: UsedAs<UDim>,
			PaddingBottom = padding :: UsedAs<UDim>,
			PaddingLeft = padding :: UsedAs<UDim>,
			PaddingRight = padding :: UsedAs<UDim>,
		}
	elseif typeof(padding) == "table" then
		local paddingTable = padding :: PaddingTable
		return {
			PaddingTop = paddingTable.top,
			PaddingBottom = paddingTable.bottom,
			PaddingLeft = paddingTable.left,
			PaddingRight = paddingTable.right,
		}
	elseif typeof(padding) == "number" then
		return {
			PaddingTop = UDim.new(0, padding),
			PaddingBottom = UDim.new(0, padding),
			PaddingLeft = UDim.new(0, padding),
			PaddingRight = UDim.new(0, padding),
		}
	elseif typeof(padding) == "Vector2" then
		return {
			PaddingTop = UDim.new(0, padding.Y),
			PaddingBottom = UDim.new(0, padding.Y),
			PaddingLeft = UDim.new(0, padding.X),
			PaddingRight = UDim.new(0, padding.X),
		}
	elseif typeof(padding) == "UDim" then
		return {
			PaddingTop = padding,
			PaddingBottom = padding,
			PaddingLeft = padding,
			PaddingRight = padding,
		}
	elseif typeof(padding) == "UDim2" then
		return {
			PaddingTop = padding.Y,
			PaddingBottom = padding.Y,
			PaddingLeft = padding.X,
			PaddingRight = padding.X,
		}
	else
		return {}
	end
end

local function Padding(props: PaddingProps)
	local Scope = props.scope
	assert(Scope, "A scope has not been provided for the Padding component.")
	
	local padding = getPadding(props.value)
	return Scope:New("UIPadding")(padding)
end

return Padding
