local Foundation = script.Parent.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local AccordionContext = require(script.Parent.AccordionContext)

local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)

local defaultProps = {
	size = InputSize.Medium,
	width = UDim.new(1, 0)
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

type InputSize = InputSize.InputSize
type onAccordionItemActivated = AccordionContext.onAccordionItemActivated

export type AccordionProps = {
	-- The scope the component will be created in
	scope: Scope,
	-- width of the Accordion and it's items
	width: UsedAs<UDim>?,
	-- activation function for children AccordionItems based on their id
	onActivated: onAccordionItemActivated?,
	-- size to pass to children
	size: UsedAs<InputSize>?,
	children: UsedAs<{Child} | ((scope: Scope) -> {Child})>?,
} & Types.CommonProps

return function(accordionProps: AccordionProps)
	local scope = accordionProps.scope
	assert(scope, "A scope has not been provided for the Accordion component.")

	local props = withDefaults(accordionProps, defaultProps)
	return scope:Computed(function(use: Use, innerScope: Scope)
		local width = unwrap(props.width, use)
		local children = unwrap(props.children, use)

		local contextValue: AccordionContext.AccordionContextType = {
			onAccordionItemActivated = props.onActivated,
			itemSize = props.size
		}

		return View(withCommonProps(props, {
			scope = innerScope,
			tag = "col flex-y-evenly auto-y",
			Size = UDim2.new(width, UDim.new(0, 0)),
			children = AccordionContext:is(contextValue):during(function()
				if type(children) == "function" then
					return children(innerScope)
				end
				return children
			end)
		}))
	end)
end
