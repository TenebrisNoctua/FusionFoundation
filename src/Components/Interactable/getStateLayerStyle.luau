local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Types = require(Utility.Types.Types)
local themeProvider = require(Utility.themeProvider)

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
	stateLayer: StateLayer?,
	guiState: ControlState
): { Color3: Color3, Transparency: number }
	local theme = themeProvider()
	
	local colorNamespace = stateLayerModeToTokenNamespace(stateLayer and stateLayer.mode)
	local stateLayerState = guiStateToStateLayer(guiState)
	local stateLayerStyle = theme:GetTokenData(colorNamespace, "State", stateLayerState)

	return stateLayerStyle
end

return getStateLayerStyle
