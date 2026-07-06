-- Written by @TenebrisNoctua
-- Tracks the on-screen keyboard position and adjusts the safe area size accordingly.

local Foundation = script.Parent.Parent.Parent
local Utility = Foundation.Utility

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)
local Wrappers = require(Utility.Wrappers)

local GuiService = Wrappers.Services.GuiService
local UserInputService = Wrappers.Services.UserInputService

local FoundationOverlayKeyboardAwarenessHardened = true

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope

return function(scope: Scope, screen: GuiBase2d?): UsedAs<UDim2>
	local safeAreaSize = scope:Value(UDim2.fromScale(1, 1))

	local function updateSafeAreaSize()
		if not screen then return end

		if not UserInputService.OnScreenKeyboardVisible then
			local current = unwrap(safeAreaSize)
			if current ~= UDim2.fromScale(1, 1) then
				safeAreaSize:set(UDim2.fromScale(1, 1))
			end
			return
		end

		local tlInset = GuiService:GetGuiInset()
		local keyboardPositionY = UserInputService.OnScreenKeyboardPosition.Y - tlInset.Y

		local screenSize = screen.AbsoluteSize
		local screenPosition = screen.AbsolutePosition

		local bottomY = screenPosition.Y + screenSize.Y
		local yAdjustment = bottomY - keyboardPositionY

		if FoundationOverlayKeyboardAwarenessHardened then
			local newSafeAreaSize = UDim2.new(1, 0, 1, -yAdjustment)
			if unwrap(safeAreaSize) ~= newSafeAreaSize then
				safeAreaSize:set(newSafeAreaSize)
			end
		else
			safeAreaSize:set(unwrap(safeAreaSize) - UDim2.fromOffset(0, yAdjustment))
		end
	end

	updateSafeAreaSize()

	local onScreenKeyboardVisible = UserInputService:GetPropertyChangedSignal("OnScreenKeyboardVisible")
		:Connect(updateSafeAreaSize)
	local onScreenKeyboardPosition = UserInputService:GetPropertyChangedSignal("OnScreenKeyboardPosition")
		:Connect(updateSafeAreaSize)
	local onScreenAbsoluteSize
	if FoundationOverlayKeyboardAwarenessHardened and screen then
		onScreenAbsoluteSize = screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSafeAreaSize)
	end

	table.insert(scope, function()
		onScreenKeyboardVisible:Disconnect()
		onScreenKeyboardPosition:Disconnect()
		if onScreenAbsoluteSize then
			onScreenAbsoluteSize:Disconnect()
		end
	end)

	return safeAreaSize
end