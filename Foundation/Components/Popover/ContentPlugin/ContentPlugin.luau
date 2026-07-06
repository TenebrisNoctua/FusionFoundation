local Foundation = script.Parent.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Providers = Foundation.Providers
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local PopoverArrow = require(script.Parent.Parent.PopoverArrow)
local PopoverContent = require(script.Parent.Parent.Content)
local PopoverShadow = require(script.Parent.Parent.PopoverShadow)
local getPanelPosition = require(script.Parent.getPanelPosition)
local useArrowPosition = require(script.Parent.useArrowPosition)
local usePanelSizing = require(script.Parent.usePanelSizing)

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
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local stripProps = require(Utility.stripProps)
local StudioUri = require(Utility.Plugin.StudioUri)
local Types = require(Utility.Types)

local Constants = require(Foundation.Constants)
local ProviderTypes = require(Foundation.Providers.PanelsProvider.Types)

local Children = Fusion.Children

local FoundationPopoverPluginDepthPool = true

local SHADOW_SIZE = Constants.SHADOW_SIZE
local SHADOW_VERTICAL_OFFSET = 2

local COMPONENT_ONLY_PROPERTIES = {
	"side",
	"align",
	"hasArrow",
	"onPressedOutside",
	"radius",
	"isOpen",
	"anchor",
	"gui",
	"parentPopoverId",
}

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
	local themeProvider = ThemeProvider()
	local tokens = unwrap(themeProvider.Tokens)

	local panelsProvider = PanelsProvider()
	local elevationProvider = ElevationProvider()

	local elevationToken = useElevation(scope, ElevationLayer.Popover, { stackAboveOwner = true })
	local depth = elevationProvider.getRelativeIndex(unwrap(elevationToken))
	local contentInstance = scope:Value(nil :: GuiObject?)

	if props.gui then
		scope:Observer(contentInstance):onChange(function()
			local currentView = unwrap(contentInstance)
			if typeof(props.gui) == "table" and (props.gui :: any).set then
				(props.gui :: any):set(currentView)
			end
		end)
	end

	local arrowSide = tokens.Size.Size_200
	local arrowWidth = arrowSide * math.sqrt(2)
	local arrowHeight = arrowWidth / 2
	local backgroundStyle = unwrap(props.backgroundStyle) or tokens.Color.Surface.Surface_100

	local currentSide = unwrap(props.side) or PopoverSide.Bottom
	local sidePosition: PopoverSide = if type(currentSide) == "table"
		then currentSide.position
		else currentSide

	local currentAlign = unwrap(props.align) or PopoverAlign.Center
	local alignPosition = if type(currentAlign) == "table"
		then currentAlign.position
		else currentAlign

	local alignValue = 0
	if alignPosition == PopoverAlign.Center then
		alignValue = 0.5
	elseif alignPosition == PopoverAlign.End then
		alignValue = 1
	end

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

	local panelDepth = if FoundationPopoverPluginDepthPool
		then (if depth ~= nil then depth else 0)
		else depth

	local panel = usePanel(scope, {
		isOpen = props.isOpen,
		onClose = onPanelClose,
		anchorUri = anchor.uri,
		registerPanelAsync = registerPanelAsync,
		position = position,
		depth = panelDepth,
		parentPopoverId = if FoundationPopoverPluginDepthPool then props.parentPopoverId else nil,
	})

	local currentHasArrow = unwrap(props.hasArrow)
	local popoverSize, contentSize = usePanelSizing(
		scope,
		props.side,
		props.align,
		contentInstance,
		if currentHasArrow then arrowHeight else 0,
		panel
	)

	local currentRadius = unwrap(props.radius)
	local currentAnchor = unwrap(props.anchor)
	local arrowPosition = useArrowPosition(
		scope,
		contentSize,
		sidePosition,
		currentRadius,
		alignValue,
		arrowHeight,
		currentAnchor
	)

	return scope:Computed(function(use: Use, innerScope: Scope)
		local currentPanel = unwrap(panel, use)
		if not currentPanel then return end

		local currentPopoverSize = unwrap(popoverSize, use)
		local currentContentSize = unwrap(contentSize, use)
		local currentArrowPos = unwrap(arrowPosition, use)
		local shouldShowArrow = unwrap(props.hasArrow, use)
		local resolvedRadius = unwrap(props.radius, use)

		local contentView = View {
			scope = innerScope,
			Position = UDim2.fromOffset(SHADOW_SIZE, SHADOW_SIZE),
			backgroundStyle = backgroundStyle,
			ZIndex = 3,
			tag = `auto-xy {radiusToTag[resolvedRadius]}`,
			children = props.children,
		}

		local instance = unwrap(contentView)
		if instance and typeof(instance) == "Instance" then
			contentInstance:set(instance)
		end

		local containerViewProps = withCommonProps(props, {
			scope = innerScope,
			Parent = currentPanel.container,
			Size = currentPopoverSize,
			tag = "size-full",
			children = {
				Shadow = PopoverShadow {
					scope = innerScope,
					contentSize = contentSize,
					position = UDim2.fromOffset(SHADOW_SIZE / 2, SHADOW_SIZE / 2 + SHADOW_VERTICAL_OFFSET),
					ZIndex = 1,
				},
				Arrow = if shouldShowArrow
					then PopoverArrow {
						scope = innerScope,
						size = arrowSide,
						position = currentArrowPos,
						ZIndex = 2,
						backgroundStyle = backgroundStyle,
					}
					else nil,
				Content = contentView,
			},
		})

		return View(containerViewProps)
	end)
end