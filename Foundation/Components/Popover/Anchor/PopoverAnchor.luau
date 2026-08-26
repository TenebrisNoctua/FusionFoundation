local Foundation = script.Parent.Parent.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility

local PopoverContext = require(script.Parent.Parent.PopoverContext)

local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local isState = require(Utility.isState)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)
local StudioUri = require(Utility.Plugin.StudioUri)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

type StudioUri = StudioUri.StudioUri

export type PopoverAnchorProps = {
	scope: Scope,
	-- The target state or instance to anchor the popover to. If provided, children will not be rendered.
	anchorInstance: UsedAs<Instance?>?,
	children: {Child}?,
} & Types.CommonProps

--// Component Implementation

return function(props: PopoverAnchorProps)
	local scope = props.scope
	assert(scope, "A scope has not been provided for the PopoverAnchor component.")

	local context = PopoverContext:now()
	local anchorState = context.anchor
	local anchorUriState = context.anchorUri
	local guiState = context.gui

	local anchorIsState = isState(anchorState)
	local anchorUriIsState = isState(anchorUriState)
	local guiIsState = isState(guiState)

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
				anchorUriState:set(externalAnchor)
			end
			if anchorIsState then
				anchorState:set(nil)
			end
		else
			local anchor = unwrap(activeAnchor)
			if anchorIsState then
				anchorState:set(anchor)
			end
			if anchorUriIsState then
				anchorUriState:set(nil)
			end
		end
	end

	scope:Observer(activeAnchor):onChange(handleAnchorRegistration)
	task.defer(handleAnchorRegistration)

	if guiIsState then
		scope:Observer(viewInstance):onChange(function()
			local currentView = unwrap(viewInstance)
			guiState:set(currentView)
		end)
	end

	table.insert(scope, function()
		if anchorIsState then
			anchorState:set(nil)
		end
		if anchorUriIsState then
			anchorUriState:set(nil)
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