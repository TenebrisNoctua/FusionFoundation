local Foundation = script.Parent.Parent.Parent.Parent

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useBreakpoint = require(script.Parent.useBreakpoint)

local Types = require(Utility.Types)
local Breakpoint = require(Enums.Breakpoint)

local OverlayProvider = require(Foundation.Providers.OverlayProvider)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Breakpoint = Breakpoint.Breakpoint

return function(scope: Scope): UsedAs<Breakpoint>
	local overlay = OverlayProvider()
	local breakpoint, _ = useBreakpoint(scope, overlay.screen)
	return breakpoint
end