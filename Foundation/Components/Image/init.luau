local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Dash = PackageManager.getPackage("Dash")
local FoundationImages = PackageManager.getPackage("FoundationImages")
local FoundationCloudAssets = PackageManager.getPackage("FoundationCloudAssets")

local Utility = Foundation.Utility
local TypesSource = Utility.Types

local Assets = FoundationCloudAssets.Assets
local Images = FoundationImages.Images

local Interactable = require(script.Parent.Interactable)

local getScaledSlice = require(script.ImageSet.getScaledSlice)
local isFoundationImage = require(script.ImageSet.isFoundationImage)
local isCloudAsset = require(script.CloudAsset.isCloudAsset)

local withDefaults = require(Utility.withDefaults)
local withGuiObjectProps = require(Utility.withGuiObjectProps)
local useDefaultTags = require(Utility.useDefaultTags)
local stripProps = require(Utility.stripProps)
local unwrap = require(Utility.unwrap)
local GuiObjectChildren = require(Utility.GuiObjectChildren)
local Types = require(TypesSource.Types)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)
local useStyleTags = require(Foundation.Providers.ThemeProvider.useStyleTags)

local Children = Fusion.Children
local OnChange = Fusion.OnChange
local Tag = Fusion.Tag

local COMPONENT_ONLY_PROPERTIES = {
	"slice",
	"imageRect",
	"imageStyle",
	"aspectRatio",
	"scale",
	"ResampleMode",
	"ScaleType",
	"TileSize",
	"Image",
	"isDisabled",
	"onActivated",
	"onSecondaryActivated",
	"onStateChanged",
	"AutoButtonColor",
	"stateLayer",
	"selection",
	"Thickness"
}

local defaultProps = {
	AutoLocalize = false,
	AutoButtonColor = false,
	BorderSizePixel = 0,
	isDisabled = false,
}

local function getAspectRatio(size: Vector2)
	return size.X / size.Y
end

local function shouldUseFoundationSlice(image: string): boolean
	if not isFoundationImage(image) then
		return false
	end
	return isCloudAsset(image) or Images[image] ~= nil
end

local DEFAULT_TAGS = "gui-object-defaults"
local DEFAULT_TAGS_WITH_BG = `{DEFAULT_TAGS} x-default-transparency`

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use
type Child = Types.Child

type ImageSetImage = {
	ImageRectOffset: Vector2,
	ImageRectSize: Vector2,
	Image: string,
}

type ColorStyle = Types.ColorStyle

type Slice = Types.Slice
type StateChangedCallback = Types.StateChangedCallback

export type ImageRect = {
	offset: UsedAs<Vector2>?,
	size: UsedAs<Vector2>?,
}

export type ImageProps = {
	slice: Slice?,
	imageRect: ImageRect?,
	imageStyle: ColorStyle?,

	Image: UsedAs<string>?,
	ResampleMode: UsedAs<Enum.ResamplerMode>?,
	ScaleType: UsedAs<Enum.ScaleType>?,
	TileSize: UsedAs<UDim2>?,
} & Types.GuiObjectProps & Types.CommonProps

return function(imageProps: ImageProps): UsedAs<ImageButton | ImageLabel>
	local Scope = imageProps.scope
	local Theme = ThemeProvider()
	assert(Scope, "A scope has not been provided for the Image component.")
	
	local props = withDefaults(imageProps, defaultProps)
	local isInteractable = props.onStateChanged ~= nil or props.onActivated ~= nil or props.onSecondaryActivated ~= nil
	local image, imageRectOffset, imageRectSize, aspectRatio = Scope:Value(nil), Scope:Value(nil), Scope:Value(nil), Scope:Value(nil)
	local sliceCenter, sliceScale, scaleType = Scope:Value(nil), Scope:Value(nil), nil
	local defaultTags = if props.backgroundStyle ~= nil then DEFAULT_TAGS_WITH_BG else DEFAULT_TAGS
	
	local tagsWithDefaults = useDefaultTags(Scope, props.tag, defaultTags)
	local tag = useStyleTags(Scope, tagsWithDefaults, Theme.AddTags)
	props.tag = unwrap(tag)
	
	local function setImageData()
		local imageData = unwrap(props.Image)
		local imageRectOffsetData = if props.imageRect then props.imageRect.offset else nil
		local imageRectSizeData = if props.imageRect then props.imageRect.size else nil

		aspectRatio:set(props.aspectRatio)
		
		if isFoundationImage(imageData) then
			if isCloudAsset(imageData) then
				local asset = Assets[imageData]
				image:set(asset.assetId)
				aspectRatio:set(getAspectRatio(asset.size))
			else
				local asset = Images[imageData]
				if asset then
					image:set(asset.Image)
					imageRectOffset:set(asset.ImageRectOffset)
					imageRectSize:set(asset.ImageRectSize)
				end
			end
		else
			image:set(imageData)
			imageRectOffset:set(imageRectOffsetData)
			imageRectSize:set(imageRectSizeData)
		end
	end
	
	setImageData()
	
	if unwrap(props.Image) ~= props.Image then
		Scope:Observer(props.Image):onChange(setImageData)
	end
	
	if props.slice then
		local imageData = unwrap(props.Image)
		if isFoundationImage(imageData) then
			local slice = getScaledSlice(props.slice.center, props.slice.scale)
			sliceCenter:set(slice.center)
			sliceScale:set(slice.scale)
		else
			sliceCenter:set(props.slice.center)
			sliceScale:set(props.slice.scale)
		end
		scaleType = Enum.ScaleType.Slice
	end
	
	props.aspectRatio = unwrap(aspectRatio)
	
	return Scope:Computed(function(use: Use, innerScope: Scope) 
		local engineComponent = if isInteractable then "ImageButton" else "ImageLabel"
		local engineComponentProps = withGuiObjectProps(props, {
			AutoButtonColor = if engineComponent == "ImageButton" then props.AutoButtonColor else nil,
			Image = image,
			ImageColor3 = if props.imageStyle then unwrap(props.imageStyle, use).Color3 else nil,
			ImageTransparency = if props.imageStyle then unwrap(props.imageStyle, use).Transparency else nil,
			ImageRectOffset = if unwrap(imageRectOffset, use) then imageRectOffset else nil,
			ImageRectSize = if unwrap(imageRectSize, use) then imageRectSize else nil,
			ResampleMode = props.ResampleMode,
			ScaleType = scaleType,
			SliceCenter = if unwrap(sliceCenter, use) then sliceCenter else nil,
			SliceScale = if unwrap(sliceScale, use) then sliceScale else nil,
			TileSize = props.TileSize
		})
		
		if isInteractable then
			local imageComponentProps = {
				scope = Scope,
				component = engineComponent,
				onActivated = props.onActivated,
				onSecondaryActivated = props.onSecondaryActivated,
				onStateChanged = props.onStateChanged,
				stateLayer = props.stateLayer,
				isDisabled = props.isDisabled,
				cursor = props.cursor,
				
				[Children] = GuiObjectChildren(props)
			}
			
			local combinedProps = Dash.union(engineComponentProps, imageComponentProps)
			return innerScope:Hydrate(Interactable(combinedProps))(stripProps(props, COMPONENT_ONLY_PROPERTIES))
		else
			return innerScope:Hydrate(innerScope:New(engineComponent)(Dash.join(engineComponentProps, {[Children] = GuiObjectChildren(props)})))(stripProps(props, COMPONENT_ONLY_PROPERTIES))
		end
	end)
end