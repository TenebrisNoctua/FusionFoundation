local Foundation = script:FindFirstAncestor("Foundation")
local PackageManager = require(Foundation.PackageManager)

local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useButtonVariants = require(script.Parent.useButtonVariants)

local Image = require(Foundation.Components.Image)
local Text = require(Foundation.Components.Text)

local unwrap = require(Utility.unwrap)
local getIconScale = require(Utility.getIconScale)
local iconMigrationUtils = require(Utility.iconMigrationUtils)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)
local ButtonVariant = require(Enums.ButtonVariant)

local migrationLookup = BuilderIcons.Migration["uiblox"]
local isMigrated = iconMigrationUtils.isMigrated
local isBuilderOrMigratedIcon = iconMigrationUtils.isBuilderOrMigratedIcon

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type InputSize = InputSize.InputSize
type SupportedButtonVariant = ButtonVariant.ButtonVariant

export type ButtonIconProps = {
	scope: Scope,
	icon: UsedAs<string>?,
	isLoading: UsedAs<boolean>?,
	variant: UsedAs<SupportedButtonVariant>,
	size: UsedAs<InputSize>,
	disabledTransparencyBinding: UsedAs<number>,
	textTransparencyBinding: UsedAs<number>,
	textSizeOffset: UsedAs<number>?
}

return function(props: ButtonIconProps)
	local scope = props.scope
	local theme = ThemeProvider()

	local currentSize = unwrap(props.size)
	local textOffset = unwrap(props.textSizeOffset) or 0
	
	local tokens = unwrap(theme.Tokens)
	local variantProps = useButtonVariants(unwrap(theme.Theme), tokens, currentSize, unwrap(props.variant), nil)

	local mixedIconStyle = scope:Computed(function(use: Use)
		local disabledValue = unwrap(props.disabledTransparencyBinding, use) or 0
		local progressValue = unwrap(props.textTransparencyBinding, use) or 0
		
		return {
			Color3 = variantProps.content.style.Color3,
			Transparency = progressValue + disabledValue
		}
	end)
	
	return scope:Computed(function(use: Use, innerScope: Scope) 
		local currentIcon = unwrap(props.icon, use)
		if not currentIcon or currentIcon == "" then return end
		local intrinsicIconSize, scale = getIconScale(currentIcon, currentSize)
		
		if isBuilderOrMigratedIcon(currentIcon) then
			return Text {
				scope = scope,
				Text = if isMigrated(currentIcon) then migrationLookup[currentIcon].name else currentIcon,
				fontStyle = {
					Font = BuilderIcons.Font[if isMigrated(currentIcon)
						then migrationLookup[currentIcon].variant
						else BuilderIcons.IconVariant.Regular],
					FontSize = variantProps.icon.size.Y.Offset,
				},
				tag = "position-center-center anchor-center-center",
				Size = variantProps.icon.size,
				textStyle = mixedIconStyle,
				children = if textOffset > 0
					then {
						scope:New "UITextSizeConstraint" {
							MaxTextSize = variantProps.icon.size.Y.Offset
						}
					}
					else nil
			}
		else
			return Image {
				scope = scope,
				tag = "position-center-center anchor-center-center",
				Image = currentIcon,
				Size = if intrinsicIconSize
					then UDim2.fromOffset(intrinsicIconSize.X, intrinsicIconSize.Y)
					else variantProps.icon.size,
				imageStyle = mixedIconStyle,
				scale = scale
			}
		end
	end)
end