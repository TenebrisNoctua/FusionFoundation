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
	children: { Child }?,
	LayoutOrder: UsedAs<number>,
}

local function BaseMenuGroup(props: BaseMenuGroupProps)
	local scope = props.scope
	assert(scope, "A scope has not been provided for the BaseMenuGroup component.")

	local context = BaseMenuContext:now()

	return scope:Computed(function(use: Use, innerScope: Scope) 
		local groupIndex = unwrap(props.LayoutOrder, use) or 1
		local currentSize = unwrap(context.size, use) or InputSize.Medium
		local currentTitle = unwrap(props.title, use)
		local paddingTag = SIZE_TO_PADDING[currentSize] or "padding-small"
		
		local children = props.children
		local childrenResult = {}

		if groupIndex ~= 1 then
			childrenResult.Divider = BaseMenuDivider {
				scope = innerScope,
				LayoutOrder = groupIndex * 2 - 1,
			}
		end
		
		-- If children is a function, call it within the context so child components can read it
		if type(children) == "function" then
			children = BaseMenuContext:is(context):during(function()
				return children(innerScope)
			end)
		end

		childrenResult.Group = View {
			scope = innerScope,
			LayoutOrder = groupIndex * 2,
			tag = `col gap-xxsmall size-full-0 auto-y {paddingTag}`,
			children = {
				Title = if currentTitle
					then BaseMenuContext:is(context):during(function()
						return BaseMenuTitleItem {
							scope = innerScope,
							text = currentTitle,
						}
						end)
					else nil,
				Items = children
			}
		}

		return childrenResult
	end)
end

return BaseMenuGroup