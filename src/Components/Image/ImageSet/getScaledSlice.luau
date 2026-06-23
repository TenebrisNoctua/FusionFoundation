local Foundation = script.Parent.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local FoundationImages = PackageManager.getPackage("FoundationImages")
local Types = require(Foundation.Utility.Types.Types)

type Slice = Types.Slice

local function getScaledSlice(sliceCenter: Rect?, sliceScale: number?): Slice
	local scale = FoundationImages.getResolutionScale()

	if sliceCenter then
		local min = sliceCenter.Min * scale
		local max = sliceCenter.Max * scale
		sliceCenter = Rect.new(min, max)
		sliceScale = (sliceScale or 1) / scale
	end

	return {
		center = sliceCenter,
		scale = sliceScale,
	}
end

return getScaledSlice
