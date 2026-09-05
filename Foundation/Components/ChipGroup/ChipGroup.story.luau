local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local ChipGroup = require(script.Parent)

local View = require(Components.View)
local ScrollView = require(Components.ScrollView)

local Types = require(Utility.Types)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local StorySection = require(Utility.Stories.StorySection)
local CommonControls = require(Utility.Stories.CommonControls)

local ChipGroupVariant = require(Enums.ChipGroupVariant)
local ChipSize = require(Enums.ChipSize)

type Scope = Types.Scope
type Use = Types.Use

local GENRE_LABELS = {
	"Literary Fiction",
	"Historical Fiction",
	"Science Fiction",
	"Fantasy",
	"Magical Realism",
	"Speculative Fiction",
	"Mystery",
	"Thriller",
	"Crime Fiction",
	"Suspense",
	"Horror",
	"Gothic Fiction",
	"Romance",
	"Contemporary Fiction",
	"Adventure",
	"Western",
	"Dystopian",
	"Utopian",
	"Cyberpunk",
	"Steampunk",
	"Alternate History",
	"Psychological Fiction",
	"Satire",
	"Urban Fiction",
}

local function activated(label: string)
	return function()
		print(`ChipGroup: "{label}" activated`)
	end
end

local function buildChips()
	local chips = {}
	for index, label in GENRE_LABELS do
		chips[index] = {
			text = label,
			isChecked = index == 1,
			onActivated = activated(label),
		}
	end
	return chips
end

local function PlaygroundStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls

	return View {
		scope = scope,
		tag = "size-full-0 auto-y",
		LayoutOrder = props.layoutOrder,
		children = {
			ChipGroup {
				scope = scope,
				size = controls.size,
				variant = controls.variant,
				chips = buildChips(),
			},
		},
	}
end

local function RowStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	return View {
		scope = scope,
		tag = "size-full-0 auto-y",
		LayoutOrder = props.layoutOrder,
		children = {
			ChipGroup {
				scope = scope,
				size = ChipSize.Medium,
				variant = ChipGroupVariant.Row,
				chips = buildChips(),
			},
		},
	}
end

local function WrapStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	return View {
		scope = scope,
		tag = "size-full-0 auto-y",
		LayoutOrder = props.layoutOrder,
		children = {
			ChipGroup {
				scope = scope,
				size = ChipSize.Medium,
				variant = ChipGroupVariant.Wrap,
				chips = buildChips(),
			},
		},
	}
end

return {
	fusion = Fusion,
	summary = "ChipGroup",
	controls = {
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = ChipSize.Medium,
			List = { ChipSize.Medium, ChipSize.Small },
			DefIndex = 1,
		},
		variant = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = ChipGroupVariant.Row,
			List = { ChipGroupVariant.Row, ChipGroupVariant.Wrap },
			DefIndex = 1,
		},
		theme = CommonControls.theme,
	},
	story = StoryMiddleware(function(props)
		local scope = props.scope
		local controls = props.controls

		return ScrollView {
			scope = scope,
			tag = "col size-full-0 auto-y padding-x-large padding-top-large",
			scroll = {
				AutomaticCanvasSize = Enum.AutomaticSize.Y	
			},
			children = {
				StorySection {
					scope = scope,
					title = "Playground",
					layoutOrder = 1,
					children = { PlaygroundStory { scope = scope, controls = controls, layoutOrder = 2 } },
				},
				StorySection {
					scope = scope,
					title = "Row",
					description = "Chips render in a single scrollable row with edge scrims.",
					layoutOrder = 2,
					children = { RowStory { scope = scope, layoutOrder = 2 } },
				},
				StorySection {
					scope = scope,
					title = "Wrap",
					description = "Chips flow onto multiple rows and clip to the group bounds.",
					layoutOrder = 3,
					children = { WrapStory { scope = scope, layoutOrder = 2 } },
				},
			},
		}
	end),
}
