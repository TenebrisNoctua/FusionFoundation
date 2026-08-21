local Foundation = script.Parent.Parent.Parent

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local ControlState = require(Enums.ControlState)
local ColorNamespace = require(Enums.ColorNamespace)
local StateLayerMode = require(Enums.StateLayerMode)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

type StateLayer = Types.StateLayer
type ColorNamespace = ColorNamespace.ColorNamespace
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
		return ColorNamespace.Color
	elseif mode == StateLayerMode.Inverse then
		return ColorNamespace.Inverse
	elseif mode == StateLayerMode.Light then
		return ColorNamespace.LightMode
	elseif mode == StateLayerMode.Dark then
		return ColorNamespace.DarkMode
	end
	-- Default to Color
	return ColorNamespace.Color
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
