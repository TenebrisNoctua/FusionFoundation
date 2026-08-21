local Foundation = script.Parent.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Dash = PackageManager.getPackage("Dash")

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Breakpoint = require(Enums.Breakpoint)
local Constants = require(Foundation.Constants)
local ResponsiveProvider = require(script.Parent.Parent)
local withDefaults = require(Utility.withDefaults)
local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type BreakpointConfig = ResponsiveProvider.BreakpointConfig
type Breakpoint = Breakpoint.Breakpoint

type UseBreakpointOptions = {
	-- Time to debounce the absolute size change in seconds
	throttleTime: number?
}

-- Buffer applied in the direction of the breakpoint change to prevent flickering at breakpoint boundaries
local BUFFER = 5

local function calculateBreakpointFromWidth(breakpointConfig: BreakpointConfig, width: number): Breakpoint
	local currentBreakpoint: Breakpoint = breakpointConfig.order[#breakpointConfig.order]

	for _, breakpoint: Breakpoint in breakpointConfig.order do
		if width <= breakpointConfig.widths[breakpoint] then
			currentBreakpoint = breakpoint
			break
		end
	end

	return currentBreakpoint
end

local function getBreakpointIndex(breakpointConfig: BreakpointConfig, targetBreakpoint: Breakpoint): number?
	return Dash.findIndex(breakpointConfig.order, function(breakpoint)
		return breakpoint == targetBreakpoint
	end)
end

local function shouldChangeBreakpoint(
	breakpointConfig: BreakpointConfig,
	currentWidth: number,
	candidateBreakpoint: Breakpoint,
	previousBreakpoint: Breakpoint?
): boolean
	if not previousBreakpoint then
		return true
	end

	if candidateBreakpoint == previousBreakpoint then
		return false
	end

	local previousBreakpointIndex = getBreakpointIndex(breakpointConfig, previousBreakpoint)
	local candidateBreakpointIndex = getBreakpointIndex(breakpointConfig, candidateBreakpoint)

	if previousBreakpointIndex and candidateBreakpointIndex then
		if candidateBreakpointIndex > previousBreakpointIndex then
			local previousBreakpointWidth: number = breakpointConfig.widths[previousBreakpoint :: Breakpoint]
			return currentWidth > (previousBreakpointWidth + BUFFER)
		else
			local candidateBreakpointWidth: number = breakpointConfig.widths[candidateBreakpoint :: Breakpoint]
			return currentWidth < (candidateBreakpointWidth - BUFFER)
		end
	end

	return true
end

return function(scope: Scope, instance: GuiBase2d?, options: UseBreakpointOptions?): (UsedAs<Breakpoint>, UsedAs<Vector2>)
	local resolvedOptions = withDefaults(options or {}, {
		throttleTime = Constants.DEFAULT_DELAY_TIME,
	})

	local responsive = ResponsiveProvider()
	local breakpointConfig = responsive.config.breakpoint

	local absoluteSizeState = scope:Value(Vector2.zero) :: UsedAs<Vector2>
	local stableBreakpointState = scope:Value(calculateBreakpointFromWidth(breakpointConfig, 0)) :: UsedAs<Breakpoint>

	local previousBreakpoint: Breakpoint? = nil
	local connection: RBXScriptConnection? = nil
	local trailingTask: thread? = nil
	local lastUpdate: number = 0

	local function updateBreakpoint()
		local currentSize = unwrap(absoluteSizeState)
		local candidateBreakpoint = calculateBreakpointFromWidth(breakpointConfig, currentSize.X)
		if shouldChangeBreakpoint(breakpointConfig, currentSize.X, candidateBreakpoint, previousBreakpoint) then
			previousBreakpoint = candidateBreakpoint
			stableBreakpointState:set(candidateBreakpoint)
		end
	end

	local function onSizeChanged()
		if not instance then return end

		local now = os.clock()
		local elapsed = now - lastUpdate

		if elapsed >= resolvedOptions.throttleTime then
			lastUpdate = now
			absoluteSizeState:set(instance.AbsoluteSize)
			updateBreakpoint()
		else
			-- Schedule trailing update
			if trailingTask then
				task.cancel(trailingTask)
			end
			trailingTask = task.delay(resolvedOptions.throttleTime - elapsed, function()
				lastUpdate = os.clock()
				if instance then
					absoluteSizeState:set(instance.AbsoluteSize)
					updateBreakpoint()
				end
			end)
		end
	end

	if instance then
		connection = instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(onSizeChanged)
		absoluteSizeState:set(instance.AbsoluteSize)
		updateBreakpoint()
	end

	table.insert(scope, function()
		if connection then
			connection:Disconnect()
			connection = nil
		end
		if trailingTask then
			task.cancel(trailingTask)
			trailingTask = nil
		end
	end)

	return stableBreakpointState, absoluteSizeState
end