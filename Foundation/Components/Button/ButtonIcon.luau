local Foundation = script:FindFirstAncestor("Foundation")
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Utility = Foundation.Utility
local Enums = Foundation.Enums
local TypesSource = Utility.Types

local Image = require(Foundation.Components.Image)
local Text = require(Foundation.Components.Text)

local getIconScale = require(Utility.getIconScale)
local iconMigrationUtils = require(Utility.iconMigrationUtils)
local useButtonVariants = require(script.Parent.useButtonVariants)
local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local unwrap = require(Utility.unwrap)

local InputSize = require(Enums.InputSize)
local ButtonVariant = require(Enums.ButtonVariant)
local Types = require(TypesSource.Types)

local migrationLookup = BuilderIcons.Migration["uiblox"]
local isMigrated = iconMigrationUtils.isMigrated
local isBuilderOrMigratedIcon = iconMigrationUtils.isBuilderOrMigratedIcon

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
	textSizeOffset: UsedAs<number>?,
}

return function(props: ButtonIconProps)
	local scope = props.scope
	local Theme = ThemeProvider()

	local currentIcon = unwrap(props.icon)
	if not currentIcon or currentIcon == "" then
		return nil
	end

	local currentSize = unwrap(props.size)
	local variantProps = useButtonVariants(scope, props.size, props.variant, nil)
	local intrinsicIconSize, scale = getIconScale(currentIcon, currentSize)
	local textOffset = unwrap(props.textSizeOffset) or 0
	
	local mixedIconStyle = scope:Computed(function(use: Use)
		local currentVariant = unwrap(variantProps, use)
		local disabledValue = unwrap(props.disabledTransparencyBinding, use) or 0
		local progressValue = unwrap(props.textTransparencyBinding, use) or 0

		return {
			Color3 = currentVariant.content.style.Color3,
			Transparency = progressValue + disabledValue
		}
	end)

	if isBuilderOrMigratedIcon(currentIcon) then
		return Text {
			scope = scope,
			Text = if isMigrated(currentIcon) then migrationLookup[currentIcon].name else currentIcon,
			fontStyle = scope:Computed(function(use: Use)
				local currentVariant = unwrap(variantProps, use)
				return {
					Font = BuilderIcons.Font[if isMigrated(currentIcon)
						then migrationLookup[currentIcon].variant
						else BuilderIcons.IconVariant.Regular],
					FontSize = currentVariant.icon.size.Y.Offset,
				}
			end),
			tag = "position-center-center anchor-center-center",
			Size = scope:Computed(function(use: Use)
				return unwrap(variantProps, use).icon.size
			end),
			textStyle = mixedIconStyle,
			children = if textOffset > 0
				then {
					scope:New "UITextSizeConstraint" {
						MaxTextSize = scope:Computed(function(use: Use)
							return unwrap(variantProps, use).icon.size.Y.Offset
						end),
					},
				}
				else nil,
		}
	else
		return Image {
			scope = scope,
			tag = "position-center-center anchor-center-center",
			Image = currentIcon,
			Size = if intrinsicIconSize
				then UDim2.fromOffset(intrinsicIconSize.X, intrinsicIconSize.Y)
				else scope:Computed(function(use: Use)
					return unwrap(variantProps, use).icon.size
				end),
			imageStyle = mixedIconStyle,
			scale = scale,
		}
	end
end