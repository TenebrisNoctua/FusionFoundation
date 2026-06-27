local Foundation = script.Parent.Parent

local Device = require(Foundation.Enums.Device)
local Theme = require(Foundation.Enums.Theme)

local getGeneratedRules = require(Foundation.Utility.getGeneratedRules)
local unwrap = require(Foundation.Utility.unwrap)
local Types = require(Foundation.Utility.Types.Types)

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