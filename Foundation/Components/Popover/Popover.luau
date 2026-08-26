local Foundation = script.Parent.Parent.Parent
local Utility = Foundation.Utility

local PopoverAnchor = require(script.Parent.Anchor)
local PopoverContext = require(script.Parent.PopoverContext)
local PopoverContentProxy = require(script.Parent.PopoverContentProxy)

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local Types = require(Utility.Types)
local StudioUri = require(Utility.Plugin.StudioUri)

local defaultProps = {
	isOpen = false
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

type PopoverAnchor = Types.PopoverAnchor
type StudioUri = StudioUri.StudioUri

export type PopoverProps = {
	scope: Scope,
	isOpen: UsedAs<boolean>,
	children: UsedAs<{Child} | ((scope: Scope) -> {Child})>?,
} & Types.CommonProps

local function PopoverRoot(popoverProps: PopoverProps)
	local scope = popoverProps.scope
	assert(scope, "A scope has not been provided for the Popover component.")

	local props = withDefaults(popoverProps, defaultProps)
	local anchor = scope:Value(nil :: PopoverAnchor?)
	local anchorUri = scope:Value(nil :: StudioUri?)
	local gui = scope:Value(nil :: Instance?)

	local contextValue = {
		anchor = anchor,
		anchorUri = anchorUri,
		isOpen = props.isOpen,
		gui = gui
	}

	return scope:Computed(function(use: Use, innerScope: Scope)
		local children = unwrap(props.children, use)

		return PopoverContext:is(contextValue):during(function()
			if type(children) == "function" then
				return children(innerScope)
			end
			return children
		end)
	end)
end

return PopoverRoot