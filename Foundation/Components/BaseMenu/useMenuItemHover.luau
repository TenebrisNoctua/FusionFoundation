local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Fusion = PackageManager.getPackage("Fusion")

local Utility = Foundation.Utility
local TypesSource = Utility.Types

local unwrap = require(Utility.unwrap)

local Types = require(TypesSource.Types)

type Scope = Types.Scope
type UsedAs<T> = Types.UsedAs<T>
type ItemId = Types.ItemId

export type UseMenuItemHoverOptions = {
	itemRef: UsedAs<GuiObject?>,
	id: ItemId,
	depth: number,
	isSubmenu: boolean,
	isDisabled: boolean?,
	hoverOpenAtDepth: ((depth: number, id: ItemId, immediate: boolean?) -> ())?,
	hoverCloseAtDepth: ((depth: number) -> ())?,
}

return function(scope: Scope, options: UseMenuItemHoverOptions)
	local connection: RBXScriptConnection? = nil

	local function cleanup()
		if not connection then return end
		connection:Disconnect()
		connection = nil
	end

	local function setupListener()
		cleanup()

		local currentItem = unwrap(options.itemRef)
		if not currentItem or typeof(currentItem) ~= "Instance" then return end
		
		connection = currentItem:GetPropertyChangedSignal("GuiState"):Connect(function()
			if options.isSubmenu then
				if options.isDisabled then return end
				local isHovered = currentItem.GuiState == Enum.GuiState.Hover

				if isHovered and options.hoverOpenAtDepth then
					options.hoverOpenAtDepth(options.depth, options.id)
				elseif options.hoverCloseAtDepth then
					options.hoverCloseAtDepth(options.depth)
				end
			elseif currentItem.GuiState == Enum.GuiState.Hover then
				if not options.hoverCloseAtDepth then return end
				options.hoverCloseAtDepth(options.depth)
			end
		end)
	end

	if unwrap(options.itemRef) ~= options.itemRef then
		scope:Observer(options.itemRef):onChange(setupListener)
	end

	setupListener()
	table.insert(scope, cleanup)
end