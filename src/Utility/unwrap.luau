local Foundation = script.Parent.Parent

local PackageManager = require(Foundation.PackageManager)
local Fusion = PackageManager.getPackage("Fusion")

local TypesSource = Foundation.Utility.Types
local Types = require(TypesSource.Types)

type Use = Types.Use
type Fusion = Types.Fusion

return function<T>(x: T, use: Use?): T | any
	-- If x is a state, and requires a dependency to be added, we also require a use function.
	-- If x is a state, but doesn't require a dependency to be added, we use Fusion.peek function.
	if typeof(x) == "table" and x.type == "State" and use then
		return use(x)
	elseif typeof(x) == "table" and x.type == "State" then
		return Fusion.peek(x)
	end

	return x
end