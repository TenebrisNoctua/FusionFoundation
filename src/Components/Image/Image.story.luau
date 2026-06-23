--!nonstrict

local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")
local Assets = PackageManager.getPackage("FoundationCloudAssets").Assets

local Children = Fusion.Children

local Image = require(Foundation.Components.Image)
local View = require(Foundation.Components.View)
local Text = require(Foundation.Components.Text)

local themeProvider = require(Foundation.Utility.themeProvider)
local getRbxThumb = require(Foundation.Utility.getRbxThumb)

local ControlState = require(Foundation.Enums.ControlState)
local ThumbnailType = require(Foundation.Enums.ThumbnailType)
local ThumbnailSize = require(Foundation.Enums.ThumbnailSize)

type ControlState = ControlState.ControlState
type ThumbnailSize = ThumbnailSize.ThumbnailSize

local AssetKeys = Dash.keys(Assets)

local function AssetStory(scope, layoutOrder)
	local theme = themeProvider(scope)
	return View {
		scope = scope,
		AutomaticSize = Enum.AutomaticSize.XY,
		backgroundStyle = {
			Transparency = 0.5,
		},
		LayoutOrder = layoutOrder,
		children = {
			scope:New "UIListLayout" {
				FillDirection = Enum.FillDirection.Vertical,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 16)
			},
			
			scope:New "UIPadding" {
				PaddingLeft	= UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 8),
				PaddingBottom = UDim.new(0, 8)
			},
			
			Image {
				scope = scope,
				Image = "rbxassetid://7229442422",
				backgroundStyle = theme:GetStyle("Extended", "White", "White_100"),
				Size = UDim2.new(0, 112, 0, 112)
			},
			
			Image {
				scope = scope,
				Image = "component_assets/circle_22_stroke_3",
				slice = {
					center = Rect.new(11, 11, 12, 12),
				},
				backgroundStyle = theme:GetStyle("Extended", "White", "White_0"),
				Size = UDim2.new(0, 112, 0, 32),
				children = {
					scope:New "UIListLayout" {
						FillDirection = Enum.FillDirection.Vertical,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder
					},
					
					Text {
						scope = scope,
						Text = "Slice Center",
						AutomaticSize = Enum.AutomaticSize.XY,
						backgroundStyle = {
							Transparency = 1
						},
						fontStyle = {
							FontSize = 20	
						},
						textStyle = theme:GetStyle("Content", "Emphasis")
					}
				}
			}
		}
	}
end

local function StoryGuiState(scope, layoutOrder)
	local guiState = scope:Value(ControlState.Initialize)
	local theme = themeProvider(scope)
	
	local function onStateChanged(new: ControlState)
		guiState:set(new)
	end
	
	return Image {
		scope = scope,
		Image = scope:Computed(function(use) 
			local state = use(guiState)
			if state == ControlState.Default then
				return getRbxThumb(ThumbnailType.Asset, 23155839, ThumbnailSize.Large)
			elseif state == ControlState.Hover then
				return getRbxThumb(ThumbnailType.Asset, 23155842, ThumbnailSize.Large)
			elseif state == ControlState.Pressed then
				return getRbxThumb(ThumbnailType.Asset, 23155847, ThumbnailSize.Large)
			end
			return getRbxThumb(ThumbnailType.Asset, 23155833, ThumbnailSize.Large)
		end),
		Size = UDim2.new(0, 112, 0, 112),
		backgroundStyle = theme:GetStyle("Extended", "Purple", "Purple_500"),
		onStateChanged = onStateChanged,
		LayoutOrder = layoutOrder,
		children = {
			scope:New "UIListLayout" {
				FillDirection = Enum.FillDirection.Vertical,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder
			}
		}
	}
end

local function ImageSliceWithChildren(scope, layoutOrder)
	local theme = themeProvider(scope)
	return Image {
		scope = scope,
		AutomaticSize = Enum.AutomaticSize.XY,
		slice = {
			center = Rect.new(52, 24, 66, 32),
			scale = 1,
		},
		backgroundStyle = {
			Transparency = 1,
		},
		Image = "rbxassetid://78323814447735",
		ScaleType = Enum.ScaleType.Slice,
		LayoutOrder = layoutOrder,
		children = {
			View {
				scope = scope,
				AutomaticSize = Enum.AutomaticSize.XY,
				padding = {
					top = UDim.new(0, 30),
					bottom = UDim.new(0, 40),
					left = UDim.new(0, 64),
					right = UDim.new(0, 32),
				},
				children = {
					scope:New "UIListLayout" {
						Padding = UDim.new(0, 16),
						SortOrder = Enum.SortOrder.LayoutOrder
					},
					
					View {
						scope = scope,
						LayoutOrder = 1,
						Size = UDim2.fromOffset(60, 60),
						children = {
							Image {
								scope = scope,
								Image = "component_assets/circle_36",
								Size = UDim2.fromOffset(60, 60),
								imageStyle = theme:GetTokenData("Color", "None"),
								ZIndex = 0,
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.new(0.5, 0, 0.5, 0),
								backgroundStyle = {
									Transparency = 1
								}
							},
							
							Image {
								scope = scope,
								Image = "component_assets/circle_36",
								Size = UDim2.fromOffset(60, 60),
								imageStyle = theme:GetTokenData("Color", "None"),
								scale = 1,
								ZIndex = 1,
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.new(0.5, 0, 0.5, 0),
								backgroundStyle = {
									Transparency = 1
								}
							},
							
							Image {
								scope = scope,
								Image = "icons/controls/speaker",
								Size = UDim2.fromOffset(32, 32),
								imageStyle = theme:GetStyle("Extended", "Gray", "Gray_300"),
								ZIndex = 2,
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.new(0.5, 0, 0.5, 0),
								backgroundStyle = {
									Transparency = 1
								}
							}
						}
					}
				}
			}
		}
	}
end

return {
	fusion = Fusion,
	story = function(props)
		local scope = props.scope
		local cloudAsset = props.controls.cloudAsset
		
		return View {
			scope = scope,
			AutomaticSize = Enum.AutomaticSize.XY,
			children = {
				scope:New "UIListLayout" {
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 4)
				},
				
				Image {
					scope = scope,
					Image = "icons/graphic/success_xlarge",
					Size = UDim2.fromOffset(112, 112),
					backgroundStyle = {
						Transparency = 1	
					},
					LayoutOrder = 1
				},
				
				AssetStory(scope, 2),
				StoryGuiState(scope, 3),
				ImageSliceWithChildren(scope, 4),
				
				Image {
					scope = scope,
					Image = props.controls.cloudAsset,
					Size = UDim2.fromOffset(300, 300),
					backgroundStyle = {
						Transparency = 1	
					},
					imageStyle = {
						Color3 = Color3.fromRGB(247, 247, 248),
						Transparency = 0
					},
					LayoutOrder = 5
				}
			}
		}
	end,
	controls = {
		cloudAsset = {
			EntryType = "Control",
			Type = "Choose",
			ControlValue = AssetKeys[1],
			List = AssetKeys,
			DefIndex = 1
		}
	}
}