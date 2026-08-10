-- Written by @TenebrisNoctua
-- Handles the theme that will be applied to the components.

local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)
local StyleSheet = require(Foundation.StyleSheet)

local Fusion = PackageManager.getPackage("Fusion")

local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Tokens = require(script.Tokens)
local useTagsState = require(script.useTagsState)

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local Types = require(Utility.Types)

local Theme = require(Enums.Theme)
local Device = require(Enums.Device)
local ColorMode = require(Enums.ColorMode)

local getTokens = Tokens.getTokens

local FoundationUseStyleSheetRegistry = true

local useRegistryStyleSheet = if FoundationUseStyleSheetRegistry
	then require(script.useRegistryStyleSheet)
	else nil :: never

-- After join, there are no optional values
local defaultStyle = {
	theme = Theme.Dark :: Theme,
	device = Device.Desktop :: Device,
	scale = 1,
}

local themeProvider = {
	Theme = nil :: UsedAs<Theme>,
	Tokens = nil :: Tokens,
	Tags = nil :: UsedAs<{[string]: boolean}>?,
	RegistryStyleSheet = nil :: UsedAs<StyleSheet>,
	StyleLink = nil :: StyleLink,
	Scope = nil :: Scope,
	Presentation = {
		isIconSize = false,
		colorMode = ColorMode.Color
	} :: PresentationValue,
	AddTags = function(tags: {string})
		error("ThemeProvider has not been initialized!")
	end
}

type State<T> = Types.State<T>
type UsedAs<T> = Types.UsedAs<T>

type Scope = Types.Scope
type Use = Types.Use
type Fusion = Types.Fusion

type Theme = Theme.Theme
type Device = Device.Device
type Tokens = Tokens.Tokens
type ColorMode = ColorMode.ColorMode

export type ThemeProviderProps = {
	scope: Scope,
	theme: UsedAs<Theme>,
	device: UsedAs<Device>,
	scale: UsedAs<number?>,
	tags: UsedAs<{[string]: boolean}>,
	derives: UsedAs<{StyleSheet}?>?,
	setStyleSheetRef: { current: ((StyleSheet?) -> ()) | nil }?
}

export type PresentationValue = {
	isIconSize: boolean,
	colorMode: ColorMode
}

type themeProvider = typeof(themeProvider)

--// Main Functions

function themeProvider.setPresentation(providedValue: PresentationValue)
	themeProvider.Presentation = providedValue
end

return function(themeProviderProps: ThemeProviderProps?): (themeProvider, () -> ()?)
	if themeProvider.Scope then return themeProvider end
	local themeScope = Fusion:scoped()
	local themeProviderProps = themeProviderProps or {}
	
	local props = withDefaults({
		theme = themeProviderProps.theme,
		device = themeProviderProps.device,
		scale = themeProviderProps.scale,
	}, defaultStyle)
	
	local tokens = themeScope:Computed(function(use: Use) 
		return getTokens(unwrap(props.theme, use), unwrap(props.device, use), unwrap(props.scale, use))
	end)
	
	if not FoundationUseStyleSheetRegistry then
		local tags, addTags = useTagsState(themeScope)
		themeProvider.Tags = tags
		themeProvider.AddTags = addTags
		
		local styleSheetInstances = StyleSheet {
			scope = themeScope,
			theme = props.theme,
			device = props.device,
			scale = props.scale,
			tags = tags,
			derives = props.derives,
			setStyleSheetRef = props.setStyleSheetRef
		}

		if styleSheetInstances.FoundationStyleSheet then
			themeProvider.RegistryStyleSheet = styleSheetInstances.FoundationStyleSheet
		end
		if styleSheetInstances.FoundationStyleLink then
			themeProvider.StyleLink = styleSheetInstances.FoundationStyleLink
		end
	end
	
	if FoundationUseStyleSheetRegistry then
		local registryStyleSheet, addStyleTags = useRegistryStyleSheet(themeScope, props.theme, props.device, props.scale)
		themeProvider.RegistryStyleSheet = registryStyleSheet
		themeProvider.AddTags = addStyleTags
		
		local styleLinkNode = themeScope:New "StyleLink" {
			StyleSheet = registryStyleSheet
		}
		
		themeProvider.StyleLink = styleLinkNode
	end
	
	themeProvider.Theme = props.theme
	themeProvider.Scope = themeScope
	themeProvider.Tokens = tokens

	return themeProvider, function()
		Fusion.doCleanup(themeScope)
		
		local RegistryStyleSheet = unwrap(themeProvider.RegistryStyleSheet)
		local StyleLink = unwrap(themeProvider.StyleLink)
		
		if RegistryStyleSheet then
			RegistryStyleSheet:Destroy()
		end
		
		if StyleLink then
			StyleLink:Destroy()
		end
		
		themeProvider.Theme = nil
		themeProvider.Scope = nil
		themeProvider.Tags = nil
		themeProvider.RegistryStyleSheet = nil
		themeProvider.StyleLink = nil
		themeProvider.AddTags = function()
			error("ThemeProvider has not been initialized!")
		end
		
		themeProvider.Presentation = {
			isIconSize = false,
			colorMode = ColorMode.Color
		}
	end
end