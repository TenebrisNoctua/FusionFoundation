--!strict

-- Written by @TenebrisNoctua
-- Types for the Foundation.

--// Require the types

local Foundation = script.Parent.Parent.Parent
local Enums = Foundation.Enums

local FusionTypes = require(script.Parent.Fusion)
local StateLayerAffordance = require(Foundation.Enums.StateLayerAffordance)
local StateLayerMode = require(Foundation.Enums.StateLayerMode)
local CursorType = require(Foundation.Enums.CursorType)
local ControlState = require(Foundation.Enums.ControlState)
local ButtonVariant = require(Foundation.Enums.ButtonVariant)

--// General Use Types

type Set<T> = {[T]: any}

type StateObject<T> = FusionTypes.StateObject<T>
type CanBeState<T> = StateObject<T> | T

type StateLayerAffordance = StateLayerAffordance.StateLayerAffordance
type StateLayerMode = StateLayerMode.StateLayerMode
type CursorType = CursorType.CursorType
type ControlState = ControlState.ControlState
type ButtonVariant = ButtonVariant.ButtonVariant

--// Fusion Types

export type State<T> = StateObject<T>
export type Value<T> = FusionTypes.Value<T>
export type Computed<T> = FusionTypes.Computed<T>
export type UsedAs<T> = FusionTypes.UsedAs<T>
export type Tween<T> = FusionTypes.Tween<T>
export type Scope = FusionTypes.Scope<FusionTypes.Fusion>
export type Use = FusionTypes.Use
export type Child = FusionTypes.Child

export type Fusion = FusionTypes.Fusion

--// Util Types

export type DragInputProperties = {
	Instance: CanBeState<GuiObject>,
	Enabled: CanBeState<boolean>?,
	OnChange: ((newValue: Vector2) -> Vector2?)?,
	getUseFunction: () -> Use?,
	Value: UsedAs<Vector2>,
	Min: UsedAs<Vector2>,
	Max: UsedAs<Vector2>,
	Step: UsedAs<Vector2>,
}

export type ModifierInput = {
	Enabled: CanBeState<boolean>?,
	Hovering: CanBeState<boolean>?,
	Selected: CanBeState<boolean>?,
	Pressed: CanBeState<boolean>?,
	Otherwise: CanBeState<Enum.StudioStyleGuideModifier>?,
}

export type GetSelectedStateProperties = {
	Value: Value<any>?,
	Options: CanBeState<{any}>?,
	OnSelected: ((selectedOption: any, use: Use?) -> nil)?,
}

--// Foundation Types

export type StateChangedCallback = (newState: ControlState) -> ()

export type ActionProps = {
	onActivated: () -> (),
	variant: ButtonVariant?,
	text: string,
}

export type ResponsiveValue<T> = {
	xs: T,
	sm: T,
	md: T,
	lg: T,
	xl: T,
	xxl: T?,
}

export type NativeCommonProps = {
	AnchorPoint: UsedAs<Vector2>?,
	LayoutOrder: UsedAs<number>?,
	Position: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
}

export type NativeCallbackProps = {
	onAbsoluteSizeChanged: (instance: GuiObject) -> ()?,
	onAbsolutePositionChanged: (instance: GuiObject) -> ()?,
}

export type CommonProps = {
	testId: string?,
} & NativeCallbackProps & NativeCommonProps

export type FlexItem = {
	FlexMode: UsedAs<Enum.UIFlexMode>?,
	GrowRatio: UsedAs<number>?,
	ShrinkRatio: UsedAs<number>?,
	ItemLineAlignment: UsedAs<Enum.ItemLineAlignment>?,
}

export type SizeConstraint = {
	MinSize: UsedAs<Vector2?>,
	MaxSize: UsedAs<Vector2?>,
}

export type Slice = {
	center: Rect?,
	scale: number?,
}

export type Stroke = {
	Color: UsedAs<Color3>?,
	Thickness: UsedAs<number>?,
	Transparency: UsedAs<number>?,
	LineJoinMode: UsedAs<Enum.LineJoinMode>?,
}

export type ColorStyleValue = {
	-- Both values are optional because of token types, but should be required.
	Color3: Color3?,
	Transparency: number?,
}

export type ColorStyle = ColorStyleValue

export type ItemId = string | number
export type OnItemActivated = (id: ItemId) -> ()

export type StateLayer = {
	inset: boolean?,
	mode: StateLayerMode?,
	affordance: StateLayerAffordance?,
}

-- SelectionProps are broken out such that any Foundation component that is selectable
-- can have these properties without needing to include the entire Selection type
export type SelectionProps = {
	Selectable: UsedAs<boolean>?,
	NextSelectionUp: UsedAs<GuiObject>?,
	NextSelectionDown: UsedAs<GuiObject>?,
	NextSelectionLeft: UsedAs<GuiObject>?,
	NextSelectionRight: UsedAs<GuiObject>?,
}

-- Unfortunately SelectionProps can't be unioned with Selection
-- without anlyze becoming incredibly unhappy, so we just duplicate them.
export type Selection = {
	-- SelectionProps
	Selectable: UsedAs<boolean>?,
	NextSelectionUp: UsedAs<GuiObject>?,
	NextSelectionDown: UsedAs<GuiObject>?,
	NextSelectionLeft: UsedAs<GuiObject>?,
	NextSelectionRight: UsedAs<GuiObject>?,

	-- Additional Selection properties
	SelectionImageObject: UsedAs<GuiObject>?,
	SelectionOrder: UsedAs<number>?,
}

export type SelectionGroup = {
	SelectionBehaviorUp: UsedAs<Enum.SelectionBehavior>?,
	SelectionBehaviorDown: UsedAs<Enum.SelectionBehavior>?,
	SelectionBehaviorLeft: UsedAs<Enum.SelectionBehavior>?,
	SelectionBehaviorRight: UsedAs<Enum.SelectionBehavior>?,
}

export type Tags = string | { [string]: boolean }

export type BaseInteractableProps = {
	-- The state layer configuration for the element.
	stateLayer: StateLayer?,
	-- A callback that is called when the element is activated with the primary input object.
	onActivated: ((self: GuiObject, inputObject: InputObject, clickCount: number) -> ())?,
	-- A callback that is called when the element is activated with the secondary input object.
	-- Currently, this is only used for right-click. When SecondaryActivated is enabled, this will be used for left-click.
	onSecondaryActivated: ((self: GuiObject, inputObject: InputObject) -> ())?,
	-- A callback that is called when the state of the element changes.
	onStateChanged: StateChangedCallback?,
	-- Whether or not the element is disabled. This can't be a bindable due to handling state updates.
	isDisabled: boolean?,
}

export type BaseGuiObjectProps = {
	aspectRatio: AspectRatio?,
	cornerRadius: UsedAs<UDim>?,
	flexItem: FlexItem?,
	layout: ListLayout?,
	padding: Padding?,
	scale: UsedAs<number>?,
	sizeConstraint: SizeConstraint?,
	stroke: Stroke?,

	backgroundStyle: ColorStyle?,
	selection: Selection?,
	cursor: Cursor?,
	selectionGroup: (UsedAs<boolean> | SelectionGroup)?,

	AutoLocalize: UsedAs<boolean>?,
	AutomaticSize: UsedAs<Enum.AutomaticSize>?,
	BorderSizePixel: UsedAs<number>?,
	BorderColor3: UsedAs<Color3>?,
	BorderMode: UsedAs<Enum.BorderMode>?,
	ClipsDescendants: UsedAs<boolean>?,
	Rotation: UsedAs<number>?,
	Size: UsedAs<UDim2?>,
	SizeConstraint: UsedAs<Enum.SizeConstraint>?,

	scope: Scope,
	children: {Instance}?,
}

export type GuiObjectProps = BaseGuiObjectProps & BaseInteractableProps

export type AspectRatioTable = {
	AspectRatio: UsedAs<number>,
	AspectType: UsedAs<Enum.AspectType>?,
	DominantAxis: UsedAs<Enum.DominantAxis>?,
}

export type AspectRatio = UsedAs<number> | AspectRatioTable

export type PaddingTable = {
	top: UsedAs<UDim>?,
	bottom: UsedAs<UDim>?,
	left: UsedAs<UDim>?,
	right: UsedAs<UDim>?,
}

export type Padding = UsedAs<UDim>? | number | Vector2 | UDim2 | PaddingTable

export type ListLayout = {
	FillDirection: UsedAs<Enum.FillDirection>,
	ItemLineAlignment: UsedAs<Enum.ItemLineAlignment>?,
	HorizontalAlignment: UsedAs<Enum.HorizontalAlignment>?,
	HorizontalFlex: UsedAs<Enum.UIFlexAlignment>?,
	VerticalAlignment: UsedAs<Enum.VerticalAlignment>?,
	VerticalFlex: UsedAs<Enum.UIFlexAlignment>?,
	Padding: UsedAs<UDim>?,
	SortOrder: UsedAs<Enum.SortOrder>?,
	Wraps: UsedAs<boolean>?,
}

export type FontFaceTable = {
	Family: string,
	Weight: Enum.FontWeight,
	Style: Enum.FontStyle,
}

export type FontFace = FontFaceTable | UsedAs<Font> | Enum.Font

export type FontStyle = {
	Font: FontFace?,
	FontSize: number?,
	LineHeight: number?,
}

export type InternalTextInputRef = {
	getIsFocused: () -> boolean,
	focus: () -> (),
	releaseFocus: () -> (),
	setHover: (isHovering: boolean) -> (),
	getSelectionStart: () -> number,
	getCursorPosition: () -> number,
	setSelectionStart: (position: number) -> (),
	setCursorPosition: (position: number) -> (),
}

export type TextInputRef = {
	getIsFocused: () -> boolean,
	focus: () -> (),
	releaseFocus: () -> (),
}

export type PopoverAnchor = GuiObject | MeasurableObject

type MeasurableObjectImpl = {
	__index: MeasurableObjectImpl,
	GetPropertyChangedSignal: (self: MeasurableObject, propertyName: string) -> MeasurableObjectSignal<any>,
	SetPosition: (self: MeasurableObject, position: Vector2) -> (),
	SetSize: (self: MeasurableObject, size: Vector2) -> (),
}

type MeasurableObjectSignalConnection = {
	Disconnect: (self: MeasurableObjectSignalConnection) -> (),
}

export type MeasurableObjectSignal<T> = {
	Connect: (self: MeasurableObjectSignal<any>, callback: (value: T) -> ()) -> MeasurableObjectSignalConnection,
}

export type MeasurableObject = setmetatable<{ AbsolutePosition: Vector2, AbsoluteSize: Vector2 }, MeasurableObjectImpl>

export type CursorConfig = {
	radius: UDim?,
	offset: number?,
	borderWidth: number?,
}

export type Cursor = CursorType | CursorConfig

export type ViewProps = {
	GroupTransparency: Value<number>?,
} & GuiObjectProps & CommonProps

return nil