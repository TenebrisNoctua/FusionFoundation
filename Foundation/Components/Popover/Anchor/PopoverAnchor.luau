local Foundation = script.Parent.Parent.Parent.Parent
local Utility = Foundation.Utility

local View = require(Foundation.Components.View)

local withCommonProps = require(Utility.withCommonProps)
local isState = require(Utility.isState)
local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

export type PopoverAnchorProps = {
	scope: Scope,
	-- From PopoverContext:
	anchor: UsedAs<Instance?>?,
	setAnchor: ((instance: Instance?) -> ())?,
	isOpen: UsedAs<boolean>?,
	-- The target state or instance to anchor the popover to. If provided, children will not be rendered.
	anchorInstance: UsedAs<Instance?>?,
	gui: UsedAs<Instance?>?,
	children: {Child}?,
} & Types.CommonProps

--// Component Implementation

return function(props: PopoverAnchorProps)
	local scope = props.scope
	assert(scope, "A scope has not been provided for the PopoverAnchor component.")

	local viewInstance = scope:Value(nil :: Instance?)

	local activeAnchor = scope:Computed(function(use: Use)
		local externalAnchor = unwrap(props.anchorInstance, use)
		if externalAnchor then return externalAnchor end
		return unwrap(viewInstance, use)
	end)

	local function handleAnchorRegistration()
		local anchor = unwrap(activeAnchor)
		if props.setAnchor then
			props.setAnchor(anchor)
		end
	end

	scope:Observer(activeAnchor):onChange(handleAnchorRegistration)
	task.defer(handleAnchorRegistration)

	if isState(props.gui) then
		scope:Observer(viewInstance):onChange(function()
			local currentView = unwrap(viewInstance)
			props.gui:set(currentView)
		end)
	end

	table.insert(scope, function()
		if props.setAnchor then
			props.setAnchor(nil)
		end
	end)

	return scope:Computed(function(use: Use, innerScope: Scope)
		viewInstance:set(nil)
		local externalAnchor = unwrap(props.anchorInstance, use)
		if externalAnchor then return end

		local viewProps = withCommonProps(props, {
			scope = scope,
			tag = "auto-xy",
			children = props.children
		})

		return viewInstance:set(unwrap(View(viewProps)))
	end)
end