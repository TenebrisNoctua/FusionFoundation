--!nonstrict

local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")
local Assets = PackageManager.getPackage("FoundationCloudAssets").Assets

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local View = require(Components.View)
local Text = require(Components.Text)
local Image = require(Components.Image)
local ScrollView = require(Components.ScrollView)

local unwrap = require(Utility.unwrap)
local getRbxThumb = require(Utility.getRbxThumb)

local StorySection = require(Utility.Stories.StorySection)
local StoryMiddleware = require(Utility.Stories.StoryMiddleware)

local ControlState = require(Enums.ControlState)
local ThumbnailType = require(Enums.ThumbnailType)
local ThumbnailSize = require(Enums.ThumbnailSize)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

type ControlState = ControlState.ControlState
type ThumbnailSize = ThumbnailSize.ThumbnailSize

local AssetKeys = Dash.keys(Assets)

local function AssetStory(scope, layoutOrder)
	local theme = ThemeProvider()
	local tokens = unwrap(theme.Tokens)
	
	return View {
		scope = scope,
		backgroundStyle = {
			Transparency = 0.5,
		},
		tag = "col gap-large auto-xy padding-small",
		LayoutOrder = layoutOrder,
		children = {
			Image {
				scope = scope,
				Image = "rbxassetid://7229442422",
				backgroundStyle = tokens.Color.Extended.White.White_100,
				tag = "size-2800"
			},
			
			Image {
				scope = scope,
				Image = "component_assets/circle_22_stroke_3",
				slice = {
					center = Rect.new(11, 11, 12, 12),
				},
				backgroundStyle = tokens.Color.Extended.White.White_0,
				tag = "col align-x-center align-y-center size-2800-800",
				children = {
					Text {
						scope = scope,
						Text = "Slice Center",
						AutomaticSize = Enum.AutomaticSize.XY,
						textStyle = tokens.Color.Content.Emphasis
					}
				}
			}
		}
	}
end

local function StoryGuiState(scope, layoutOrder)
	local guiState = scope:Value(ControlState.Initialize)
	local theme = ThemeProvider()
	local tokens = unwrap(theme.Tokens)
	
	local function onStateChanged(new: ControlState)
		guiState:set(new)
	end
	
	return Image {
		scope = scope,
		Image = scope:Computed(function(use) 
			local state = unwrap(guiState, use)
			if state == ControlState.Default then
				return getRbxThumb(ThumbnailType.Asset, 23155839, ThumbnailSize.Large)
			elseif state == ControlState.Hover then
				return getRbxThumb(ThumbnailType.Asset, 23155842, ThumbnailSize.Large)
			elseif state == ControlState.Pressed then
				return getRbxThumb(ThumbnailType.Asset, 23155847, ThumbnailSize.Large)
			end
			return getRbxThumb(ThumbnailType.Asset, 23155833, ThumbnailSize.Large)
		end),
		backgroundStyle = tokens.Color.Extended.Purple.Purple_500,
		tag = "col align-x-center align-y-center size-2800",
		onStateChanged = onStateChanged,
		LayoutOrder = layoutOrder
	}
end

local function ImageSliceWithChildren(scope, layoutOrder)
	local theme = ThemeProvider()
	local tokens = unwrap(theme.Tokens)
	
	return Image {
		scope = scope,
		tag = "auto-xy",
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
				tag = "gap-large auto-xy",
				padding = {
					top = UDim.new(0, 30),
					bottom = UDim.new(0, 40),
					left = UDim.new(0, 64),
					right = UDim.new(0, 32),
				},
				children = {
					View {
						scope = scope,
						LayoutOrder = 1,
						tag = "size-1500",
						children = {
							Image {
								scope = scope,
								Image = "component_assets/circle_36",
								Size = UDim2.fromOffset(60, 60),
								imageStyle = unwrap(theme.Tokens).Color.None,
								ZIndex = 0,
								tag = "position-center-center anchor-center-center"
							},
							
							Image {
								scope = scope,
								Image = "component_assets/circle_36",
								Size = UDim2.fromOffset(60, 60),
								imageStyle = unwrap(theme.Tokens).Color.None,
								scale = 1,
								ZIndex = 1,
								tag = "position-center-center anchor-center-center"
							},
							
							Image {
								scope = scope,
								Image = "icons/controls/speaker",
								Size = UDim2.fromOffset(32, 32),
								imageStyle = tokens.Color.Extended.Gray.Gray_300,
								ZIndex = 2,
								tag = "position-center-center anchor-center-center"
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
	story = StoryMiddleware(function(props)
		local scope = props.scope
		local cloudAsset = props.controls.cloudAsset
		
		return ScrollView {
			scope = scope,
			tag = "col size-full",
			scroll = {
				AutomaticCanvasSize = Enum.AutomaticSize.XY	
			},
			children = {
				StorySection {
					scope = scope,
					title = "Basic Image",
					children = {
						Image {
							scope = scope,
							Image = "icons/graphic/success_xlarge",
							tag = "size-2800",
							LayoutOrder = 2
						}
					}
				},
				
				StorySection {
					scope = scope,
					title = "Basic Asset Use",
					layoutOrder = 2,
					children = {
						AssetStory(scope, 2)
					}
				},
				
				StorySection {
					scope = scope,
					title = "GUI State Use",
					layoutOrder = 3,
					children = {
						StoryGuiState(scope, 2)
					}
				},
				
				StorySection {
					scope = scope,
					title = "Custom 9-slice Image",
					layoutOrder = 4,
					children = {
						ImageSliceWithChildren(scope, 2)
					}
				},
				
				StorySection {
					scope = scope,
					title = "Cloud Asset",
					layoutOrder = 5,
					children = {
						Image {
							scope = scope,
							Image = props.controls.cloudAsset,
							Size = UDim2.fromOffset(300, 300),
							tag = "content-emphasis",
							LayoutOrder = 2
						}
					}
				}
			}
		}
	end),
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