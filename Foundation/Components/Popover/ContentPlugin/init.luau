local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Providers = Foundation.Providers
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local PopoverArrow = require(script.Parent.PopoverArrow)
local PopoverContent = require(script.Parent.Content)
local PopoverShadow = require(script.Parent.PopoverShadow)
local getPanelPosition = require(script.getPanelPosition)
local useArrowPosition = require(script.useArrowPosition)
local usePanelSizing = require(script.usePanelSizing)

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
local useUniqueWidget = require(Providers.WidgetsProvider.useUniqueWidget)

local unwrap = require(Utility.unwrap)
local isState = require(Utility.isState)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local StudioUri = require(Utility.Plugin.StudioUri)
local Types = require(Utility.Types)

local Constants = require(Foundation.Constants)
local ProviderTypes = require(Foundation.Providers.PanelsProvider.Types)

local FoundationPopoverPluginDepthPool = true

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
	parentPopoverId: UsedAs<string?>?
}

return function(contentProps: ContentPluginProps)
	local scope = contentProps.scope
	assert(scope, "A scope has not been provided for the ContentPlugin component.")
	
	local props = withDefaults(contentProps, defaultProps)
	
	local panelsProvider = PanelsProvider()
	local elevationProvider = ElevationProvider()
	local themeProvider = ThemeProvider()
	
	local tokens = unwrap(themeProvider.Tokens)
	local depth, elevationToken
	
	if FoundationPopoverPluginDepthPool then
		elevationToken = useElevation(scope, ElevationLayer.Popover, { stackAboveOwner = true })
		depth = elevationProvider.getRelativeIndex(unwrap(elevationToken))
	end
	
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
	
	local anchor = useUniqueWidget(scope, {
		gui = props.anchor
	})
	
	local position = scope:Computed(function(use: Use)
		local resolvedSide = unwrap(props.side, use) or PopoverSide.Bottom
		local resolvedAlign = unwrap(props.align, use) or PopoverAlign.Start
		local resolvedHasArrow = unwrap(props.hasArrow, use)
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
		local parentId = if FoundationPopoverPluginDepthPool then props.parentPopoverId else nil
		return panelsProvider:registerPopoverAsync(anchorUri, panelPosition, onClose, panelDepth, parentId)
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
	
	local panelDepth = if FoundationPopoverPluginDepthPool then (if depth ~= nil then depth else 0) else depth
	local panel = usePanel({
		scope = scope,
		isOpen = props.isOpen,
		onClose = onPanelClose,
		anchorUri = anchor.uri,
		anchorGui = props.anchor,
		registerPanelAsync = registerPanelAsync,
		position = position,
		depth = panelDepth,
		parentPopoverId = if FoundationPopoverPluginDepthPool then props.parentPopoverId else nil,
	})

	local arrowHeightState = scope:Computed(function(use: Use)
		return if unwrap(props.hasArrow, use) then arrowHeight else 0
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
		props.anchor
	)
	
	local contentViewParent = scope:Value(nil :: Instance?)
	local children = props.children
	
	table.insert(children, scope:New "StyleLink" {
		StyleSheet = themeProvider.RegistryStyleSheet
	})

	local contentView = View {
		Name = "ContentView",
		scope = scope,
		Parent = contentViewParent,
		Position = UDim2.fromOffset(SHADOW_SIZE, SHADOW_SIZE),
		backgroundStyle = backgroundStyle,
		ZIndex = 3,
		tag = scope:Computed(function(use: Use)
			return `auto-xy {radiusToTag[unwrap(props.radius, use)]}`
		end),
		children = children
	}

	contentInstance:set(unwrap(contentView))

	return scope:Computed(function(use: Use, innerScope: Scope)
		local currentPanel = unwrap(panel, use)
		if not currentPanel then
			contentViewParent:set(nil)
			return
		end

		local shouldShowArrow = unwrap(props.hasArrow, use)
		contentViewParent:set(currentPanel.container)

		unwrap(View(withCommonProps(props, {
			Name = "Content",
			scope = innerScope,
			Parent = currentPanel.container,
			Size = popoverSize,
			tag = "size-full",
			children = {
				PopoverShadow {
					scope = innerScope,
					contentSize = contentSize,
					position = UDim2.fromOffset(SHADOW_SIZE / 2, SHADOW_SIZE / 2 + SHADOW_VERTICAL_OFFSET),
					ZIndex = 1,
				},
				if shouldShowArrow
					then PopoverArrow {
						scope = innerScope,
						size = arrowSide,
						position = arrowPosition,
						ZIndex = 2,
						backgroundStyle = backgroundStyle,
					}
					else nil,

				innerScope:New "StyleLink" {
					StyleSheet = themeProvider.RegistryStyleSheet
				},
			}
		})))
	end)
end