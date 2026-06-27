--!nonstrict

local Foundation = script.Parent.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local FoundationImages = PackageManager.getPackage("FoundationImages")

local Image = require(Foundation.Components.Image)
local View = require(Foundation.Components.View)
local Text = require(Foundation.Components.Text)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local Images = FoundationImages.Images

local function ImageGridItem(props: {imageName: string, isVisible: boolean, scope: any})
	local imageName = props.imageName
	local isVisible = props.isVisible
	local scope = props.scope

	return View {
		scope = scope,
		tag = "col align-x-center align-y-center gap-small size-3000-0 auto-y padding-medium radius-medium bg-surface-100",
		Visible = isVisible,
		children = {
			Image {
				scope = scope,
				Image = imageName,
				LayoutOrder = 1,
				tag = "size-2000-2000",
			},

			Text {
				scope = scope,
				Text = imageName:match("([^/]+)$") or imageName, -- Extract just the filename
				LayoutOrder = 2,
				tag = "size-full-0 auto-xy text-caption-large text-wrap content-default"
			},

			Text {
				scope = scope,
				Text = imageName,
				LayoutOrder = 3,
				tag = "size-full-0 auto-xy text-caption-small text-wrap content-default"
			}
		}
	}
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
		tag = "row wrap gap-xlarge size-full-0 auto-y",
		children = scope:Computed(function(use, innerScope) 
			local keyword = use(keywordstate)
			local gridItems: {Instance} = {}

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

		local theme, cleanup = ThemeProvider()
		table.insert(scope, cleanup)

		local sections = getImagesBySection()
		local storyViews = {
			scope:New "StyleLink" {
				StyleSheet = theme.RegistryStyleSheet
			}
		}

		for sectionName, imageList in sections do
			table.insert(storyViews, Text {
				scope = scope,
				Text = sectionName,
				tag = "auto-xy"
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
			tag = "column auto-xy",
			children = storyViews
		}
	end
}