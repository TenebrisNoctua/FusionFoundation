local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Enums = Foundation.Enums
local Utility = Foundation.Utility
local TypesSource = Utility.Types

local InputSize = require(Enums.InputSize)
local IconSize = require(Enums.IconSize)

local composeStyleVariant = require(Utility.composeStyleVariant)
local useVariants = require(Utility.useVariants)
local unwrap = require(Utility.unwrap)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local Types = require(TypesSource.Types)

type Scope = Types.Scope
type UsedAs<T> = Types.UsedAs<T>
type Use = Types.Use

type InputSize = InputSize.InputSize
type IconSize = IconSize.IconSize
type ColorStyleValue = Types.ColorStyleValue

type VariantProps = composeStyleVariant.VariantProps

export type BaseMenuItemVariantProps = {
	container: { tag: string },
	icon: { tag: string, style: ColorStyleValue, size: number },
	text: { tag: string },
	check: { tag: string, style: ColorStyleValue, size: number },
	title: { tag: string },
	chevron: { size: IconSize },
	groupPadding: { size: number },
}

local FOUNDATION_BASE_MENU_ITEM_IMAGE_RADIUS = true

local function variantsMap(use: Use)
	local themeProvider = ThemeProvider()
	local tokens = unwrap(themeProvider.Tokens, use)

	local common = {
		container = {
			tag = "row flex-x-between align-y-center auto-x",
		},
		icon = {
			tag = if FOUNDATION_BASE_MENU_ITEM_IMAGE_RADIUS
				then "radius-small content-emphasis"
				else "content-emphasis",
			style = tokens.Color.Content.Emphasis,
		},
		text = {
			tag = "fill auto-xy text-align-x-left text-truncate-split content-emphasis",
		},
		title = {
			tag = "fill auto-xy text-align-x-left text-truncate-split content-default",
		},
		check = { 
			tag = "content-emphasis", 
			style = tokens.Color.Content.Emphasis 
		},
	}

	local sizes: { [InputSize]: VariantProps } = {
		[InputSize.XSmall] = {
			container = {
				tag = "gap-xsmall size-full-600 padding-x-medium radius-small",
			},
			icon = { tag = "size-400", size = IconSize.XSmall :: IconSize },
			text = { tag = "text-body-small" },
			title = { tag = "text-caption-small" },
			check = { tag = "size-300", size = tokens.Size.Size_600 },
			chevron = { size = IconSize.Small :: IconSize },
			groupPadding = { size = tokens.Padding.XSmall },
		},
		[InputSize.Small] = {
			container = {
				tag = "gap-xsmall size-full-800 padding-x-medium radius-medium",
			},
			icon = { tag = "size-500", size = IconSize.Small :: IconSize },
			text = { tag = "text-body-small" },
			title = { tag = "text-caption-small" },
			check = { tag = "size-400", size = tokens.Size.Size_700 },
			chevron = { size = IconSize.Small :: IconSize },
			groupPadding = { size = tokens.Padding.Small },
		},
		[InputSize.Medium] = {
			container = {
				tag = "gap-small size-full-1000 padding-x-medium radius-medium",
			},
			icon = { tag = "size-600", size = IconSize.Medium :: IconSize },
			text = { tag = "text-body-medium" },
			title = { tag = "text-caption-medium" },
			check = { tag = "size-500", size = tokens.Size.Size_800 },
			chevron = { size = IconSize.Medium :: IconSize },
			groupPadding = { size = tokens.Padding.Small },
		},
		[InputSize.Large] = {
			container = {
				tag = "gap-small size-full-1200 padding-x-large radius-medium",
			},
			icon = { tag = "size-700", size = IconSize.Large :: IconSize },
			text = { tag = "text-body-large" },
			title = { tag = "text-caption-large" },
			check = { tag = "size-600", size = tokens.Size.Size_900 },
			chevron = { size = IconSize.Large :: IconSize },
			groupPadding = { size = tokens.Padding.Small },
		},
	}

	local isChecked = {
		[false] = { container = { tag = "" } },
		[true] = { container = { tag = "bg-surface-200" } },
	}

	return { common = common, sizes = sizes, isChecked = isChecked }
end

local function useBaseMenuItemVariants(
	scope: Scope,
	tokens: any?,
	size: UsedAs<InputSize>,
	isChecked: UsedAs<boolean>
): UsedAs<BaseMenuItemVariantProps>
	return scope:Computed(function(use: Use)
		local variants = useVariants(use, "BaseMenuItem", variantsMap)
		local currentSize = unwrap(size, use)
		local currentIsChecked = unwrap(isChecked, use)

		return composeStyleVariant(
			variants.common,
			variants.sizes[currentSize],
			variants.isChecked[currentIsChecked]
		)
	end)
end

return useBaseMenuItemVariants