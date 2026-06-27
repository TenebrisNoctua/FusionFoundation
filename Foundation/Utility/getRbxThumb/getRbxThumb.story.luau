--!nonstrict

local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")

local Image = require(Foundation.Components.Image)
local View = require(Foundation.Components.View)
local Text = require(Foundation.Components.Text)

local getRbxThumb = require(Foundation.Utility.getRbxThumb)
local unwrap = require(Foundation.Utility.unwrap)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local ThumbnailType = require(Foundation.Enums.ThumbnailType)
local ThumbnailSize = require(Foundation.Enums.ThumbnailSize)
local ControlState = require(Foundation.Enums.ControlState)

type ThumbnailSize = ThumbnailSize.ThumbnailSize
type ControlState = ControlState.ControlState

local ThumbnailValues = Dash.values(ThumbnailType)

return {
	fusion = Fusion,
	summary = "Configurable image with getRbxThumb",
	story = function(props)
		local scope = props.scope
		local theme, cleanup = ThemeProvider(scope)
		table.insert(scope, cleanup)		

		local url = scope:Computed(function(use) 
			return getRbxThumb(unwrap(props.controls.type, use), unwrap(props.controls.id, use), unwrap(props.controls.size, use))
		end)
		
		return View {
			scope = scope :: any,
			AutomaticSize = Enum.AutomaticSize.XY,
			backgroundStyle = {
				Color3 = Color3.fromRGB(25, 26, 31)
			},
			children = {
				scope:New "UIListLayout" {
					FillDirection = Enum.FillDirection.Vertical,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 12)
				},
				
				scope:New "UIPadding" {
					PaddingLeft	= UDim.new(0, 14),
					PaddingRight = UDim.new(0, 14),
					PaddingTop = UDim.new(0, 14),
					PaddingBottom = UDim.new(0, 14)
				},
				
				Image {
					scope = scope,
					backgroundStyle = {
						Color3 = Color3.new(0.815686, 0.85098, 0.984314),
						Transparency = 0.96
					},
					Image = url,
					Size = UDim2.fromOffset(150, 150),
					LayoutOrder = 1
				},
				
				Text {
					scope = scope,
					Text = url,
					AutomaticSize = Enum.AutomaticSize.XY,
					LayoutOrder = 2,
					textStyle = theme:GetStyle("Content", "Default"), 
					backgroundStyle = {
						Transparency = 1	
					},
					children = {
						scope:New "UIPadding" {
							PaddingLeft	= UDim.new(0, 4),
							PaddingRight = UDim.new(0, 4)
						}
					}
				}
			}
		}
	end,
	controls = {
		type = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = ThumbnailValues[1],
			List = ThumbnailValues,
			DefIndex = 1
		},
		id = 1,
		size = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = "Medium",
			List = { ThumbnailSize.Medium :: ThumbnailSize, ThumbnailSize.Large, ThumbnailSize.XLarge, ThumbnailSize.Small },
			DefIndex = 1
		}
	},
}
