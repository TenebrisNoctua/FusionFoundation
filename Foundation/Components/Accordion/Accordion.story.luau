local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")
local BuilderIcons = PackageManager.getPackage("BuilderIcons")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Accordion = require(script.Parent.Accordion)
local AccordionItem = require(script.Parent.Item)

local View = require(Components.View)
local Text = require(Components.Text)
local Button = require(Components.Button)
local ScrollView = require(Components.ScrollView)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

local StoryMiddleware = require(Utility.Stories.StoryMiddleware)
local StorySection = require(Utility.Stories.StorySection)
local CommonControls = require(Utility.Stories.CommonControls)

local InputSize = require(Enums.InputSize)

type Scope = Types.Scope
type Use = Types.Use
type ItemId = Types.ItemId
type InputSize = InputSize.InputSize

local IconVariant = BuilderIcons.IconVariant

local exampleIcons = {
	"tilt",
	"robux",
	"shopping-basket-check",
	"hat-fedora",
	"",
}

local function content(scope: Scope, omitDynamicContent: boolean?)
	local padding = scope:Value(false)

	local children = {
		Text = Text {
			scope = scope,
			LayoutOrder = 1,
			Text = "Our flagship product combines cutting-edge technology with sleek design.",
			tag = "auto-xy padding-y-small text-body-medium text-wrap text-align-x-left text-align-y-center",
		}
	}

	if not omitDynamicContent then
		children.Button = Button {
			scope = scope,
			LayoutOrder = 2,
			text = "Click to expand!",
			onActivated = function()
				padding:set(not unwrap(padding))
			end,
		}
		children.UIPadding = scope:New "UIPadding" {
			PaddingBottom = scope:Computed(function(use: Use)
				return UDim.new(0, if unwrap(padding, use) then 50 else 0)
			end)
		}
	end

	return View {
		scope = scope,
		tag = "col size-full-0 auto-y",
		children = children,
	}
end

local function PlaygroundStory(props: { scope: Scope, controls: any, layoutOrder: number? })
	local scope = props.scope
	local controls = props.controls

	return scope:Computed(function(use: Use, innerScope: Scope)
		local numItems = unwrap(controls.numItems, use)

		local leadingIcon = innerScope:Computed(function(use: Use)
			local icon = unwrap(controls.icon, use)
			if icon == "" then
				return nil
			end
			return { name = icon, variant = unwrap(controls.iconVariant, use) }
		end)

		return Accordion {
			scope = innerScope,
			width = UDim.new(0, 400),
			size = controls.size,
			LayoutOrder = props.layoutOrder,
			children = function(accordionScope: Scope)
				local items = {}
				for i = 1, numItems do
					items[i] = AccordionItem {
						scope = accordionScope,
						text = `Accordion header {i}`,
						LayoutOrder = i,
						hasDivider = controls.divider,
						leadingIcon = leadingIcon,
						id = i,
						isExpanded = i == 1,
						children = function(itemScope: Scope)
							return { content(itemScope, true) }
						end
					}
				end
				return items
			end
		}
	end)
end

local function ControlledStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	local expandedItem = scope:Value(1 :: ItemId)

	local function handleActivated(item: ItemId, isExpanded: boolean?)
		return function()
			if isExpanded then
				expandedItem:set(-1)
			else
				expandedItem:set(item)
			end
		end
	end

	return Accordion {
		scope = scope,
		width = UDim.new(0, 400),
		onActivated = handleActivated,
		LayoutOrder = props.layoutOrder,
		children = function(accordionScope: Scope)
			local items = {}
			for i = 1, 3 do
				items[i] = AccordionItem {
					scope = accordionScope,
					text = `Controlled Item {i}`,
					LayoutOrder = i,
					id = i,
					isExpanded = scope:Computed(function(use: Use)
						return unwrap(expandedItem, use) == i
					end),
					children = function(itemScope: Scope)
						return { content(itemScope) }
					end
				}
			end
			return items
		end
	}
end

local function ComplexControlledStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	local expandedItems = scope:Value({ 1, 2, 3 } :: { ItemId })

	local function isItemExpanded(use: Use, id: number): boolean
		local current = unwrap(expandedItems, use)
		return table.find(current, id) ~= nil
	end

	local function handleActivated(item: ItemId, isExpanded: boolean?)
		return function()
			local current = unwrap(expandedItems)
			if isExpanded then
				local filtered = {}
				for _, expandedItem in current do
					if expandedItem ~= item then
						table.insert(filtered, expandedItem)
					end
				end
				expandedItems:set(filtered)
			else
				expandedItems:set({ item })
			end
		end
	end

	return Accordion {
		scope = scope,
		width = UDim.new(0, 400),
		onActivated = handleActivated,
		LayoutOrder = props.layoutOrder,
		children = function(accordionScope: Scope)
			return {
				AccordionItem1 = AccordionItem {
					scope = accordionScope,
					text = "All Controlling Item",
					LayoutOrder = 1,
					id = 1,
					onActivated = function()
						local current = unwrap(expandedItems)
						if table.find(current, 1) then
							expandedItems:set({})
						else
							expandedItems:set({ 1, 2, 3 })
						end
					end,
					isExpanded = scope:Computed(function(use: Use)
						return isItemExpanded(use, 1)
					end),
					children = function(itemScope: Scope)
						return { content(itemScope) }
					end
				},
				AccordionItem2 = AccordionItem {
					scope = accordionScope,
					text = "Controlled Item 2",
					LayoutOrder = 2,
					id = 2,
					isExpanded = scope:Computed(function(use: Use)
						return isItemExpanded(use, 2)
					end),
					children = function(itemScope: Scope)
						return { content(itemScope) }
					end
				},
				AccordionItem3 = AccordionItem {
					scope = accordionScope,
					text = "Controlled Item 3",
					LayoutOrder = 3,
					id = 3,
					isExpanded = scope:Computed(function(use: Use)
						return isItemExpanded(use, 3)
					end),
					children = function(itemScope: Scope)
						return { content(itemScope) }
					end
				}
			}
		end
	}
end

local function PartiallyControlledStory(props: { scope: Scope, layoutOrder: number? })
	local scope = props.scope
	local expandedItem = scope:Value(1)

	local function onActivatedFor(item: number)
		return function()
			if unwrap(expandedItem) == item then
				expandedItem:set(0)
			else
				expandedItem:set(item)
			end
		end
	end

	return Accordion {
		scope = scope,
		width = UDim.new(0, 400),
		LayoutOrder = props.layoutOrder,
		children = function(accordionScope: Scope)
			return {
				AccordionItem1 = AccordionItem {
					scope = accordionScope,
					text = "Controlled Item 1",
					LayoutOrder = 1,
					id = 1,
					isExpanded = scope:Computed(function(use: Use)
						return unwrap(expandedItem, use) == 1
					end),
					onActivated = onActivatedFor(1),
					children = function(itemScope: Scope)
						return { content(itemScope) }
					end
				},
				AccordionItem2 = AccordionItem {
					scope = accordionScope,
					text = "Default Item 1",
					LayoutOrder = 2,
					id = 2,
					children = function(itemScope: Scope)
						return { content(itemScope) }
					end
				},
				DefaultItem = AccordionItem {
					scope = accordionScope,
					text = "Default Item 2",
					LayoutOrder = 3,
					id = 3,
					children = function(itemScope: Scope)
						return { content(itemScope) }
					end
				},
				AccordionItem3 = AccordionItem {
					scope = accordionScope,
					text = "Controlled Item 2",
					LayoutOrder = 4,
					id = 4,
					isExpanded = scope:Computed(function(use: Use)
						return unwrap(expandedItem, use) == 4
					end),
					onActivated = onActivatedFor(4),
					children = function(itemScope: Scope)
						return { content(itemScope) }
					end
				}
			}
		end
	}
end

return {
	fusion = Fusion,
	summary = "Accordion",
	controls = {
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = InputSize.Medium,
			List = Dash.values(InputSize),
			DefIndex = 3,
		},
		icon = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = exampleIcons[1],
			List = exampleIcons,
			DefIndex = 1,
		},
		iconVariant = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = IconVariant.Regular,
			List = Dash.values(IconVariant),
			DefIndex = 1,
		},
		numItems = 3,
		divider = true,
		theme = CommonControls.theme
	},
	story = StoryMiddleware(function(props)
		local scope = props.scope
		local controls = props.controls

		return scope:Computed(function(use: Use, innerScope: Scope)
			unwrap(controls.theme, use)

			return ScrollView {
				scope = innerScope,
				tag = "auto-x size-full padding-x-large padding-top-large col",
				scroll = {
					AutomaticCanvasSize = Enum.AutomaticSize.XY,
				},
				children = {
					StorySection {
						scope = innerScope,
						title = "Playground",
						layoutOrder = 1,
						children = { PlaygroundStory { scope = innerScope, controls = controls, layoutOrder = 2 } },
					},
					StorySection {
						scope = innerScope,
						title = "Controlled (one expanded item at a time)",
						layoutOrder = 2,
						children = { ControlledStory { scope = innerScope, layoutOrder = 2 } },
					},
					StorySection {
						scope = innerScope,
						title = "Complex Controlled with unique onActivated",
						layoutOrder = 3,
						children = { ComplexControlledStory { scope = innerScope, layoutOrder = 2 } },
					},
					StorySection {
						scope = innerScope,
						title = "Partially Controlled",
						layoutOrder = 4,
						children = { PartiallyControlledStory { scope = innerScope, layoutOrder = 2 } },
					}
				}
			}
		end)
	end)
}
