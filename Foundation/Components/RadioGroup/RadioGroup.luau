local Foundation = script.Parent.Parent.Parent

local Components = Foundation.Components
local Utility = Foundation.Utility

local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local isState = require(Utility.isState)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)

local RadioGroupContext = require(script.Parent.RadioGroupContext)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

export type RadioGroupProps = {
	scope: Scope,
	-- The value of the currently checked radio item. If left nil, the radio group is
	-- uncontrolled and manages its own state.
	value: UsedAs<string?>?,
	onValueChanged: ((newValue: string) -> ())?,
	children: UsedAs<{Child} | ((scope: Scope) -> {Child})>?
} & Types.SelectionProps & Types.CommonProps

local defaultProps = {
	Selectable = true,
}

return function(radioGroupProps: RadioGroupProps)
	local scope = radioGroupProps.scope
	assert(scope, "A scope has not been provided for the RadioGroup component.")

	local props = withDefaults(radioGroupProps, defaultProps)
	local valueInternal = scope:Value(unwrap(props.value))
	
	if isState(props.value) then
		scope:Observer(props.value):onChange(function()
			local newValue = unwrap(props.value)
			if not newValue then return end
			valueInternal:set(newValue)
		end)
	end

	local function onValueChanged(newValue: string)
		valueInternal:set(newValue)
		if props.onValueChanged then
			props.onValueChanged(newValue)
		end
	end

	return scope:Computed(function(use: Use, innerScope: Scope)
		local children = unwrap(props.children, use)

		local contextValue: RadioGroupContext.RadioGroupContextType = {
			value = valueInternal,
			onValueChanged = onValueChanged,
			Selectable = props.Selectable,
		}

		return View(withCommonProps(props, {
			scope = innerScope,
			tag = "col gap-medium auto-xy",
			children = RadioGroupContext:is(contextValue):during(function()
				if type(children) == "function" then
					return children(innerScope)
				end
				return children
			end)
		}))
	end)
end
