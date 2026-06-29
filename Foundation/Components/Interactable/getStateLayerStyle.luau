local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types.Types)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local ColorMode = require(Foundation.Enums.ColorMode)
local StateLayerMode = require(Foundation.Enums.StateLayerMode)
local ControlState = require(Foundation.Enums.ControlState)

type StateLayer = Types.StateLayer
type ColorMode = ColorMode.ColorMode
type StateLayerMode = StateLayerMode.StateLayerMode
type ControlState = ControlState.ControlState

function guiStateToStateLayer(guiState: ControlState): "Idle" | "Press" | "Hover"
	if guiState == ControlState.Pressed then
		return "Press"
	elseif guiState == ControlState.SelectedPressed then
		return "Press"
	elseif guiState == ControlState.Hover then
		return "Hover"
	end

	return "Idle"
end

function stateLayerModeToTokenNamespace(mode: StateLayerMode?)
	if mode == StateLayerMode.Default then
		return ColorMode.Color
	elseif mode == StateLayerMode.Inverse then
		return ColorMode.Inverse
	elseif mode == StateLayerMode.Light then
		return ColorMode.LightMode
	elseif mode == StateLayerMode.Dark then
		return ColorMode.DarkMode
	end
	-- Default to Color
	return ColorMode.Color
end

local function getStateLayerStyle(
	mode: StateLayerMode?,
	guiState: ControlState
): { Color3: Color3, Transparency: number }
	local theme = ThemeProvider()
	local colorNamespace = stateLayerModeToTokenNamespace(mode)
	local stateLayerState = guiStateToStateLayer(guiState)
	local stateLayerStyle = unwrap(theme.Tokens)[colorNamespace].State[stateLayerState]
	return stateLayerStyle
end

return getStateLayerStyle
