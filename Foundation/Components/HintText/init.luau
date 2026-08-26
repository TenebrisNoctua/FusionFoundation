local Foundation = script.Parent.Parent
local Utility = Foundation.Utility

local Text = require(Foundation.Components.Text)

local unwrap = require(Utility.unwrap)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type HintTextProps = {
	-- The scope the component will be created in
	scope: Scope,
	-- Determines the string rendered by the UI element
	text: UsedAs<string>,
	-- Whether the input is in an error state
	hasError: UsedAs<boolean>?,
	-- Whether the input is disabled
	isDisabled: UsedAs<boolean>?,
} & Types.CommonProps

return function(hintTextProps: HintTextProps)
	local scope = hintTextProps.scope
	assert(scope, "A scope has not been provided for the HintText component.")
	
	return scope:Computed(function(use: Use, innerScope: Scope) 
		local hasError = unwrap(hintTextProps.hasError, use)
		local isDisabled = unwrap(hintTextProps.isDisabled, use)		
		
		local props = withCommonProps(hintTextProps, {
			scope = innerScope,
			Text = hintTextProps.text,
			tag = {
				["size-full-0 auto-y text-caption-small text-align-x-left text-align-y-top text-wrap"] = true,
				["content-action-alert"] = hasError,
				["content-muted"] = isDisabled and not hasError,
				["content-default"] = not isDisabled and not hasError
			}
		})
		
		return Text(props :: any)
	end)
end
