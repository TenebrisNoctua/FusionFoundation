local Foundation = script.Parent.Parent.Parent.Parent
local Utility = Foundation.Utility

local View = require(Foundation.Components.View)

local withCommonProps = require(Utility.withCommonProps)
local isState = require(Utility.isState)
local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)
local StudioUri = require(Utility.Plugin.StudioUri)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

type StudioUri = StudioUri.StudioUri

export type PopoverAnchorProps = {
	scope: Scope,
	-- From PopoverContext:
	anchor: UsedAs<Instance?>?,
	anchorUri: UsedAs<StudioUri?>?,
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
	
	local anchorIsState = isState(props.anchor)
	local anchorUriIsState = isState(props.anchorUri)
	local guiIsState = isState(props.gui)

	local viewInstance = scope:Value(nil :: Instance?)

	local activeAnchor = scope:Computed(function(use: Use)
		local externalAnchor = unwrap(props.anchorInstance, use)
		if externalAnchor and not StudioUri.isStudioUri(externalAnchor) then
			return externalAnchor
		end
		return unwrap(viewInstance, use)
	end)

	local function handleAnchorRegistration()
		local externalAnchor = unwrap(props.anchorInstance)
		if StudioUri.isStudioUri(externalAnchor) then
			if anchorUriIsState then
				props.anchorUri:set(externalAnchor)
			end
			if anchorIsState then
				props.anchor:set(nil)
			end
		else
			local anchor = unwrap(activeAnchor)
			if anchorIsState then
				props.anchor:set(anchor)
			end
			if anchorUriIsState then
				props.anchorUri:set(nil)
			end
		end
	end

	scope:Observer(activeAnchor):onChange(handleAnchorRegistration)
	task.defer(handleAnchorRegistration)

	if guiIsState then
		scope:Observer(viewInstance):onChange(function()
			local currentView = unwrap(viewInstance)
			props.gui:set(currentView)
		end)
	end

	table.insert(scope, function()
		if anchorIsState then
			props.anchor:set(nil)
		end
		if anchorUriIsState then
			props.anchorUri:set(nil)
		end
	end)

	return scope:Computed(function(use: Use, innerScope: Scope)
		local externalAnchor = unwrap(props.anchorInstance, use)
		if externalAnchor then return end

		local viewProps = withCommonProps(props, {
			scope = innerScope,
			tag = "auto-xy",
			children = props.children
		})

		local instance = unwrap(View(viewProps))
		viewInstance:set(instance)
		return instance
	end)
end