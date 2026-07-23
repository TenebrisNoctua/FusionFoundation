local Foundation = script.Parent.Parent.Parent
local Utility = Foundation.Utility

local withDefaults = require(Utility.withDefaults)
local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local defaultProps = {
	isOpen = false
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child
type PopoverAnchor = Types.PopoverAnchor

export type PopoverContext = {
	anchor: UsedAs<PopoverAnchor?>,
	setAnchor: (instance: PopoverAnchor?) -> (),
	isOpen: UsedAs<boolean>,
}

export type PopoverProps = {
	scope: Scope,
	isOpen: UsedAs<boolean>,
	render: (scope: Scope, context: PopoverContext) -> { Child }?,
} & Types.CommonProps

return function(popoverProps: PopoverProps)
	local Scope = popoverProps.scope
	assert(Scope, "A scope has not been provided for the Popover component.")

	local props = withDefaults(popoverProps, defaultProps)
	local anchor = Scope:Value(nil :: PopoverAnchor?)

	local function setAnchor(instance: PopoverAnchor?)
		anchor:set(instance)
	end

	return Scope:Computed(function(use: Use, innerScope: Scope)
		local context: PopoverContext = {
			anchor = anchor,
			setAnchor = setAnchor,
			isOpen = props.isOpen,
		}

		if props.render then
			return props.render(innerScope, context)
		end

		return nil
	end)
end