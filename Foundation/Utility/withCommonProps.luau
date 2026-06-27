local Types = require(script.Parent.Types.Types)

type CommonProps = Types.CommonProps

local function withCommonProps<T>(props: CommonProps, baseProps: T | any)
	if type(baseProps) == "table" then
		baseProps.AnchorPoint = props.AnchorPoint
		baseProps.LayoutOrder = props.LayoutOrder
		baseProps.Position = props.Position
		baseProps.Visible = props.Visible
		baseProps.ZIndex = props.ZIndex
		baseProps.onAbsoluteSizeChanged = props.onAbsoluteSizeChanged
		baseProps.onAbsolutePositionChanged = props.onAbsolutePositionChanged
	end
	
	return baseProps :: T & CommonProps
end

return withCommonProps
