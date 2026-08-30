local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Utility = Foundation.Utility

local unwrap = require(Utility.unwrap)
local isState = require(Utility.isState)
local getFormattedTags = require(Utility.getFormattedTags)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)

local OnChange = Fusion.OnChange
local Tags = Fusion.Tags

local DEFAULT_COLOR = Color3.fromRGB(163, 165, 162)
local DEFAULT_TRANSPARENCY = 1

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type GuiObjectProps = Types.GuiObjectProps
type CommonProps = Types.CommonProps
type NativeCommonProps = Types.NativeCommonProps
type SelectionGroup = Types.SelectionGroup

-- Since GuiObjectProps is in a different form than what's actually applied, we need to manually define the applied props
type AppliedGuiObjectProps = {
	AnchorPoint: UsedAs<Vector2>?,
	AutoLocalize: UsedAs<boolean>?,
	AutomaticSize: UsedAs<Enum.AutomaticSize>?,
	BackgroundColor3: UsedAs<Color3>?,
	BackgroundTransparency: UsedAs<number>?,
	BorderSizePixel: UsedAs<number>?,
	BorderColor3: UsedAs<Color3>?,
	BorderMode: UsedAs<Enum.BorderMode>?,
	ClipsDescendants: UsedAs<boolean>?,
	Rotation: UsedAs<number>?,
	Selectable: UsedAs<boolean>?,
	SelectionImageObject: UsedAs<GuiObject>?,
	SelectionOrder: UsedAs<number>?,
	SizeConstraint: UsedAs<Enum.SizeConstraint>?,
	NextSelectionDown: UsedAs<GuiObject>?,
	NextSelectionLeft: UsedAs<GuiObject>?,
	NextSelectionRight: UsedAs<GuiObject>?,
	NextSelectionUp: UsedAs<GuiObject>?,
	Size: UsedAs<UDim2>?,
} & NativeCommonProps

local function getBackgroundStylePropsStates(scope: Scope, backgroundStyle: UsedAs<{Color3: Color3, Transparency: number}>)
	local color3 = scope:Computed(function(use: Use) 
		local styleData = unwrap(backgroundStyle, use)
		if not styleData then return DEFAULT_COLOR end
		return styleData.Color3
	end)
	local transparency = scope:Computed(function(use: Use) 
		local styleData = unwrap(backgroundStyle, use)
		if not styleData then return DEFAULT_TRANSPARENCY end
		return styleData.Transparency
	end)
	return {Color3 = color3, Transparency = transparency}
end

local function withGuiObjectProps<T>(props: GuiObjectProps & CommonProps, baseProps: T | any)
	if type(baseProps) == "table" then
		baseProps.AutoLocalize = props.AutoLocalize
		baseProps.AutomaticSize = props.AutomaticSize
		
		if props.backgroundStyle then 
			local styleProps = if isState(props.backgroundStyle) then 
				getBackgroundStylePropsStates(props.scope, props.backgroundStyle) else props.backgroundStyle
			
			baseProps.BackgroundColor3 = styleProps.Color3
			baseProps.BackgroundTransparency = styleProps.Transparency 
		end
		
		baseProps.BorderSizePixel = props.BorderSizePixel
		baseProps.BorderColor3 = props.BorderColor3
		baseProps.BorderMode = props.BorderMode
		baseProps.ClipsDescendants = props.ClipsDescendants
		baseProps.Rotation = props.Rotation
		baseProps.SizeConstraint = props.SizeConstraint

		if props.selection then
			baseProps.Selectable = props.selection.Selectable
			baseProps.SelectionImageObject = props.selection.SelectionImageObject
			baseProps.SelectionOrder = props.selection.SelectionOrder
			baseProps.NextSelectionDown = props.selection.NextSelectionDown
			baseProps.NextSelectionLeft = props.selection.NextSelectionLeft
			baseProps.NextSelectionRight = props.selection.NextSelectionRight
			baseProps.NextSelectionUp = props.selection.NextSelectionUp
		end

		if props.selectionGroup ~= nil then
			if type(props.selectionGroup) == "boolean" then
				baseProps.SelectionGroup = props.selectionGroup
			else
				local selectionGroup = props.selectionGroup :: SelectionGroup
				baseProps.SelectionGroup = true
				baseProps.SelectionBehaviorUp = selectionGroup.SelectionBehaviorUp
				baseProps.SelectionBehaviorDown = selectionGroup.SelectionBehaviorDown
				baseProps.SelectionBehaviorLeft = selectionGroup.SelectionBehaviorLeft
				baseProps.SelectionBehaviorRight = selectionGroup.SelectionBehaviorRight
			end
		end

		baseProps.Size = props.Size
	end
	
	local tagProp = props.tag
	if tagProp then
		if typeof(tagProp) == "table" and not isState(tagProp) then
			baseProps[Tags] = getFormattedTags(tagProp)
		else
			baseProps[Tags] = tagProp
		end
	end
	
	local fullProps = withCommonProps(props, baseProps) :: any -- Required since constrained generics are not yet supported
	
	-- Replace incompatible Common Props
	fullProps[OnChange "AbsoluteSize"] = fullProps.onAbsoluteSizeChanged
	fullProps.onAbsoluteSizeChanged = nil
	fullProps[OnChange "AbsolutePosition"] = fullProps.onAbsolutePositionChanged
	fullProps.onAbsolutePositionChanged = nil
	
	return fullProps :: T & AppliedGuiObjectProps
end

return withGuiObjectProps
