local Foundation = script.Parent.Parent.Parent

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local unwrap = require(Utility.unwrap)
local isState = require(Utility.isState)
local useVariants = require(Utility.useVariants)
local composeStyleVariant = require(Utility.composeStyleVariant)
local Types = require(Utility.Types)

local AvatarIconSize = require(Enums.AvatarIconSize)

type Scope = Types.Scope
type Use = Types.Use

type AvatarIconSize = AvatarIconSize.AvatarIconSize
type VariantProps = composeStyleVariant.VariantProps
type ColorStyle = Types.ColorStyle


local function variantsMap(tokens: {[string]: any})
	local common = {
		container = { tag = "radius-circle" },
		avatar = { tag = "size-full radius-circle" }
	}

	local backplateStrokes: { [boolean]: { [AvatarIconSize]: number } } = {
		[true] = {
			[AvatarIconSize.XSmall] = tokens.Stroke.Standard,
			[AvatarIconSize.Small] = tokens.Stroke.Standard,
			[AvatarIconSize.Medium] = tokens.Stroke.Thick,
			[AvatarIconSize.Large] = tokens.Stroke.Thicker,
			[AvatarIconSize.XLarge] = tokens.Stroke.Thicker,
		},
		[false] = {}
	}

	local sizes: { [AvatarIconSize]: VariantProps } = {
		[AvatarIconSize.XSmall] = { container = { size = tokens.Size.Size_300 } },
		[AvatarIconSize.Small] = { container = { size = tokens.Size.Size_400 } },
		[AvatarIconSize.Medium] = { container = { size = tokens.Size.Size_500 } },
		[AvatarIconSize.Large] = { container = { size = tokens.Size.Size_600 } },
		[AvatarIconSize.XLarge] = { container = { size = tokens.Size.Size_700 } }
	}

	return {
		strokes = backplateStrokes,
		common = common,
		sizes = sizes
	}
end

return function(theme: string, tokens: {[string]: any}, size: AvatarIconSize, backplateStyle: ColorStyle?): VariantProps
	local props = useVariants(theme, tokens, "AvatarIcon", variantsMap)
	local stroke
	
	if backplateStyle then
		local thickness = props.strokes[true][size]
		if thickness then
			stroke = {
				Color = backplateStyle.Color3,
				Transparency = backplateStyle.Transparency,
				Thickness = thickness
			}
		end
	end

	return composeStyleVariant(
		props.common,
		props.sizes[size],
		{ container = { stroke = stroke } }
	)
end