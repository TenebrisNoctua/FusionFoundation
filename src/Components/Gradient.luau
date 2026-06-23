--!nonstrict

local Foundation = script.Parent.Parent

local Types = require(Foundation.Utility.Types.Types)
local unwrap = require(Foundation.Utility.unwrap)
local stripProps = require(Foundation.Utility.stripProps)

local COMPONENT_ONLY_PROPERTIES = {
	"fillDirection",
	"top"
}

type Scope = Types.Scope
type Use = Types.Use

export type GradientProps = {
	scope: Scope,
	fillDirection: Enum.FillDirection,
	top: boolean,
}

return function(props: GradientProps)
	local Scope = props.scope
	assert(Scope, "A scope has not been provided for the Gradient component.")
	
	return Scope:Computed(function(use: Use, innerScope: Scope)
		local top = unwrap(props.top, use)
		return innerScope:Hydrate(innerScope:New "UIGradient" {
			Rotation = if unwrap(props.fillDirection, use) == Enum.FillDirection.Vertical then 90 else 0,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, if top then 0 else 1),
				NumberSequenceKeypoint.new(
					0.5,
					if top then 0 else 1
				),
				NumberSequenceKeypoint.new(
					0.50001,
					if top then 1 else 0
				),
				NumberSequenceKeypoint.new(1, if top then 1 else 0),
			}),
		})(stripProps(props, COMPONENT_ONLY_PROPERTIES))
	end)
end
