local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Utility = Foundation.Utility

local withDefaults = require(Utility.withDefaults)
local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local Children = Fusion.Children

local defaultProps = {
	anchor = nil :: PopoverAnchor?,
	setAnchor = function(instance: PopoverAnchor?)
		warn("This function has not been initialized.") -- This can be converted back to Logger Utility if Lumberyak is added as a package.
	end,
	isOpen = false
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child
type PopoverAnchor = Types.PopoverAnchor

export type PopoverProps = {
	scope: Scope,
	isOpen: UsedAs<boolean>,
	children: { Child }?
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
		local currentIsOpen = unwrap(props.isOpen, use)
		
		-- Inject context fields down to the component children properties
		local wrappedChildren = {}
		if props.children then
			for key, child in pairs(props.children) do
				if type(child) == "table" and child.props then
					child.props.anchor = anchor
					child.props.setAnchor = setAnchor
					child.props.isOpen = currentIsOpen
				end
				wrappedChildren[key] = child
			end
		end

		return innerScope:New "Folder" {
			[Children] = wrappedChildren
		}
	end)
end