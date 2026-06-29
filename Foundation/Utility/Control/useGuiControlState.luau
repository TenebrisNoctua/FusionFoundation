local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local ControlState = require(Enums.ControlState)
local ControlStateEvent = require(Enums.ControlStateEvent)
local Types = require(Utility.Types.Types)
local unwrap = require(Utility.unwrap)

local guiStateMapper: { [Enum.GuiState]: ControlState } = {
	[Enum.GuiState.Idle] = ControlState.Default,
	[Enum.GuiState.Hover] = ControlState.Hover,
	[Enum.GuiState.Press] = ControlState.Pressed,
	[Enum.GuiState.NonInteractable] = ControlState.Disabled,
}

local OnEvent = Fusion.OnEvent

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope

type ControlState = ControlState.ControlState
type ControlStateEvent = ControlStateEvent.ControlStateEvent
type StateChangedCallback = Types.StateChangedCallback

local function useGuiControlState(scope: Scope, guiObjectRef: UsedAs<GuiObject?>, onStateChanged: StateChangedCallback)
	local isSelected = scope:Value(false)
	local currentControlState = scope:Value(ControlState.Initialize)
	local connections: { RBXScriptConnection } = {}

	local function onControlStateChanged(newState: ControlState)
		local oldState = unwrap(currentControlState)
		
		if unwrap(isSelected) then
			if newState == ControlState.Default or newState == ControlState.Hover then
				newState = ControlState.Selected
			elseif newState == ControlState.Pressed then
				newState = ControlState.SelectedPressed
			end
		end

		if oldState == newState then
			return
		end

		currentControlState:set(newState)

		if onStateChanged ~= nil then
			onStateChanged(newState)
		end
	end

	local function onRefChange(instance: GuiObject)
		if not instance then return end
		onControlStateChanged(guiStateMapper[instance.GuiState])
	 	
		table.insert(
			connections,
			instance:GetPropertyChangedSignal("GuiState"):Connect(function()
				local controlState: ControlState = guiStateMapper[instance.GuiState]
				onControlStateChanged(controlState)
			end)
		)
  		
		-- Selected state is not part of GuiState, so we need to handle it separately with SelectionGained and SelectionLost
		table.insert(
			connections,
			instance.SelectionGained:Connect(function()
				isSelected.current = true
				onControlStateChanged(unwrap(currentControlState))
			end)
		)
		
		table.insert(
			connections,
			instance.SelectionLost:Connect(function()
				isSelected.current = false
				onControlStateChanged(unwrap(currentControlState))
			end)
		) 	
	end

	return scope:Observer(guiObjectRef):onChange(function()
		for _, connection in connections do
			connection:Disconnect()
		end
		table.clear(connections)
		return onRefChange(unwrap(guiObjectRef))	
	end)
end

return useGuiControlState
