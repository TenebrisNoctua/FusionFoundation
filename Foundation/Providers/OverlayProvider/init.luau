-- Written by @TenebrisNoctua
-- Provides an overlay ScreenGui for rendering floating content (popovers, dialogs, etc.).

local Foundation = script.Parent.Parent
local Utility = Foundation.Utility

local useKeyboardAwareSize = require(script.useKeyboardAwareSize)
local ThemeProvider = require(script.Parent.ThemeProvider)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)
local Wrappers = require(Utility.Wrappers)
local isPluginSecurity = require(Utility.isPluginSecurity)

local CoreGui = Wrappers.Services.CoreGui
local RunService = Wrappers.Services.RunService
local Players = Wrappers.Services.Players

local Constants = require(Foundation.Constants)

local FoundationOverlayKeyboardAwareness = true
local FoundationOverlayKeyboardAwarenessHardened = true
local FoundationOverlayDisplayOrder = true

local FoundationOverlayDisplayOrderDefault = Constants.MAX_LAYOUT_ORDER - 1

local overlayProvider = {
	instance = nil :: GuiBase2d?,
	screen = nil :: GuiBase2d?,
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope

export type OverlayProviderProps = {
	scope: Scope,
	gui: UsedAs<GuiBase2d>? | any,
	DisplayOrder: UsedAs<number>?
}

type overlayProvider = typeof(overlayProvider)

--// Main Functions

local function getMainGui(): Instance?
	if isPluginSecurity() then
		return CoreGui
	end

	if not RunService:IsClient() or not Players.LocalPlayer or not RunService:IsRunning() then
		return nil
	end

	return Players.LocalPlayer:FindFirstChild("PlayerGui")
end

local defaultDisplayOrder = if FoundationOverlayDisplayOrder
	then FoundationOverlayDisplayOrderDefault
	else Constants.MAX_LAYOUT_ORDER - 1

return function(props: OverlayProviderProps?): (overlayProvider, () -> ()?)
	if overlayProvider.instance then return overlayProvider end
	assert(props.scope, "OverlayProvider has not been provided a scope!")
	assert(props.gui, "OverlayProvider has not been provided a GuiObject!")

	local scope: Scope = props and props.scope
	local theme = ThemeProvider()
	local gui = props and unwrap(props.gui)
	local displayOrder = (props and unwrap(props.DisplayOrder)) or defaultDisplayOrder

	if gui then
		overlayProvider.instance = gui
		overlayProvider.screen = gui
		return overlayProvider
	end

	local mainGui = getMainGui()
	if not mainGui then
		return overlayProvider
	end
	
	local screenGui = scope:New "ScreenGui" {
		Enabled = true,
		DisplayOrder = displayOrder,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		SafeAreaCompatibility = Enum.SafeAreaCompatibility.None,
		ClipToDeviceSafeArea = false,
		Parent = mainGui,
	}
	
	local safeAreaFrame = scope:New "Frame" {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Parent = screenGui
	}
	
	local foundationStyleLink = scope:New "StyleLink" {
		StyleSheet = theme.RegistryStyleSheet,
		Parent = screenGui
	}
	
	local cleanup: () -> ()

	if FoundationOverlayKeyboardAwareness and scope then
		local screen = if FoundationOverlayKeyboardAwarenessHardened then screenGui else safeAreaFrame
		local safeAreaSize = useKeyboardAwareSize(scope, screen)
		cleanup = scope:Observer(safeAreaSize):onChange(function()
			safeAreaFrame.Size = unwrap(safeAreaSize)
		end)
	end

	overlayProvider.screen = screenGui
	overlayProvider.instance = safeAreaFrame

	return overlayProvider, function() 
		screenGui:Destroy()
		safeAreaFrame:Destroy()
		foundationStyleLink:Destroy()
		
		overlayProvider.screen = nil
		overlayProvider.instance = nil
		
		if cleanup then pcall(cleanup) end
	end
end