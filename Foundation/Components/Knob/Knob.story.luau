local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")
local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Knob = require(script.Parent)
local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local StorySection = require(Utility.Stories.StorySection)
local CommonControls = require(Utility.Stories.CommonControls)

local InputSize = require(Enums.InputSize)
local ColorNamespace = require(Enums.ColorNamespace)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local PresentationContext = require(Foundation.Providers.ThemeProvider.PresentationContext)

local SIZES = { InputSize.Large, InputSize.Medium, InputSize.Small, InputSize.XSmall }

type Scope = Types.Scope
type Use = Types.Use

local function presentationContextValue(isInverse: boolean)
	return {
		colorNamespace = if isInverse then ColorNamespace.Inverse else ColorNamespace.Color,
		isIconSize = false,
	}
end

-- Renders one Knob per size in a row - mirrors the React `Story` helper.
local function SizesRow(props: {
	scope: Scope,
	style: any?,
	stroke: any?,
	hasShadow: any?,
	icon: any?,
	isDisabled: any?,
	layoutOrder: number?,
})
	local scope = props.scope
	local children = {}
	for index, size in SIZES do
		children[index] = Knob {
			scope = scope,
			size = size,
			style = props.style,
			stroke = props.stroke,
			hasShadow = props.hasShadow,
			icon = props.icon,
			isDisabled = props.isDisabled,
			LayoutOrder = index,
		}
	end
	return View {
		scope = scope,
		tag = "row align-y-center gap-medium size-full-0 auto-y",
		LayoutOrder = props.layoutOrder,
		children = children,
	}
end

local function PlaygroundStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls
	local theme = ThemeProvider()

	return scope:Computed(function(use: Use, innerScope: Scope)
		local isInverse = unwrap(controls.isInverse, use)
		local tokens = unwrap(theme.Tokens, use)

		return View {
			scope = innerScope,
			tag = "align-y-center gap-medium auto-xy padding-medium radius-medium",
			backgroundStyle = if isInverse then tokens.Inverse.Surface.Surface_0 else nil,
			LayoutOrder = props.layoutOrder,
			children = { PresentationContext.Context:is(presentationContextValue(isInverse)):during(function()
				return Knob {
					scope = innerScope,
					size = controls.size,
					hasShadow = controls.hasShadow,
					isDisabled = controls.isDisabled,
				}
			end) },
		}
	end)
end

local function SizesStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls
	local theme = ThemeProvider()

	return scope:Computed(function(use: Use, innerScope: Scope)
		local isInverse = unwrap(controls.isInverse, use)
		local tokens = unwrap(theme.Tokens, use)

		return View {
			scope = innerScope,
			tag = "align-y-center gap-medium auto-xy padding-medium radius-medium",
			backgroundStyle = if isInverse then tokens.Inverse.Surface.Surface_0 else nil,
			LayoutOrder = props.layoutOrder,
			children = { PresentationContext.Context:is(presentationContextValue(isInverse)):during(function()
				return SizesRow {
					scope = innerScope,
					hasShadow = controls.hasShadow,
					isDisabled = controls.isDisabled,
					layoutOrder = 1,
				}
			end) },
		}
	end)
end

local function WithStrokeStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls
	local theme = ThemeProvider()

	return scope:Computed(function(use: Use, innerScope: Scope)
		local isInverse = unwrap(controls.isInverse, use)
		local tokens = unwrap(theme.Tokens, use)
		local emphasis = if isInverse then tokens.Inverse.Content.Emphasis else tokens.Color.Content.Emphasis

		return View {
			scope = innerScope,
			tag = "align-y-center gap-medium auto-xy padding-medium radius-medium",
			backgroundStyle = if isInverse then tokens.Inverse.Surface.Surface_0 else nil,
			LayoutOrder = props.layoutOrder,
			children = { PresentationContext.Context:is(presentationContextValue(isInverse)):during(function()
				return SizesRow {
					scope = innerScope,
					style = tokens.Color.None,
					stroke = {
						Color = emphasis.Color3,
						Thickness = tokens.Stroke.Thicker,
						Transparency = emphasis.Transparency,
					},
					hasShadow = controls.hasShadow,
					isDisabled = controls.isDisabled,
					layoutOrder = 1,
				}
			end) },
		}
	end)
end

local function WithIconStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls
	local theme = ThemeProvider()

	return scope:Computed(function(use: Use, innerScope: Scope)
		local isInverse = unwrap(controls.isInverse, use)
		local tokens = unwrap(theme.Tokens, use)

		return View {
			scope = innerScope,
			tag = "align-y-center gap-medium auto-xy padding-medium radius-medium",
			backgroundStyle = if isInverse then nil else tokens.Inverse.Surface.Surface_0,
			LayoutOrder = props.layoutOrder,
			children = { PresentationContext.Context:is(presentationContextValue(isInverse)):during(function()
				return SizesRow {
					scope = innerScope,
					hasShadow = controls.hasShadow,
					isDisabled = controls.isDisabled,
					icon = { name = BuilderIcons.Icon.Check, variant = BuilderIcons.IconVariant.Regular },
					layoutOrder = 1,
				}
			end) },
		}
	end)
end

return {
	fusion = Fusion,
	summary = "Interactive circular handle used by higher-level inputs (e.g., Slider and Toggle). Typically composed by parent controls rather than used directly. Uses PresentationContext for inverse styling.",
	controls = {
		isInverse = false,
		hasShadow = true,
		isDisabled = false,
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = InputSize.Medium,
			List = Dash.values(InputSize),
			DefIndex = 3,
		},
		theme = CommonControls.theme,
	},
	story = StoryMiddleware(function(props)
		local scope = props.scope
		local controls = props.controls

		return scope:Computed(function(use: Use, innerScope: Scope)
			unwrap(controls.theme, use)

			return View {
				scope = innerScope,
				tag = "col size-full-0 auto-y padding-large gap-xxlarge",
				children = {
					StorySection {
						scope = innerScope,
						title = "Playground",
						layoutOrder = 1,
						children = { PlaygroundStory { scope = innerScope, controls = controls, layoutOrder = 2 } },
					},
					StorySection {
						scope = innerScope,
						title = "Sizes",
						description = "Default knob across sizes.",
						layoutOrder = 2,
						children = { SizesStory { scope = innerScope, controls = controls, layoutOrder = 3 } },
					},
					StorySection {
						scope = innerScope,
						title = "With Stroke",
						description = "Knob with transparent fill and emphasis stroke across sizes.",
						layoutOrder = 3,
						children = { WithStrokeStory { scope = innerScope, controls = controls, layoutOrder = 3 } },
					},
					StorySection {
						scope = innerScope,
						title = "With Icon",
						description = "Knob rendering a BuilderIcons check icon instead of the circle.",
						layoutOrder = 4,
						children = { WithIconStory { scope = innerScope, controls = controls, layoutOrder = 3 } },
					},
				},
			}
		end)
	end),
}
