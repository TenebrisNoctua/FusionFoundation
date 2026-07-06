local Foundation = script.Parent.Parent

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local getGeneratedRules = require(Utility.getGeneratedRules)
local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local Device = require(Enums.Device)
local Theme = require(Enums.Theme)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type Theme = Theme.Theme
type Device = Device.Device

local function useGeneratedRules(scope: Scope, theme: UsedAs<Theme>, device: UsedAs<Device>): UsedAs<any>
	return scope:Computed(function(use: Use): any
		local currentTheme: Theme = unwrap(theme, use)
		local currentDevice: Device = unwrap(device, use)
		return getGeneratedRules(currentTheme, currentDevice)
	end)
end

return useGeneratedRules