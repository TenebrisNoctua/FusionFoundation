--!nonstrict

local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Utility = Foundation.Utility
local TypesSource = Utility.Types

local Interactable = require(Foundation.Components.Interactable)

local stripProps = require(Utility.stripProps)
local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local withGuiObjectProps = require(Utility.withGuiObjectProps)
local GuiObjectChildren = require(Utility.GuiObjectChildren)
local Types = require(TypesSource.Types)
local FontScales = require(script.FontScales)

local COMPONENT_ONLY_PROPERTIES = {
	"textStyle",
	"fontStyle",
	"isDisabled",
	"onActivated",
	"onSecondaryActivated",
	"onStateChanged",
	"AutoButtonColor",
	"stateLayer",
	"selection"
}

local defaultProps = {
	AutoLocalize = false,
	AutoButtonColor = false,
	BorderSizePixel = 0,
	isDisabled = false,
}

local Children = Fusion.Children

type UsedAs<T> = Types.UsedAs<T>
type CanBeComputed<T> = (Types.Computed<T> | T)

type Scope = Types.Scope
type Use = Types.Use

type StateChangedCallback = Types.StateChangedCallback
type ColorStyle = Types.ColorStyle
type FontStyle = Types.FontStyle
type FontFaceTable = Types.FontFaceTable

export type TextProps = {
	textStyle: CanBeComputed<ColorStyle>?,
	fontStyle: CanBeComputed<FontStyle>?,

	RichText: UsedAs<boolean>?,
	Text: UsedAs<string>?,
	TextDirection: UsedAs<Enum.TextDirection>?,
	TextScaled: UsedAs<boolean>?,
	TextTruncate: UsedAs<Enum.TextTruncate>?,
	TextWrapped: UsedAs<boolean>?,
	TextXAlignment: UsedAs<Enum.TextXAlignment>?,
	TextYAlignment: UsedAs<Enum.TextYAlignment>?,
} & Types.GuiObjectProps & Types.CommonProps

return function(textProps: TextProps): UsedAs<TextLabel>
	local Scope = textProps.scope
	assert(Scope, "A scope has not been provided for the Text component.")
	
	local props = withDefaults(textProps, defaultProps)
	local isInteractable = props.onStateChanged ~= nil or props.onActivated ~= nil or props.onSecondaryActivated ~= nil
	
	local fontFace = Scope:Computed(function(use: Use) 
		local fontFaceProp = if props.fontStyle ~= nil then unwrap(props.fontStyle, use).Font else nil
		
		if typeof(fontFaceProp) == "table" and unwrap(fontFaceProp) == fontFaceProp then
			local fontFaceTyped = fontFaceProp :: FontFaceTable -- We're sure because it's not a value
			return Font.new(fontFaceTyped.Family, fontFaceTyped.Weight, fontFaceTyped.Style)
		elseif typeof(fontFaceProp) == "EnumItem" then
			return Font.fromEnum(fontFaceProp :: Enum.Font)
		else
			return fontFaceProp
		end
	end)
	
	local lineHeightPaddingOffsetState = Scope:Computed(function(use: Use) 
		local fontStyle = unwrap(props.fontStyle, use) :: FontStyle
		local fontFace = unwrap(fontFace, use)
		
		if
			fontStyle == nil
			or fontStyle.LineHeight == nil
			or fontStyle.FontSize == nil
			or fontFace == nil
		then
			return 0
		end

		local fontFamily = nil

		if unwrap(fontFace) ~= fontFace then
			local fontFaceState = fontFace :: UsedAs<Font>
			fontFamily = unwrap(fontFaceState).Family
		else
			fontFamily = fontFace.Family
		end

		local nominalScale = FontScales[fontFamily]

		if nominalScale == nil then
			return 0
		end

		local rawTextSize = fontStyle.FontSize / nominalScale
		local rawLineHeight = fontStyle.LineHeight * nominalScale
		local heightOffset = rawTextSize * rawLineHeight - fontStyle.FontSize
		local paddingOffset = heightOffset / 2
		return paddingOffset
	end)
	
	local lineHeightPaddingOffset: number = unwrap(lineHeightPaddingOffsetState)
	-- Only set line height padding if it's not already set to mimic styling behavior
	if props.padding == nil and lineHeightPaddingOffset ~= 0 then
		props.padding = Vector2.new(0, lineHeightPaddingOffset)
	end
	
	return Scope:Computed(function(use: Use, innerScope: Scope) 
		local fontStyle = unwrap(props.fontStyle, use)
		local engineComponent = if isInteractable then "TextButton" else "TextLabel"
		local engineComponentProps = withGuiObjectProps(props, {
			AutoButtonColor = if engineComponent == "TextButton" then props.AutoButtonColor else nil,
			FontFace = unwrap(fontFace, use),
			LineHeight = if fontStyle ~= nil then fontStyle.LineHeight else nil,
			RichText = props.RichText,
			Text = props.Text,
			TextColor3 = if props.textStyle then unwrap(props.textStyle, use).Color3 else nil,
			TextTransparency = if props.textStyle then unwrap(props.textStyle, use).Transparency else nil,
			TextDirection = props.TextDirection,
			TextScaled = props.TextScaled,
			TextSize = if fontStyle ~= nil then fontStyle.FontSize else nil,
			TextTruncate = props.TextTruncate,
			TextWrapped = props.TextWrapped,
			TextXAlignment = props.TextXAlignment,
			TextYAlignment = props.TextYAlignment
		})
		
		if isInteractable then
			local textComponentProps = {
				scope = innerScope,
				component = engineComponent,
				onActivated = props.onActivated,
				onSecondaryActivated = props.onSecondaryActivated,
				onStateChanged = props.onStateChanged,
				stateLayer = props.stateLayer,
				isDisabled = props.isDisabled,
				cursor = props.cursor,
				
				[Children] = GuiObjectChildren(props)
			}
			
			local combinedProps = Dash.union(engineComponentProps, textComponentProps)
			return innerScope:Hydrate(Interactable(combinedProps))(stripProps(props, COMPONENT_ONLY_PROPERTIES))
		else
			return innerScope:Hydrate(innerScope:New(engineComponent)(Dash.join(engineComponentProps, {[Children] = GuiObjectChildren(props)})))(stripProps(props, COMPONENT_ONLY_PROPERTIES))
		end
	end)
end