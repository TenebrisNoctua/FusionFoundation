local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Tag = Fusion.Tag

local Utility = Foundation.Utility
local withCommonProps = require(Utility.withCommonProps)
local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types.Types)

type Value<T> = Types.Value<T>
type CanBeValue<T> = (Value<T> | T)
type Computed<T> = Types.Computed<T>
type Scope = Types.Scope
type Use = Types.Use

type GuiObjectProps = Types.GuiObjectProps
type CommonProps = Types.CommonProps
type NativeCommonProps = Types.NativeCommonProps
type SelectionGroup = Types.SelectionGroup

-- Since GuiObjectProps is in a different form than what's actually applied, we need to manually define the applied props
type AppliedGuiObjectProps = {
	AnchorPoint: CanBeValue<Vector2>?,
	AutoLocalize: CanBeValue<boolean>?,
	AutomaticSize: CanBeValue<Enum.AutomaticSize>?,
	BackgroundColor3: CanBeValue<Color3>?,
	BackgroundTransparency: CanBeValue<number>?,
	BorderSizePixel: CanBeValue<number>?,
	BorderColor3: CanBeValue<Color3>?,
	BorderMode: CanBeValue<Enum.BorderMode>?,
	ClipsDescendants: CanBeValue<boolean>?,
	Rotation: CanBeValue<number>?,
	Selectable: CanBeValue<boolean>?,
	SelectionImageObject: CanBeValue<GuiObject>?,
	SelectionOrder: CanBeValue<number>?,
	SizeConstraint: CanBeValue<Enum.SizeConstraint>?,
	NextSelectionDown: CanBeValue<GuiObject>?,
	NextSelectionLeft: CanBeValue<GuiObject>?,
	NextSelectionRight: CanBeValue<GuiObject>?,
	NextSelectionUp: CanBeValue<GuiObject>?,
	Size: CanBeValue<UDim2>?,
} & NativeCommonProps

local function getBackgroundStylePropsStates(scope: Scope, backgroundStyle: Computed<any>)
	local color3 = scope:Computed(function(use: Use) 
		local styleData = unwrap(backgroundStyle, use)
		return styleData.Color3
	end)
	local transparency = scope:Computed(function(use: Use) 
		local styleData = unwrap(backgroundStyle, use)
		return styleData.Transparency
	end)
	return {Color3 = color3, Transparency = transparency}
end

local function withGuiObjectProps<T>(props: GuiObjectProps & CommonProps, baseProps: T | any)
	if type(baseProps) == "table" then
		baseProps.AutoLocalize = props.AutoLocalize
		baseProps.AutomaticSize = props.AutomaticSize
		
		if props.backgroundStyle then 
			local styleProps = if unwrap(props.backgroundStyle) ~= props.backgroundStyle then 
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
	
	if props.tag then
		if typeof(props.tag) == "table" then
			for stringVal, _ in props.tag do
				for str in string.gmatch(stringVal or "", "%S+") do
					baseProps[Tag(str)] = true
				end
			end
		elseif typeof(props.tag) == "string" then
			for str in string.gmatch(props.tag or "", "%S+") do
				baseProps[Tag(str)] = true
			end
		end
	end
	
	local fullProps = withCommonProps(props, baseProps) :: any -- Required since constrained generics are not yet supported
	return fullProps :: T & AppliedGuiObjectProps
end

return withGuiObjectProps
