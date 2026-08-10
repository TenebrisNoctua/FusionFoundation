-- Written by @TenebrisNoctua
-- Provides the elevation layer used by certain components.

local Foundation = script.Parent.Parent
local Enums = Foundation.Enums
local ElevationLayer = require(Enums.ElevationLayer)

local ELEVATION_LAYERS: { [ElevationLayer]: ElevationLayerSpec } = {
	[ElevationLayer.Popover] = { start = 4, finish = 99, step = 1 },
	[ElevationLayer.Drawer] = { start = 100, finish = 199, step = 10 },
	[ElevationLayer.Sheet] = { start = 200, finish = 299, step = 10 },
	[ElevationLayer.Dialog] = { start = 300, finish = 399, step = 10 },
	-- TODO: update this when we have a Notification component in Foundation v2
	[ElevationLayer.Notification] = { start = 400, finish = 499, step = 1 },
}

local elevationProvider = {
	ELEVATION_LAYERS = ELEVATION_LAYERS,
	counters = nil :: { [ElevationLayer]: number }?,
}

type ElevationLayer = ElevationLayer.ElevationLayer

export type ElevationLayerSpec = { start: number, finish: number, step: number }
export type Token = {
	layer: ElevationLayer,
	zIndex: number,
	index: number,
}

export type elevationProvider = typeof(elevationProvider)

--// Main Functions

function elevationProvider.acquire(self: elevationProvider, layer: ElevationLayer, options: { reserve: boolean, owner: Token? }?): Token
	assert(self.counters, "ElevationProvider has not been initialized!")

	local spec = ELEVATION_LAYERS[layer]
	local count = self.counters[layer] or 0
	local safeOptions = options or { reserve = false }

	local index = -1
	local zIndex
	local shouldCap = true
 	 
	if safeOptions.owner then
		zIndex = safeOptions.owner.zIndex + 1
		shouldCap = safeOptions.owner.zIndex <= spec.finish
	elseif safeOptions.reserve then
		zIndex = spec.start + (count + 1) * spec.step
		self.counters[layer] = count + 1
		index = count
	else
		zIndex = spec.start
	end
 	  
	if shouldCap and zIndex > spec.finish then
		warn(
			string.format(
				"Layer '%s' capacity exceeded (%d/%d). Capping zIndex at %d.",
				tostring(layer),
				zIndex,
				spec.finish,
				spec.finish
			)
		)
		zIndex = spec.finish
	end
 	 
	return { layer = layer, index = index, zIndex = zIndex }
end

function elevationProvider.peek(self: elevationProvider, layer: ElevationLayer): number
	assert(self.counters, "ElevationProvider has not been initialized!")
	return self.counters[layer] or 0
end

function elevationProvider.releaseIfTop(self: elevationProvider, layer: ElevationLayer, index: number)
	assert(self.counters, "ElevationProvider has not been initialized!")
	local current = self.counters[layer] or 0

	if index ~= nil and index >= 0 and index == (current - 1) then
		self.counters[layer] = current - 1
	end
end

function elevationProvider.getRelativeIndex(token: Token): number
	local spec = ELEVATION_LAYERS[token.layer]
	return token.zIndex - spec.start
end

return function(): (elevationProvider, () -> ()?)
	if elevationProvider.counters then return elevationProvider end

	elevationProvider.counters = {
		[ElevationLayer.Popover] = 0,
		[ElevationLayer.Drawer] = 0,
		[ElevationLayer.Sheet] = 0,
		[ElevationLayer.Dialog] = 0,
		[ElevationLayer.Notification] = 0,
	}

	return elevationProvider, function()
		elevationProvider.counters = nil
	end
end