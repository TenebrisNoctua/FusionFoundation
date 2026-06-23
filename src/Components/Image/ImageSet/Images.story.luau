--!nonstrict

local Foundation = script.Parent.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")
local FoundationImages = PackageManager.getPackage("FoundationImages")

local Image = require(Foundation.Components.Image)
local View = require(Foundation.Components.View)
local Text = require(Foundation.Components.Text)

local themeProvider = require(Foundation.Utility.themeProvider)

local Children = Fusion.Children
local Images = FoundationImages.Images

local function ImageGridItem(props: {imageName: string, isVisible: boolean, scope: any})
	local imageName = props.imageName
	local isVisible = props.isVisible
	local scope = props.scope
	
	return View {
		scope = scope,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromOffset(120, 0),
		Visible = isVisible,
		backgroundStyle = {
			Color3 = Color3.fromRGB(25, 26, 31)	
		},
		
		children = {
			scope:New "UIListLayout" {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 8)
			},
			
			scope:New "UIPadding" {
				PaddingTop = UDim.new(0, 12),
				PaddingBottom = UDim.new(0, 12),
				PaddingLeft = UDim.new(0, 12),
				PaddingRight = UDim.new(0, 12)
			},
			
			scope:New "UICorner" {
				CornerRadius = UDim.new(0, 8)
			},
			
			Image {
				scope = scope,
				Image = imageName,
				LayoutOrder = 1,
				backgroundStyle = {
					Transparency = 1	
				},
				Size = UDim2.fromOffset(80, 80)
			},
			
			Text {
				scope = scope,
				Text = imageName:match("([^/]+)$") or imageName, -- Extract just the filename
				LayoutOrder = 2,
				AutomaticSize = Enum.AutomaticSize.XY,
				backgroundStyle = {
					Transparency = 1,	
				},
				textStyle = {
					Color3 = Color3.fromRGB(213, 215, 221),
					Transparency = 0
				},
				fontStyle = {
					Font = Enum.Font.BuilderSansMedium,
					LineHeight = 1.11,
					FontSize = 17.6
				},
				TextWrapped = true
			},
			
			Text {
				scope = scope,
				Text = imageName,
				LayoutOrder = 3,
				AutomaticSize = Enum.AutomaticSize.XY,
				backgroundStyle = {
					Transparency = 1,	
				},
				textStyle = {
					Color3 = Color3.fromRGB(213, 215, 221),
					Transparency = 0
				},
				fontStyle = {
					Font = Enum.Font.BuilderSansMedium,
					LineHeight = 1.11,
					FontSize = 12.6
				},
				TextWrapped = true
			},
		}
	}
end

local function capitalizeFirstLetter(str)
	return str:gsub("^%l", string.upper)
end

local function getImagesBySection()
	-- Group images by their top-level directory/section
	local sections = {}

	for imageName, imageDetails in Images do
		-- Extract the first part of the path (before the first '/')
		local section = imageName:match("^([^/]+)") or "other"

		if not sections[section] then
			sections[section] = {}
		end

		table.insert(sections[section], {
			name = imageName,
			details = imageDetails,
		})
	end

	-- Sort images within each section
	for _section, imageList in sections do
		table.sort(imageList, function(a, b)
			return a.name < b.name
		end)
	end

	return sections
end

local function createViewForSection(sectionName, imageList, scope, keywordstate)
	return View {
		scope = scope,
		AutomaticSize = Enum.AutomaticSize.XY,
		children = scope:Computed(function(use, innerScope) 
			local keyword = use(keywordstate)
			
			local gridItems: {Instance} = {
				innerScope:New "UIListLayout" {
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 20),
					Wraps = true
				}
			}

			for _, imageInfo in ipairs(imageList) do
				table.insert(gridItems, ImageGridItem {
					scope = innerScope,
					imageName = imageInfo.name,
					isVisible = if #keyword > 0 then string.find(imageInfo.name, keyword) ~= nil else true
				})
			end

			return gridItems
		end)
	}
end

return {
	fusion = Fusion,
	summary = "Foundation Images organized by section",
	controls = {
		keyword = ""
	},
	story = function(props)
		local scope = props.scope
		local keyword = props.controls.keyword
		
		local sections = getImagesBySection()
		local storyViews = {
			scope:New "UIListLayout" {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 6)
			}
		}

		for sectionName, imageList in sections do
			table.insert(storyViews, Text {
				scope = scope,
				Text = sectionName,
				AutomaticSize = Enum.AutomaticSize.XY,
				fontStyle = {
					Font = Enum.Font.BuilderSansBold,
					FontSize = 25,
				},
				backgroundStyle = {
					Transparency = 1
				},
				textStyle = {
					Color3 = Color3.fromRGB(213, 215, 221),
					Transparency = 0
				}
			})
			table.insert(storyViews, createViewForSection(sectionName, imageList, scope, keyword))
			table.insert(storyViews, scope:New "Frame" {
				BackgroundColor3 = Color3.fromRGB(61, 61, 61),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 2)
			})
		end
		
		return View {
			scope = props.scope,
			AutomaticSize = Enum.AutomaticSize.XY,
			children = storyViews
		}
	end
}