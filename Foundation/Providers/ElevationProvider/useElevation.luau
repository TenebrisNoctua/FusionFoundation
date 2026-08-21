local Foundation = script.Parent.Parent.Parent

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)
local ElevationLayer = require(Enums.ElevationLayer)

local ElevationProvider = require(script.Parent)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type ElevationLayer = ElevationLayer.ElevationLayer
type Token = ElevationProvider.Token

export type UseElevationOptions = {
	stackAboveOwner: UsedAs<boolean>?,
	ownerToken: UsedAs<Token?>?
}

type ElevationProvider = ElevationProvider.elevationProvider

local function releaseCurrentToken(elevationProvider: ElevationProvider, tokenState: UsedAs<Token>)
	local currentToken: Token? = unwrap(tokenState)
	if currentToken and currentToken.index ~= nil and currentToken.index >= 0 then
		elevationProvider:releaseIfTop(currentToken.layer, currentToken.index)
	end
end

local function updateToken(elevationProvider: ElevationProvider, tokenState: UsedAs<Token>, layer: UsedAs<ElevationLayer>, options: UseElevationOptions?)
	releaseCurrentToken(elevationProvider, tokenState)
 	 
	local currentLayer: ElevationLayer = unwrap(layer)
	local safeOptions: UseElevationOptions = options or {}
 	  	
	local stackAboveOwner = unwrap(safeOptions.stackAboveOwner) or false
	local owner = unwrap(safeOptions.ownerToken)
 	  	 
	local isNestedSameLayer = owner ~= nil and owner.layer == currentLayer
	local newToken: Token
 	  	
	if stackAboveOwner then
		if not owner then
			newToken = elevationProvider:acquire(currentLayer, { reserve = false })
		elseif isNestedSameLayer then
			newToken = elevationProvider:acquire(currentLayer, { reserve = true, owner = owner })
		else
			local desired = owner.zIndex + 1
			newToken = {
				layer = currentLayer,
				index = -1,
				zIndex = desired,
			}
		end
	else
		newToken = elevationProvider:acquire(currentLayer, { reserve = isNestedSameLayer })
	end
 	  	
	tokenState:set(newToken)
end

return function(scope: Scope, layer: UsedAs<ElevationLayer>, options: UseElevationOptions?): UsedAs<Token>
	local elevationProvider = ElevationProvider()
	local tokenState = scope:Value(nil) :: UsedAs<Token>

	local dependencies = scope:Computed(function(use: Use)
		local safeOptions: UseElevationOptions = options or {}
		return {
			layer = unwrap(layer, use),
			stackAboveOwner = unwrap(safeOptions.stackAboveOwner, use),
			ownerToken = unwrap(safeOptions.ownerToken, use)
		}
	end)

	scope:Observer(dependencies):onChange(function() 
		updateToken(elevationProvider, tokenState, layer, options)	
	end)
	updateToken(elevationProvider, tokenState, layer, options)
	
	table.insert(scope, function()
		releaseCurrentToken(elevationProvider, tokenState)
	end)

	return tokenState
end

