local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Image = require(script.Parent.Image)
local Text = require(script.Parent.Text)

local Font = BuilderIcons.Font
local IconVariant = BuilderIcons.IconVariant
type IconVariant = BuilderIcons.IconVariant

local IconSize = require(Enums.IconSize)
type IconSize = IconSize.IconSize

local migrateFontSize = require(script.migrateFontSize)
local migrateIconName = require(script.migrateIconName)

local isBuilderIcon = require(Utility.isBuilderIcon)
local unwrap = require(Utility.unwrap)
local useIconSize = require(Utility.useIconSize)
local withCommonProps = require(Utility.withCommonProps)
local withDefaults = require(Utility.withDefaults)
local Types = require(Utility.Types)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child
type ColorStyle = Types.ColorStyle

export type IconProps = {
	-- The scope in which the component will be created.
	scope: Scope,
	name: UsedAs<string>,
	style: UsedAs<ColorStyle>?,
	size: UsedAs<IconSize | number>?,
	variant: UsedAs<IconVariant>?,
	Rotation: UsedAs<number>?,
	-- These properties are converted from contexts.
	textSizeOffset: UsedAs<number>?,
	-- **DEPRECATED**
	children: {Child}?,
} & Types.CommonProps

local defaultProps = {
	size = IconSize.Medium,
	variant = IconVariant.Regular,
}

return function(iconProps: IconProps): UsedAs<ImageLabel | TextLabel>
	local Scope = iconProps.scope
	local Theme = ThemeProvider()
	assert(Scope, "A scope has not been provided for the Icon component.")
	
	local props = withDefaults(iconProps, defaultProps)
	
	return Scope:Computed(function(use: Use, innerScope: Scope) 
		local name = unwrap(props.name, use)
		local migratedIcon = migrateIconName(name)
		
		local size = unwrap(useIconSize(innerScope, props.size, isBuilderIcon(name)), use)
		local variant = unwrap(props.variant, use)
		local tokens = unwrap(Theme.Tokens, use)
		local textSizeOffset = unwrap(props.textSizeOffset, use) or 0
		
		local fontSize: number? = if typeof(size) == "table" then nil else size.Y.Offset
		
		if not isBuilderIcon(name) then
			if migratedIcon then
				if typeof(size) == "table" then
					error("Binding size isn't supported when migrating a UIBlox icon, use Builder Icons directly")
				end
				variant = migratedIcon.variant or variant
				name = migratedIcon.name
				fontSize = migrateFontSize(fontSize :: number, tokens)
			end
		end
		
		local iconStyle = unwrap(props.style, use) or tokens.Color.Content.Default
		
		if not isBuilderIcon(name) and not migratedIcon then
			if iconProps.variant ~= nil then
				-- This can be converted back to Logger Utility if Lumberyak is added as a package.
				warn("[FusionFoundation]: variant is not supported when using FoundationImages, consider using BuilderIcons")
			end
			
			return Image(withCommonProps(props, {
				scope = innerScope,
				imageStyle = iconStyle,
				Image = name,
				Size = size,
				Rotation = props.Rotation,
				children = props.children
			}))
		else
			local children = props.children or {}
			table.insert(children, 
				if textSizeOffset > 0 and fontSize then 
					innerScope:New "UITextSizeConstraint" {
						MaxTextSize = fontSize,
					}
					else nil)
			
			return Text(withCommonProps(props, {
				scope = innerScope,
				textStyle = iconStyle,
				Text = name,
				fontStyle = {
					Font = Font[variant],
					FontSize = fontSize,
				},
				TextScaled = typeof(size) == "table",
				Size = size,
				Rotation = props.Rotation,
				children = children
			}))
		end
	end)
end