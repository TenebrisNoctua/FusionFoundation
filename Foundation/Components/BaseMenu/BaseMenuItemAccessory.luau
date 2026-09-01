local Foundation = script.Parent.Parent.Parent

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Icon = require(Foundation.Components.Icon)
local Text = require(Foundation.Components.Text)
local View = require(Foundation.Components.View)
local Avatar = require(Foundation.Components.Avatar)
local Badge = require(Foundation.Components.Badge)

local Types = require(Utility.Types)

local AccessoryType = require(Enums.AccessoryType)
local InputSize = require(Enums.InputSize)

type Scope = Types.Scope
type Use = Types.Use
type UsedAs<T> = Types.UsedAs<T>
type Child = Types.Child
type InputSize = InputSize.InputSize
type ColorStyleValue = Types.ColorStyleValue

type IconAccessoryConfig = Types.IconAccessoryConfig
type AvatarAccessoryConfig = Types.AvatarAccessoryConfig
type HintAccessoryConfig = Types.HintAccessoryConfig
type BadgeAccessoryConfig = Types.BadgeAccessoryConfig

export type LeadingAccessory = IconAccessoryConfig | AvatarAccessoryConfig
export type TrailingAccessory = HintAccessoryConfig | BadgeAccessoryConfig

export type IconVariantTag = { tag: string, style: ColorStyleValue, size: number }

local SLOT_ALIGN = "align-x-center align-y-center"
local HINT_TAG = "row align-y-center auto-xy padding-x-xsmall radius-small bg-shift-200"
local HINT_TEXT_TAG = "auto-xy text-caption-medium content-muted"

export type AccessoryProps = {
	scope: Scope,
	LayoutOrder: number,
	accessory: LeadingAccessory | TrailingAccessory | nil,
	iconVariant: IconVariantTag,
	size: InputSize,
	tokens: any,
}

local function Accessory(props: AccessoryProps): Child
	local scope = props.scope
	local accessory = props.accessory
	if accessory == nil then
		return nil
	end

	local slotTag = `{SLOT_ALIGN} {props.iconVariant.tag}`

	if accessory.type == AccessoryType.Avatar then
		return View {
			scope = scope,
			LayoutOrder = props.LayoutOrder,
			tag = slotTag,
			children = {
				Avatar = Avatar {
					scope = scope,
					userId = accessory.userId,
					backplateStyle = props.tokens.Color.Shift.Shift_200,
					size = props.size,
					isIconSize = true
				}
			}
		}
	end

	if accessory.type == "Hint" then
		return View {
			scope = scope,
			LayoutOrder = props.LayoutOrder,
			tag = HINT_TAG,
			children = {
				Text = Text {
					scope = scope,
					Text = accessory.text,
					tag = HINT_TEXT_TAG,
				},
			}
		}
	end

	if accessory.type == "Badge" then
		return Badge {
			scope = scope,
			LayoutOrder = props.LayoutOrder,
			text = accessory.text,
			icon = accessory.icon,
			variant = accessory.variant,
		}
	end

	-- Default: Icon accessory
	return View {
		scope = scope,
		LayoutOrder = props.LayoutOrder,
		tag = slotTag,
		children = {
			Icon = Icon {
				scope = scope,
				name = accessory.iconName,
				style = props.iconVariant.style,
				size = props.iconVariant.size,
			}
		}
	}
end

return Accessory