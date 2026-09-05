local RadioGroupRoot = require(script.RadioGroup)
local RadioGroupItem = require(script.Item)

local RadioGroup = {
	Root = RadioGroupRoot,
	Item = RadioGroupItem
}

export type RadioGroupProps = RadioGroupRoot.RadioGroupProps
export type RadioGroupItemProps = RadioGroupItem.RadioGroupItemProps

return RadioGroup
