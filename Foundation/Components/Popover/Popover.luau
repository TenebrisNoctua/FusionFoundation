local Foundation = script.Parent.Parent.Parent
local Utility = Foundation.Utility

local PopoverAnchor = require(script.Parent.Anchor)
local PopoverContentProxy = require(script.Parent.PopoverContentProxy)

local withDefaults = require(Utility.withDefaults)
local Types = require(Utility.Types)
local StudioUri = require(Utility.Plugin.StudioUri)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

type PopoverAnchor = Types.PopoverAnchor
type StudioUri = StudioUri.StudioUri

export type PopoverProps = {
	scope: Scope,
	isOpen: UsedAs<boolean>,
	-- Anchor props
	anchorInstance: UsedAs<Instance?>?,
	anchorChildren: {Child}?,
	-- Content props  
	side: UsedAs<any>?,
	align: UsedAs<any>?,
	hasArrow: UsedAs<boolean>?,
	onPressedOutside: (() -> ())?,
	selection: UsedAs<any>?,
	selectionGroup: UsedAs<any>?,
	radius: UsedAs<any>?,
	backgroundStyle: UsedAs<any>?,
	contentChildren: {Child}?,
} & Types.CommonProps

local defaultProps = {
	isOpen = false,
}

return function(popoverProps: PopoverProps)
	local Scope = popoverProps.scope
	assert(Scope, "A scope has not been provided for the Popover component.")

	local props = withDefaults(popoverProps, defaultProps)
	local anchor = Scope:Value(nil :: PopoverAnchor?)
	local anchorUri = Scope:Value(nil :: StudioUri?)
	
	return Scope:Computed(function(use: Use, innerScope: Scope)
		local anchorProps = {
			scope = innerScope,
			anchor = anchor,
			anchorUri = anchorUri,
			isOpen = props.isOpen,
			anchorInstance = props.anchorInstance,
			children = props.anchorChildren
		}

		local contentProps = {
			scope = innerScope,
			anchor = anchor,
			anchorUri = anchorUri,
			isOpen = props.isOpen,
			side = props.side,
			align = props.align,
			hasArrow = props.hasArrow,
			onPressedOutside = props.onPressedOutside,
			selection = props.selection,
			selectionGroup = props.selectionGroup,
			radius = props.radius,
			backgroundStyle = props.backgroundStyle,
			children = props.contentChildren,
		}

		return {
			Anchor = PopoverAnchor(anchorProps),
			Content = PopoverContentProxy(contentProps)
		}
	end)
end