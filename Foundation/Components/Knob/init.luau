local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useKnobVariants = require(script.useKnobVariants)

local Icon = require(Components.Icon)
local View = require(Components.View)
local Image = require(Components.Image)

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local blendTransparencies = require(Utility.blendTransparencies)
local Types = require(Utility.Types)

local InputSize = require(Enums.InputSize)
local ColorNamespace = require(Enums.ColorNamespace)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local usePresentationContext = require(Foundation.Providers.ThemeProvider.PresentationContext).usePresentationContext

local Constants = require(Foundation.Constants)

local defaultProps = {
	size = InputSize.Medium,
	hasShadow = true,
	isDisabled = false
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type InputSize = InputSize.InputSize
type IconVariant = typeof(BuilderIcons.IconVariant)

export type KnobProps = {
	scope: Scope,
	size: UsedAs<InputSize>?,
	style: UsedAs<Types.ColorStyle>?,
	stroke: UsedAs<Types.Stroke>?,
	hasShadow: UsedAs<boolean>?,
	-- Optional icon to render instead of the default knob circle
	icon: UsedAs<{ name: string, variant: IconVariant }?>?,
	isDisabled: UsedAs<boolean>?
} & Types.CommonProps

return function(knobProps: KnobProps)
	local scope = knobProps.scope
	assert(scope, "A scope has not been provided for the Knob component.")

	local theme = ThemeProvider()
	local presentationContext = usePresentationContext()
	local props = withDefaults(knobProps, defaultProps)

	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local size = unwrap(props.size, use)
		local isDisabled = unwrap(props.isDisabled, use)
		local icon = unwrap(props.icon, use)
		local hasShadow = unwrap(props.hasShadow, use)
		local stroke = unwrap(props.stroke, use)

		local isInverse = unwrap(presentationContext.colorNamespace, use) == ColorNamespace.Inverse
		local variantProps = useKnobVariants(unwrap(theme.Theme, use), tokens, size, isInverse)

		local knobStyle = unwrap(props.style, use) or variantProps.knob.style

		local circleSize = variantProps.knob.size
		if stroke and stroke.Thickness then
			local thickness = unwrap(stroke.Thickness, use)
			circleSize = circleSize - UDim2.fromOffset(thickness * 2, thickness * 2)
		end

		local resolvedStroke = stroke
		if stroke and isDisabled and stroke.Transparency ~= nil then
			resolvedStroke = {
				Color3 = stroke.Color3,
				Thickness = stroke.Thickness,
				Transparency = blendTransparencies(unwrap(stroke.Transparency, use), Constants.DISABLED_TRANSPARENCY),
			}
		end

		local function getShadowStyle(style: Types.ColorStyleValue)
			return {
				Color3 = tokens.Color.Extended.White.White_100.Color3,
				Transparency = style.Transparency
			}
		end

		return View(withCommonProps(props, {
			scope = innerScope,
			Size = variantProps.knob.size,
			isDisabled = isDisabled,
			children = {
				Icon = if icon
					then View {
						scope = innerScope,
						tag = variantProps.knob.tag,
						Size = circleSize,
						ZIndex = 4,
						backgroundStyle = variantProps.iconContainer.backgroundStyle,
						children = {
							Icon = Icon {
								scope = innerScope,
								name = icon.name,
								variant = icon.variant,
								style = if isDisabled
								then {
									Color3 = variantProps.knob.style.Color3,
									Transparency = blendTransparencies(variantProps.knob.style.Transparency, Constants.DISABLED_TRANSPARENCY),
								}
								else variantProps.knob.style,
								size = variantProps.knob.iconSize,
							},
						},
					}
					else View {
						scope = innerScope,
						tag = variantProps.knob.tag,
						backgroundStyle = if isDisabled
						then {
							Color3 = knobStyle.Color3,
							Transparency = blendTransparencies(knobStyle.Transparency, Constants.DISABLED_TRANSPARENCY)
						}
						else knobStyle,
						Size = circleSize,
						stroke = resolvedStroke,
						ZIndex = 4
					},
				Shadow = if hasShadow and not isDisabled
					then Image {
						scope = innerScope,
						tag = variantProps.knobShadow.tag,
						imageStyle = getShadowStyle(knobStyle),
						Image = "component_assets/dropshadow_28",
						Size = variantProps.knobShadow.size,
						ZIndex = 3
					}
					else nil
			}
		}))
	end)
end
