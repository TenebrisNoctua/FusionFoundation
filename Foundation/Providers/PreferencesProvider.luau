-- Written by @TenebrisNoctua
-- Provides user preferences for Foundation components.

local Foundation = script.Parent.Parent

local Utility = Foundation.Utility
local Types = require(Utility.Types)
local withDefaults = require(Utility.withDefaults)

type Scope = Types.Scope

export type Preferences = {
	preferredTextSize: Enum.PreferredTextSize,
	preferredTransparency: number,
	reducedMotion: boolean,
}

export type PreferencesProps = {
	preferredTextSize: Enum.PreferredTextSize?,
	preferredTransparency: number?,
	reducedMotion: boolean?,
	scale: number?,
}

local defaultPreferences = {
	preferredTextSize = Enum.PreferredTextSize.Medium,
	preferredTransparency = 1,
	reducedMotion = false,
	scale = 1,
}

local preferencesProvider = {
	preferences = {} :: Preferences,
	scale = 1,
}

type preferencesProvider = typeof(preferencesProvider)

return function(props: PreferencesProps?): (preferencesProvider, () -> ()?)
	if preferencesProvider.initialized then return preferencesProvider end
	preferencesProvider.initialized = true

	local resolved = withDefaults({
		preferredTextSize = props and props.preferredTextSize,
		preferredTransparency = props and props.preferredTransparency,
		reducedMotion = props and props.reducedMotion,
	}, defaultPreferences)

	preferencesProvider.preferences = resolved
	preferencesProvider.scale = (props and props.scale) or defaultPreferences.scale

	return preferencesProvider, function()
		preferencesProvider.initialized = false
		preferencesProvider.preferences = {}
		preferencesProvider.scale = 1
	end
end