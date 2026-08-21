local Foundation = script.Parent.Parent.Parent.Parent

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useBreakpoint = require(script.Parent.useBreakpoint)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)
local Breakpoint = require(Enums.Breakpoint)

local ResponsiveProvider = require(script.Parent.Parent)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type ResponsiveValue<T> = Types.ResponsiveValue<T>
type ResponsiveConfig = ResponsiveProvider.ResponsiveConfig
type Breakpoint = Breakpoint.Breakpoint

return function<T>(scope: Scope, instance: GuiBase2d?, value: ResponsiveValue<T>): UsedAs<T>
	local breakpointState, _ = useBreakpoint(scope, instance)
	local responsive = ResponsiveProvider()
	local breakpointConfig = responsive.config.breakpoint

	return scope:Computed(function(use: Use): T
		local breakpoint: Breakpoint = unwrap(breakpointState, use)
		local shortName = breakpointConfig.shortNames[breakpoint]
		return value[shortName] :: T
	end)
end