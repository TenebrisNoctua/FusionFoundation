local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local migrateFontSize = require(script.migrateFontSize)
local migrateIconName = require(script.migrateIconName)

local Image = require(Components.Image)
local Text = require(Components.Text)

local unwrap = require(Utility.unwrap)
local useIconSize = require(Utility.useIconSize)
local withDefaults = require(Utility.withDefaults)
local isBuilderIcon = require(Utility.isBuilderIcon)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)

local IconSize = require(Enums.IconSize)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local Font = BuilderIcons.Font
local IconVariant = BuilderIcons.IconVariant

local defaultProps = {
	size = IconSize.Medium,
	variant = IconVariant.Regular
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

type IconVariant = typeof(BuilderIcons.IconVariant)
type IconSize = IconSize.IconSize
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

return function(iconProps: IconProps): UsedAs<ImageLabel | TextLabel>
	local scope = iconProps.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the Icon component.")
	
	local props = withDefaults(iconProps, defaultProps)
	
	return scope:Computed(function(use: Use, innerScope: Scope) 
		local name = unwrap(props.name, use)
		local size = unwrap(props.size, use)
		local variant = unwrap(props.variant, use)
		local textSizeOffset = unwrap(props.textSizeOffset, use) or 0
		
		local migratedIcon = migrateIconName(name)
		local size = useIconSize(size, isBuilderIcon(name))
		
		local tokens = unwrap(theme.Tokens, use)
		local fontSize: number? = if typeof(size) == "table" then nil else size.Y.Offset
		
		if not isBuilderIcon(name) then
			if migratedIcon then
				if typeof(size) == "table" then
					error("[FusionFoundation]: Binding size isn't supported when migrating a UIBlox icon, use Builder Icons directly")
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