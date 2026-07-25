local Foundation = script.Parent.Parent.Parent

local View = require(Foundation.Components.View)

local Types = require(Foundation.Utility.Types)
local StoryTypes = require(Foundation.Utility.Stories.Types)

local FoundationProvider = require(Foundation.Providers.FoundationProvider)

local FoundationPopoverPluginSupport = true

type Scope = Types.Scope
export type UILabsStoryProps = StoryTypes.UILabsStoryProps

--[[
	StoryMiddleware wraps a UILabs story function to provide Foundation context.

	It:
	1. Creates an overlay Frame for popover/floating content testing
	2. Initializes FoundationProvider (ThemeProvider, OverlayProvider, ElevationProvider, etc.)
	   with certain properties from the controls. (Theme and Device)
	3. Creates a StyleLink under the overlay so Foundation styles apply to floating content
	4. Calls the original story function with the same { scope, controls } props
	5. Wraps the story's result in a padded View that includes the overlay

	Usage in a UILabs story module:
		local StoryMiddleware = require(Foundation.Utility.Stories.StoryMiddleware)
		return {
			fusion = Fusion,
			controls = { ... },
			story = StoryMiddleware(function(props)
				local scope = props.scope
				local controls = props.controls
				-- Providers are now automatically initialized and can be required without providing any parameters here.
				return View { ... }
			end)
		}
]]

local function StoryMiddleware(story: (UILabsStoryProps) -> any)
	return function(storyProps: UILabsStoryProps)
		local scope = storyProps.scope
		local controls = storyProps.controls
		
		-- TODO: Add preferences
		local theme = controls and controls.theme
		local device = controls and controls.device

		-- This Frame serves as the parent for popover content.
		local overlayFrame = scope:New "Frame" {
			Name = "Overlay",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 1000,
		}

		local providers = FoundationProvider({
			scope = scope,
			theme = theme,
			device = device,
			overlayGui = overlayFrame,
			plugin = if FoundationPopoverPluginSupport then storyProps.plugin else nil
		})

		local themeProvider = providers.themeProvider

		-- Create a StyleLink parented to the overlay so Foundation styles
		-- apply to floating content rendered on the overlay.
		scope:New "StyleLink" {
			StyleSheet = themeProvider.RegistryStyleSheet,
			Parent = overlayFrame,
		}

		-- Call the original story function with the same props.
		local storyContent = story(storyProps)

		-- Return a wrapping View that holds the returned content and the overlay
		return View {
			Name = "FoundationStory",
			scope = scope,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.fromScale(1, 0),
			BackgroundTransparency = 1,
			children = {
				scope:New "UIPadding" { -- Padding makes selection cursors easier to see in storybook
					PaddingTop = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
				},
				themeProvider.StyleLink, -- Foundation StyleLink from ThemeProvider
				storyContent, -- The original story content
				overlayFrame, -- Overlay for floating content
			}
		}
	end
end

return StoryMiddleware
