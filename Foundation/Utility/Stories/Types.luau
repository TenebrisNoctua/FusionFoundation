local Foundation = script.Parent.Parent.Parent

local Types = require(Foundation.Utility.Types)

local Device = require(Foundation.Enums.Device)
local Theme = require(Foundation.Enums.Theme)

local StoryTypes = {}

local PreferencesProvider = require(Foundation.Providers.PreferencesProvider)

type Scope = Types.Scope
type Child = Types.Child

type Theme = Theme.Theme
type Device = Device.Device
type Preferences = PreferencesProvider.PreferencesProps

export type DeveloperStorybookStoryProps = {
	focus: LayerCollector,
	theme: Theme,
	platform: Platform,
	settings: Preferences?,
	plugin: Plugin,
	host: GuiObject,
}

export type FlipbookStoryProps = {
	theme: string,
	plugin: Plugin,
	locale: string,
	container: GuiObject,
	controls: { [string]: any },
	widget: DockWidgetPluginGui,
}

export type UILabsStoryProps = {
	plugin: Plugin?,
	scope: Scope,
	controls: { 
		theme: Theme?,
		device: Device?,
		preferredTextSize: Enum.PreferredTextSize?,
		preferredTransparency: number?,
		reducedMotion: boolean?,
		scale: number?,
		[string]: any 
	}
}

export type StoryProps = FlipbookStoryProps | DeveloperStorybookStoryProps

export type StorySectionProps = {
	scope: Scope,
	title: string,
	description: string?,
	layoutOrder: number?,
	children: Child
}

--[[ 
	These functions are related to the two internal plugins that are used to display component stories: Flipbook and Developer Storybook.
	They will remain here for API compatibility, but since Fusion doesn't have any compatibility with neither of those plugins,
	these functions will most likely never be used. Even if Fusion gains compatibility, it is unclear whether or not these plugins
	will ever be accessible without certain modifications.
--]]

function StoryTypes.toDeveloperStorybookStoryProps(storyProps: StoryProps): DeveloperStorybookStoryProps?
	if rawget(storyProps, "focus") then
		return storyProps :: DeveloperStorybookStoryProps
	end
	return nil
end

function StoryTypes.toFlipbookStoryProps(storyProps: StoryProps): FlipbookStoryProps?
	if rawget(storyProps, "widget") then
		return storyProps :: FlipbookStoryProps
	end
	return nil
end

return StoryTypes
