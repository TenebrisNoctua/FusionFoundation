local Foundation = script.Parent.Parent.Parent

local Providers = Foundation.Providers
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local PopoverArrow = require(script.Parent.PopoverArrow)
local PopoverContent = require(script.Parent.Content)
local PopoverShadow = require(script.Parent.PopoverShadow)
local getPanelPosition = require(script.getPanelPosition)
local useArrowPosition = require(script.useArrowPosition)
local usePanelSizing = require(script.usePanelSizing)
local usePluginAnchor = require(script.usePluginAnchor)

local View = require(Foundation.Components.View)

local ElevationLayer = require(Enums.ElevationLayer)
local PopoverAlign = require(Enums.PopoverAlign)
local PopoverSide = require(Enums.PopoverSide)
local Radius = require(Enums.Radius)

local ThemeProvider = require(Providers.ThemeProvider)
local ElevationProvider = require(Providers.ElevationProvider)
local useElevation = require(Providers.ElevationProvider.useElevation)
local PanelsProvider = require(Providers.PanelsProvider)
local usePanel = require(Providers.PanelsProvider.usePanel)

local unwrap = require(Utility.unwrap)
local isState = require(Utility.isState)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local StudioUri = require(Utility.Plugin.StudioUri)
local Types = require(Utility.Types)

local Constants = require(Foundation.Constants)
local ProviderTypes = require(Foundation.Providers.PanelsProvider.Types)

local SHADOW_SIZE = Constants.SHADOW_SIZE
local SHADOW_VERTICAL_OFFSET = 2

local defaultProps = {
	side = PopoverSide.Bottom,
	align = PopoverAlign.Center,
	hasArrow = true,
	radius = Radius.Medium,
}

local radiusToTag: { [Radius]: string } = {
	[Radius.Small] = "radius-small",
	[Radius.Medium] = "radius-medium",
	[Radius.Circle] = "radius-circle",
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

type StudioUri = StudioUri.StudioUri

type PopoverSide = PopoverSide.PopoverSide
type PopoverAlign = PopoverAlign.PopoverAlign
type Radius = Radius.Radius
type ElevationLayer = ElevationLayer.ElevationLayer

type PanelPosition = ProviderTypes.PanelPosition
type PanelHandle = ProviderTypes.PanelHandle
type PopoverContentProps = PopoverContent.PopoverContentProps

type ContentPluginProps = PopoverContentProps & {
	anchorUri: UsedAs<StudioUri?>?,
}

return function(contentProps: ContentPluginProps)
	local scope = contentProps.scope
	assert(scope, "A scope has not been provided for the ContentPlugin component.")
	
	local props = withDefaults(contentProps, defaultProps)
	
	local panelsProvider = PanelsProvider()
	local elevationProvider = ElevationProvider()
	local themeProvider = ThemeProvider()
	
	local tokens = unwrap(themeProvider.Tokens)
	local elevationToken = useElevation(scope, ElevationLayer.Popover, { stackAboveOwner = true })
	local depth = elevationProvider.getRelativeIndex(unwrap(elevationToken))
	
	local contentInstance = scope:Value(nil :: GuiObject?)
	
	if isState(props.gui) then
		scope:Observer(contentInstance):onChange(function()
			local currentView = unwrap(contentInstance)
			props.gui:set(currentView)
		end)
	end
	
	local arrowSide = tokens.Size.Size_200
	local arrowWidth = arrowSide * math.sqrt(2)
	local arrowHeight = arrowWidth / 2
	local backgroundStyle = unwrap(props.backgroundStyle) or tokens.Color.Surface.Surface_100
	
	local sidePosition = scope:Computed(function(use: Use)
		local side = unwrap(props.side, use) or PopoverSide.Bottom
		if type(side) == "table" then
			return side.position
		end
		return side
	end)
	
	local alignValue = scope:Computed(function(use: Use)
		local align = unwrap(props.align, use) or PopoverAlign.Center
		local alignPosition = if type(align) == "table" then align.position else align
		if alignPosition == PopoverAlign.Center then
			return 0.5
		elseif alignPosition == PopoverAlign.End then
			return 1
		end
		return 0
	end)
	
	local pluginAnchor = usePluginAnchor(scope, props.anchor, props.anchorUri)
	
	local hasArrow = scope:Computed(function(use: Use)
		local isVirtual = unwrap(pluginAnchor.isVirtual, use)
		if isVirtual then return false end
		return unwrap(props.hasArrow, use)
	end)
	
	local anchorInstance = scope:Computed(function(use: Use)
		local isVirtual = unwrap(pluginAnchor.isVirtual, use)
		if isVirtual then return nil end
		local a = props.anchor and unwrap(props.anchor, use) or nil
		if typeof(a) ~= "Instance" then return nil end
		return a :: GuiBase2d?
	end)
	
	local position = scope:Computed(function(use: Use)
		local resolvedSide = unwrap(props.side, use) or PopoverSide.Bottom
		local resolvedAlign = unwrap(props.align, use) or PopoverAlign.Start
		local resolvedHasArrow = unwrap(hasArrow, use)
		return getPanelPosition(
			resolvedSide,
			resolvedAlign,
			nil,
			SHADOW_SIZE,
			if resolvedHasArrow then arrowHeight else 0
		)
	end)
	
	local function registerPanelAsync(
		anchorUri: StudioUri,
		panelPosition: PanelPosition,
		onClose: () -> (),
		panelDepth: number?
	)
		return panelsProvider:registerPopoverAsync(anchorUri, panelPosition, onClose, panelDepth)
	end
	
	-- This can be converted back to Logger Utility if Lumberyak is added as a package.
	if not props.onPressedOutside then
		warn(
			"PopoverContent rendered in a plugin context without onPressedOutside. "
				.. "In Studio, the QWidget popup will close on focus loss, but the parent's "
				.. "isOpen state will not update. Provide onPressedOutside to stay in sync."
		)
	end
	
	local function onPanelClose()
		if props.onPressedOutside then
			props.onPressedOutside()
		end
	end
	
	local panelDepth = if depth ~= nil then depth else 0

	local panel = usePanel({
		scope = scope,
		isOpen = scope:Computed(function(use: Use)
			local isOpen = unwrap(props.isOpen, use)
			local isReady = unwrap(pluginAnchor.isReady, use)
			return isOpen and isReady
		end),
		onClose = onPanelClose,
		anchorUri = pluginAnchor.uri,
		registerPanelAsync = registerPanelAsync,
		position = position,
		depth = panelDepth,
	})
	
	local dummyContainer = scope:New "Frame" {
		Name = "PopoverDummyContainer",
		Visible = false,
		BackgroundTransparency = 1,
	}

	local panelContainer = scope:Computed(function(use: Use)
		local currentPanel = unwrap(panel, use)
		if currentPanel then
			return currentPanel.container
		end
		return dummyContainer
	end)
	
	local contentVisible = scope:Computed(function(use: Use)
		local currentPanel = unwrap(panel, use)
		return currentPanel ~= nil
	end)

	local arrowHeightState = scope:Computed(function(use: Use)
		return if unwrap(hasArrow, use) then arrowHeight else 0
	end)

	local popoverSize, contentSize = usePanelSizing(
		scope,
		props.side,
		props.align,
		contentInstance,
		arrowHeightState,
		panel
	)

	local arrowPosition = useArrowPosition(
		scope,
		contentSize,
		sidePosition,
		props.radius,
		alignValue,
		arrowHeight,
		anchorInstance
	)
	
	local children = props.children

	table.insert(children, scope:New "StyleLink" {
		StyleSheet = themeProvider.RegistryStyleSheet
	})

	local contentView = View {
		Name = "ContentView",
		scope = scope,
		Parent = panelContainer,
		Visible = contentVisible,
		Position = UDim2.fromOffset(SHADOW_SIZE, SHADOW_SIZE),
		backgroundStyle = backgroundStyle,
		ZIndex = 3,
		tag = scope:Computed(function(use: Use)
			return `auto-xy {radiusToTag[unwrap(props.radius, use)]}`
		end),
		children = children
	}

	contentInstance:set(unwrap(contentView))

	local contentProps = withCommonProps(props, {
		Name = "Content",
		scope = scope,
		Parent = panelContainer,
		Size = popoverSize,
		tag = "size-full",
		children = {
			PopoverShadow {
				scope = scope,
				contentSize = contentSize,
				position = UDim2.fromOffset(SHADOW_SIZE / 2, SHADOW_SIZE / 2 + SHADOW_VERTICAL_OFFSET),
				ZIndex = 1,
			},
			PopoverArrow {
				scope = scope,
				size = arrowSide,
				position = arrowPosition,
				ZIndex = 2,
				backgroundStyle = backgroundStyle,
				Visible = hasArrow,
			},
			scope:New "StyleLink" {
				StyleSheet = themeProvider.RegistryStyleSheet,
			},
		}
	})
	
	contentProps.Visible = contentVisible
	return View(contentProps)
end