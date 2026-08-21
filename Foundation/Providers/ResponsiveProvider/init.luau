local Foundation = script.Parent.Parent

local Utility = Foundation.Utility

local withDefaults = require(Utility.withDefaults)
local BreakpointConfig = require(Utility.Responsive.BreakpointConfig)
local GridConfig = require(Utility.Responsive.GridConfig)

export type BreakpointConfig = typeof(BreakpointConfig)
export type GridConfig = typeof(GridConfig)

export type ResponsiveProviderProps = {
	config: ResponsiveConfig?
}

export type ResponsiveConfig = {
	breakpoint: BreakpointConfig,
	grid: GridConfig
}

local defaultProps = {
	config = {
		breakpoint = BreakpointConfig,
		grid = GridConfig,
	}
}

local responsiveProvider = {
	config = nil :: ResponsiveConfig?,
}

type responsiveProvider = typeof(responsiveProvider)

return function(props: ResponsiveProviderProps?): (responsiveProvider, () -> ()?)
	if responsiveProvider.config then return responsiveProvider end

	local resolvedProps = withDefaults(props or {}, defaultProps)
	responsiveProvider.config = resolvedProps.config

	return responsiveProvider, function()
		responsiveProvider.config = nil
	end
end