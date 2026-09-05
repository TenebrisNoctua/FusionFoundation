local Foundation = script.Parent.Parent.Parent

local BaseMenuDivider = require(script.Parent.BaseMenuDivider)
local BaseMenuTitleItem = require(script.Parent.BaseMenuTitleItem)
local BaseMenuContext = require(script.Parent.BaseMenuContext)

local View = require(Foundation.Components.View)

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child
type InputSize = InputSize.InputSize

local SIZE_TO_PADDING: { [string]: string } = {
	["XSmall"] = "padding-xsmall",
	["Small"] = "padding-small",
	["Medium"] = "padding-small",
	["Large"] = "padding-small",
}

export type BaseMenuGroupProps = {
	scope: Scope,
	title: UsedAs<string?>?,
	children: (UsedAs<{Child} | ((scope: Scope) -> {Child})>)?,
	LayoutOrder: UsedAs<number>?
} & { [number]: Child }

local function BaseMenuGroup(props: BaseMenuGroupProps)
	local scope = props.scope
	assert(scope, "A scope has not been provided for the BaseMenuGroup component.")

	local context = BaseMenuContext:now()

	local positionalChildren
	if #props > 0 then
		positionalChildren = {}
		for i, child in ipairs(props) do
			positionalChildren[i] = child
		end
	end
	
	local children = props.children or positionalChildren
	local groupIndex = unwrap(props.LayoutOrder) or 1

	local tagValue = scope:Computed(function(use: Use)
		local currentSize = unwrap(context.size, use) or InputSize.Medium
		local paddingTag = SIZE_TO_PADDING[currentSize] or "padding-small"
		return `col gap-xxsmall size-full-0 auto-y {paddingTag}`
	end)

	local titleChild = scope:Computed(function(use: Use, titleInnerScope: Scope)
		local currentTitle = unwrap(props.title, use)
		if currentTitle == nil then return nil end
		return BaseMenuContext:is(context):during(function()
			return BaseMenuTitleItem {
				scope = titleInnerScope,
				text = currentTitle
			}
		end)
	end)

	local resolvedChildren = children
	if type(children) == "function" then
		resolvedChildren = scope:Computed(function(use: Use, childrenInnerScope: Scope)
			return BaseMenuContext:is(context):during(function()
				return (children :: (Scope) -> { Child })(childrenInnerScope)
			end)
		end)
	end

	local groupView = View {
		scope = scope,
		LayoutOrder = groupIndex * 2,
		tag = tagValue,
		children = {
			Title = titleChild,
			Items = resolvedChildren
		}
	}

	if groupIndex == 1 then
		return { Group = groupView }
	end

	return {
		Divider = BaseMenuDivider {
			scope = scope,
			LayoutOrder = groupIndex * 2 - 1,
		},
		Group = groupView
	}
end

return BaseMenuGroup