-- Seperated this function to its own module, because Script Editor messes it up.
return function (values: { autoSize: boolean, isOverMaxHeight: boolean }): Enum.AutomaticSize
	return if values.autoSize
		then if values.isOverMaxHeight then Enum.AutomaticSize.X else Enum.AutomaticSize.XY
	else if values.isOverMaxHeight then Enum.AutomaticSize.None else Enum.AutomaticSize.Y
end