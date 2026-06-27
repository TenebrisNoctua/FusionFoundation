local Foundation = script.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")
local Types = require(Foundation.Utility.Types.Types)

type UsedAs<T> = Types.UsedAs<T>
type AspectRatio = Types.AspectRatio
type AspectRatioTable = Types.AspectRatioTable

export type AspectRatioProps = {
	scope: Types.Scope,
	value: AspectRatio,
}

local function getAspectRatio(aspectRatio: AspectRatio): {
	AspectRatio: UsedAs<number>,
	AspectType: UsedAs<Enum.AspectType>?,
	DominantAxis: UsedAs<Enum.DominantAxis>?,
}
	if typeof(aspectRatio) == "table" then
		local aspectRatioTable = aspectRatio :: AspectRatioTable
		return {
			AspectRatio = aspectRatioTable.AspectRatio,
			AspectType = aspectRatioTable.AspectType,
			DominantAxis = aspectRatioTable.DominantAxis,
		}
	else
		return {
			AspectRatio = aspectRatio,
			AspectType = nil,
			DominantAxis = nil,
		}
	end
end

local function AspectRatio(props: AspectRatioProps)
	local Scope = props.scope
	assert(Scope, "A scope has not been provided for the AspectRatio component.")
	
	local aspectRatio = getAspectRatio(props.value)
	return Scope:New("UIAspectRatioConstraint")(aspectRatio)
end

return AspectRatio
