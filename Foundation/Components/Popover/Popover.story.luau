--!nonstrict

local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Popover = require(script.Parent)
local PopoverAnchor = Popover.Anchor
local PopoverContent = Popover.Content
local useMeasurableRef = require(script.Parent.useMeasurableRef)

local View = require(Components.View)
local Button = require(Components.Button)
local Text = require(Components.Text)

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)
local StoryMiddleware = require(Utility.Stories.StoryMiddleware)

local InputSize = require(Enums.InputSize)
local PopoverAlign = require(Enums.PopoverAlign)
local PopoverSide = require(Enums.PopoverSide)
local Radius = require(Enums.Radius)
local StateLayerAffordance = require(Enums.StateLayerAffordance)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

type Scope = Types.Scope
type Use = Types.Use

-- Originally this was required because of Storybook, but UILabs is capable of handling it the same way just fine.
local backgroundStyleOrderedKeys = { "Default", "Surface_0", "Surface_200", "ActionAlert" }

local function getBackgroundStyle(scope: Scope, theme, keyControl): any
	return scope:Computed(function(use: Use)
		local key = unwrap(keyControl, use)
		if key == "Default" then return nil end
		local tokens = unwrap(theme.Tokens, use)
		return ({
			Default = nil,
			Surface_0 = tokens.Color.Surface.Surface_0,
			Surface_200 = tokens.Color.Surface.Surface_200,
			ActionAlert = tokens.Color.ActionAlert.Background,
		})[key]
	end)
end

local function StoryBasic(props)
	local scope = props.scope
	local theme = props.theme
	local controls = props.controls

	local anchor = scope:Value(nil)
	local function setAnchor(instance)
		anchor:set(instance)
	end
	
	local isOpen = scope:Value(true)
	local backgroundStyle = getBackgroundStyle(scope, theme, controls.backgroundStyle)

	return View {
		scope = scope,
		Size = UDim2.new(1, 0, 0, 1000),
		tag = "row align-x-center align-y-center",
		LayoutOrder = props.layoutOrder,
		children = {
			PopoverAnchor {
				scope = scope,
				anchor = anchor,
				setAnchor = setAnchor,
				isOpen = isOpen,
				children = {
					View {
						scope = scope,
						tag = "col gap-large auto-xy padding-large stroke-neutral radius-medium bg-surface-100",
						backgroundStyle = {
							Transparency = 0	
						},
						children = {
							Text {
								scope = scope,
								Text = "I am a card",
								tag = "auto-xy text-heading-medium",
							},
							Button {
								scope = scope,
								text = "Just a button!",
								size = InputSize.Medium,
								onActivated = function()
									print("Button activated")
								end,
							},
						}
					}
				}
			},
			PopoverContent {
				scope = scope,
				anchor = anchor,
				isOpen = isOpen,
				align = controls.align,
				side = controls.side,
				backgroundStyle = backgroundStyle,
				radius = controls.radius,
				children = {
					View {
						scope = scope,
						tag = "col gap-small auto-xy padding-medium",
						children = {
							Text {
								scope = scope,
								Text = "Tooltip Title",
								tag = "auto-xy text-title-medium content-emphasis",
							},
							Text {
								scope = scope,
								Text = "Here's the tooltip's subtitle and content.",
								tag = "auto-xy text-body-small",
							},
						}
					}
				}
			}
		}
	}
end

local function StoryClickOutside(props)
	local scope = props.scope
	local controls = props.controls

	local anchor = scope:Value(nil)
	local function setAnchor(instance)
		anchor:set(instance)
	end
	local open = scope:Value(false)

	return View {
		scope = scope,
		tag = "row align-x-center align-y-center size-full-0 auto-y",
		LayoutOrder = props.layoutOrder,
		children = {
			PopoverAnchor {
				scope = scope,
				anchor = anchor,
				setAnchor = setAnchor,
				isOpen = open,
				children = {
					View {
						scope = scope,
						tag = "col gap-large auto-xy padding-large stroke-neutral radius-medium bg-surface-100",
						backgroundStyle = {
							Transparency = 0	
						},
						children = {
							Text {
								scope = scope,
								Text = "I am a card",
								tag = "auto-xy text-heading-medium",
							},
							Button {
								scope = scope,
								text = "Click me to toggle!",
								size = InputSize.Medium,
								onActivated = function()
									open:set(not unwrap(open))
								end,
							},
						}
					}
				}
			},
			PopoverContent {
				scope = scope,
				anchor = anchor,
				isOpen = open,
				align = controls.align,
				side = controls.side,
				onPressedOutside = function()
					open:set(false)
				end,
				children = {
					View {
						Name = "ContentFrame",
						scope = scope,
						tag = "col gap-small auto-xy padding-medium",
						children = {
							Text {
								scope = scope,
								Text = "Click outside example",
								tag = "auto-xy text-title-medium content-emphasis",
							},
							Text {
								scope = scope,
								Text = "Click anywhere outside to close this",
								tag = "auto-xy text-body-small",
							},
						}
					}
				}
			},
		}
	}
end

--[[
	Foundation components return a Computed object which upon evaluation, returns an Instance.
	This is normally fine, as Fusion automatically evaluates the result of the Computed objects, and builds the component tree.
	
	However, in Popover, we must evaluate the result of the Computed object manually, so we can pass this Instance to be used
	as an anchor. This can be achieved pretty easily by calling unwrap with the component result.
]]

local function StoryAnchorRef(props)
	local scope = props.scope
	local controls = props.controls

	local anchor = scope:Value(nil)
	local function setAnchor(instance)
		anchor:set(instance)
	end
	local open = scope:Value(false)

	local buttonInstance = unwrap(Button {
		scope = scope,
		text = "Click me to toggle!",
		size = InputSize.Medium,
		onActivated = function()
			open:set(not unwrap(open))
		end
	})

	return View {
		scope = scope,
		Size = UDim2.new(1, 0, 0, 300),
		tag = "row align-x-center align-y-center",
		LayoutOrder = props.layoutOrder,
		children = {
			buttonInstance,
			PopoverAnchor {
				scope = scope,
				anchor = anchor,
				setAnchor = setAnchor,
				isOpen = open,
				anchorInstance = buttonInstance,
			},
			PopoverContent {
				scope = scope,
				anchor = anchor,
				isOpen = open,
				align = controls.align,
				side = controls.side,
				onPressedOutside = function()
					open:set(false)
				end,
				children = {
					View {
						scope = scope,
						tag = "col gap-small auto-xy padding-medium",
						children = {
							Text {
								scope = scope,
								Text = "Anchor Reference Example",
								tag = "auto-xy text-title-medium content-emphasis",
							},
							Text {
								scope = scope,
								Text = "This popover is anchored to a button using anchorInstance",
								tag = "auto-xy text-body-small",
							},
						}
					}
				}
			},
		}
	}
end

--[[ The TextInput component has not been converted yet, so this story is unavailable.
local function StoryKeyboardAware(props)
	local scope = props.scope
	local controls = props.controls

	local anchor = scope:Value(nil)
	local function setAnchor(instance)
		anchor:set(instance)
	end
	local open = scope:Value(false)

	return View {
		scope = scope,
		tag = "col align-x-center align-y-center gap-large size-full-0 auto-y",
		LayoutOrder = props.layoutOrder,
		children = {
			Text {
				scope = scope,
				Text = "Focus the input field to test keyboard-aware positioning",
				tag = "auto-xy text-body-medium content-emphasis",
				padding = {
					bottom = UDim.new(0, 500),
				},
			},
			PopoverAnchor {
				scope = scope,
				anchor = anchor,
				setAnchor = setAnchor,
				isOpen = open,
				children = {
					View {
						scope = scope,
						tag = "col gap-medium auto-xy",
						children = {
							Button {
								scope = scope,
								text = scope:Computed(function(use: Use)
									return if unwrap(open, use) then "Close Popover" else "Open Popover"
								end),
								size = InputSize.Medium,
								onActivated = function()
									open:set(not unwrap(open))
								end,
							},
						}
					}
				}
			},
			PopoverContent {
				scope = scope,
				anchor = anchor,
				isOpen = open,
				side = PopoverSide.Bottom,
				align = PopoverAlign.Start,
				onPressedOutside = function()
					open:set(false)
				end,
				children = {
					View {
						scope = scope,
						tag = "col gap-small auto-xy padding-medium",
						Size = UDim2.fromOffset(300, 0),
						children = {
							Text {
								scope = scope,
								Text = "Keyboard-Aware Popover",
								tag = "auto-xy text-title-medium content-emphasis",
							},
							Text {
								scope = scope,
								Text = "This popover should avoid the on-screen keyboard on touch devices.",
								tag = "auto-xy text-body-small",
							},
						}
					}
				}
			},
		}
	}
end
]]

local function StoryMousePositionTooltip(props)
	local scope = props.scope
	local controls = props.controls

	local anchor = scope:Value(nil)
	local function setAnchor(instance)
		anchor:set(instance)
	end
	local open = scope:Value(false)
	local virtualRef = useMeasurableRef(scope, Vector2.zero)

	local viewInstance = unwrap(View {
		scope = scope,
		tag = "row auto-xy align-x-center align-y-center size-full-3000 bg-surface-200 padding-medium",
		backgroundStyle = {
			Transparency = 0	
		},
		LayoutOrder = props.layoutOrder,
		children = {
			Text {
				scope = scope,
				Text = "Move the mouse over this area to see a tooltip",
				tag = "text-align-x-center auto-xy",
			},
			PopoverAnchor {
				scope = scope,
				anchor = anchor,
				setAnchor = setAnchor,
				isOpen = open,
				anchorInstance = virtualRef,
			},
			PopoverContent {
				scope = scope,
				anchor = anchor,
				isOpen = open,
				align = controls.align,
				side = controls.side,
				children = {
					View {
						scope = scope,
						tag = "col gap-small auto-xy padding-medium",
						children = {
							Text {
								scope = scope,
								Text = "Can't close unless you are in the area",
								tag = "auto-xy text-title-medium content-emphasis",
							},
						}
					}
				}
			},
		}
	})
	
	local mouseMoveConnection = viewInstance.MouseMoved:Connect(function(x, y)
		unwrap(virtualRef):SetPosition(Vector2.new(x, y))
		open:set(true)
	end)
	
	local mouseLeaveConnection = viewInstance.MouseLeave:Connect(function()
		open:set(false)
	end)
	
	table.insert(scope, function()
		mouseMoveConnection:Disconnect()
		mouseLeaveConnection:Disconnect()
	end)

	return viewInstance
end

local function StoryContextMenu(props)
	local scope = props.scope
	local controls = props.controls

	local anchor = scope:Value(nil)
	local function setAnchor(instance)
		anchor:set(instance)
	end
	local open = scope:Value(false)
	local virtualRef = useMeasurableRef(scope, Vector2.zero)

	local viewInstance = unwrap(View {
		Name = "test",
		scope = scope,
		tag = "align-x-center align-y-center size-full-3000 bg-surface-200 padding-medium",
		LayoutOrder = props.layoutOrder,
		stateLayer = {
			affordance = StateLayerAffordance.None,
		},
		backgroundStyle = {
			Color3 = Color3.fromRGB(163, 162, 165)	
		},
		onActivated = function() end,
		children = {
			Text {
				scope = scope,
				Text = "Right-click on this area to open the context menu.",
				tag = "size-full-full text-align-x-center",
			},
			PopoverAnchor {
				scope = scope,
				anchor = anchor,
				setAnchor = setAnchor,
				isOpen = open,
				anchorInstance = virtualRef,
			},
			PopoverContent {
				scope = scope,
				anchor = anchor,
				isOpen = open,
				align = controls.align,
				side = controls.side,
				onPressedOutside = function()
					open:set(false)
				end,
				children = {
					View {
						scope = scope,
						tag = "col gap-small auto-xy padding-medium",
						children = {
							Text {
								scope = scope,
								Text = "Context Menu",
								tag = "auto-xy text-title-medium content-emphasis",
							},
							Text {
								scope = scope,
								Text = "Right-click functionality enabled.",
								tag = "auto-xy text-body-small",
							},
						}
					}
				}
			},
		}
	})
	
	local mouseButtonRightConnection = viewInstance.MouseButton2Up:Connect(function(x, y)
		unwrap(virtualRef):SetPosition(Vector2.new(x, y))
		open:set(true)
	end)
	
	table.insert(scope, function()
		mouseButtonRightConnection:Disconnect()
	end)

	return viewInstance
end

return {
	fusion = Fusion,
	controls = {
		side = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(PopoverSide)[1],
			List = Dash.values(PopoverSide),
			DefIndex = 1
		},
		align = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Dash.values(PopoverAlign)[1],
			List = Dash.values(PopoverAlign),
			DefIndex = 1
		},
		radius = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = Radius.Medium,
			List = { Radius.Small, Radius.Medium, Radius.Circle },
			DefIndex = 2
		},
		backgroundStyle = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = backgroundStyleOrderedKeys[1],
			List = backgroundStyleOrderedKeys,
			DefIndex = 1
		},
	},
	story = StoryMiddleware(function(props)
		local scope = props.scope
		local controls = props.controls

		local theme = ThemeProvider()

		return View {
			scope = scope,
			backgroundStyle = {
				Transparency = 1
			},
			tag = "auto-xy",
			children = {
				scope:New "UIListLayout" {
					Padding = UDim.new(0, 16),
					SortOrder = Enum.SortOrder.LayoutOrder,
				},

				StoryBasic {
					scope = scope,
					theme = theme,
					controls = controls,
					layoutOrder = 1
				},
				
				StoryClickOutside {
					scope = scope,
					controls = controls,
					layoutOrder = 2
				},
				
				StoryAnchorRef {
					scope = scope,
					controls = controls,
					layoutOrder = 3
				},
				
				--[[
				StoryKeyboardAware {
					scope = scope,
					controls = controls,
					layoutOrder = 4
				},
				--]]

				StoryMousePositionTooltip {
					scope = scope,
					controls = controls,
					layoutOrder = 5
				},
				
				StoryContextMenu {
					scope = scope,
					controls = controls,
					layoutOrder = 6
				},
			}
		}
	end),
}