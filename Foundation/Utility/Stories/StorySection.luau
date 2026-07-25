local Foundation = script.Parent.Parent.Parent
local View = require(Foundation.Components.View)
local Text = require(Foundation.Components.Text)

local Types = require(Foundation.Utility.Types)
local StoryTypes = require(Foundation.Utility.Stories.Types)

type Scope = Types.Scope
export type StorySectionProps = StoryTypes.StorySectionProps

--[[
	StorySection wraps an UILabs story section as a View component with a title.
	It allows you to group every story function into a group that provides a better view for stories.

	Usage in a UILabs story module:
		StorySection {
			scope = scope,
			title = "Basic Story",
			description = "Basic story description", -- Description will not be created if it's empty or nil.
			layoutOrder = 1, -- If not provided, it will be assumed to be 1.
			children = {
				...
			}
		}
	
	An important note, if there is a title and a description, the layoutOrder of children must start from 3,
	otherwise they will appear before the title and description. If there's only a title, it must start from 2.
]]

local function StorySection(storySectionProps: StorySectionProps)
	local scope = storySectionProps.scope
	local title = storySectionProps.title
	local description = storySectionProps.description
	local children = storySectionProps.children or {}
	local layoutOrder = storySectionProps.layoutOrder or 1
	
	table.insert(children, scope:New "UIListLayout" {
		Padding = UDim.new(0, 24),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	
	table.insert(children, Text {
		scope = scope,
		LayoutOrder = 1,
		Text = title,
		tag = "size-full-0 auto-y text-heading-small text-align-x-left"
	})
	
	if description and description ~= "" then
		table.insert(children, Text {
			scope = scope,
			LayoutOrder = 2,
			Text = description,
			fontStyle = {
				FontSize = 18	
			},
			tag = "size-full-0 auto-y x-default-text-size text-align-x-left"
		})
	end
	
	return View {
		scope = scope,
		tag = "padding-medium",
		LayoutOrder = layoutOrder,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		BackgroundTransparency = 1,
		children = children
	}
end

return StorySection
