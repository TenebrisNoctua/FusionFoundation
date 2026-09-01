local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Dash = PackageManager.getPackage("Dash")

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useVariants = require(Utility.useVariants)
local composeStyleVariant = require(Utility.composeStyleVariant)
local Types = require(Utility.Types)

local BadgeVariant = require(Enums.BadgeVariant)
local BadgeShape = require(Enums.BadgeShape)
local BadgeSize = require(Enums.BadgeSize)
local IconPosition = require(Enums.IconPosition)
local IconSize = require(Enums.IconSize)

type ColorStyleValue = Types.ColorStyleValue
type BadgeVariant = BadgeVariant.BadgeVariant
type BadgeShape = BadgeShape.BadgeShape
type BadgeSize = BadgeSize.BadgeSize
type IconPosition = IconPosition.IconPosition
type IconSize = IconSize.IconSize
type VariantProps = composeStyleVariant.VariantProps

type BadgeVariantProps = {
	container: { tag: string, backgroundStyle: ColorStyleValue, stroke: Types.Stroke? },
	text: { tag: string },
	content: { style: ColorStyleValue },
	icon: { style: ColorStyleValue, size: IconSize },
}

local function variantsFactory(tokens: {[string]: any})
	local common = {
		container = {
			tag = "row align-x-center align-y-center auto-xy",
		},
		text = {
			tag = "auto-xy text-align-x-left text-truncate-split",
		},
	}

	local variants: { [BadgeVariant]: VariantProps } = {
		[BadgeVariant.Alert] = {
			container = {
				-- Color3 and Transparency kept distinct here since the spec's
				-- token isn't available directly in Luau yet.
				backgroundStyle = {
					Color3 = tokens.Color.System.Alert.Color3,
					Transparency = 0.8,
				},
			},
			content = { style = tokens.Color.Content.Emphasis },
			icon = { style = tokens.Color.System.Alert },
		},
		[BadgeVariant.Success] = {
			container = {
				backgroundStyle = {
					Color3 = tokens.Color.System.Success.Color3,
					Transparency = 0.8,
				},
			},
			content = { style = tokens.Color.Content.Emphasis },
			icon = { style = tokens.Color.System.Success },
		},
		[BadgeVariant.Warning] = {
			container = {
				backgroundStyle = {
					Color3 = tokens.Color.System.Warning.Color3,
					Transparency = 0.8,
				},
			},
			content = { style = tokens.Color.Content.Emphasis },
			icon = { style = tokens.Color.System.Warning },
		},
		[BadgeVariant.Contrast] = {
			container = { backgroundStyle = tokens.Color.System.Contrast },
			content = { style = tokens.Inverse.Content.Emphasis },
			icon = { style = tokens.Inverse.Content.Emphasis },
		},
		[BadgeVariant.Standard] = {
			container = { backgroundStyle = tokens.Color.ActionStandard.Background },
			content = { style = tokens.Color.ActionStandard.Foreground },
			icon = { style = tokens.Color.ActionStandard.Foreground },
		},
		[BadgeVariant.OverMedia] = {
			container = { backgroundStyle = tokens.Color.OverMedia.OverMedia_0 },
			content = { style = tokens.Inverse.OverMedia.OverMedia_0 },
			icon = { style = tokens.Inverse.OverMedia.OverMedia_0 },
		},
		[BadgeVariant.Emphasis] = {
			container = { backgroundStyle = tokens.Color.ActionEmphasis.Background },
			content = { style = tokens.Color.ActionEmphasis.Foreground },
			icon = { style = tokens.Color.ActionEmphasis.Foreground },
		}
	}

	local sizes: { [BadgeSize]: VariantProps } = {
		[BadgeSize.XSmall] = {
			container = { tag = "gap-xxsmall size-0-400 padding-x-xsmall" },
			text = { tag = "text-caption-small" },
			icon = { size = IconSize.XSmall },
		},
		[BadgeSize.Small] = {
			container = { tag = "gap-xsmall size-0-600 padding-x-small" },
			text = { tag = "text-caption-medium" },
			icon = { size = IconSize.XSmall },
		},
		-- BadgeSize.Medium is deprecated - mapped to Small for compatibility.
		[BadgeSize.Medium] = {
			container = { tag = "gap-xsmall size-0-600 padding-x-small" },
			text = { tag = "text-caption-medium" },
			icon = { size = IconSize.XSmall },
		},
	}

	local shapes: { [BadgeShape]: VariantProps } = {
		[BadgeShape.Pill] = { container = { tag = "radius-circle" } },
		[BadgeShape.Box] = { container = { tag = "radius-small" } },
	}

	local iconPlacement: { [IconPosition | typeof(Dash.None)]: VariantProps } = {
		[IconPosition.Left] = { text = { tag = "padding-right-xsmall" } },
		[IconPosition.Right] = { text = { tag = "padding-left-xsmall" } },
		[Dash.None] = { text = { tag = "padding-x-xsmall" } },
	}

	return {
		common = common,
		variants = variants,
		shapes = shapes,
		sizes = sizes,
		iconPlacement = iconPlacement,
	}
end

return function(
	theme: string,
	tokens: {[string]: any},
	variant: BadgeVariant,
	shape: BadgeShape,
	size: BadgeSize,
	iconPlacement: IconPosition?
): BadgeVariantProps
	local props = useVariants(theme, tokens, "Badge", variantsFactory)

	return composeStyleVariant(
		props.common,
		props.variants[variant],
		props.shapes[shape],
		props.sizes[size],
		props.iconPlacement[if iconPlacement then iconPlacement else Dash.None]
	)
end
