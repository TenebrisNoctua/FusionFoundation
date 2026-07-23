local Foundation = script.Parent.Parent.Parent
local Utility = Foundation.Utility

local unwrap = require(Utility.unwrap)
local isState = require(Utility.isState)
local StudioUri = require(Utility.Plugin.StudioUri)
local Types = require(Utility.Types)

local ProviderTypes = require(script.Parent.Types)

type Scope = Types.Scope
type UsedAs<T> = Types.UsedAs<T>
type Use = Types.Use
type StudioUri = StudioUri.StudioUri
type PanelHandle = ProviderTypes.PanelHandle
type PanelPosition = ProviderTypes.PanelPosition

export type UsePanelOptions = {
	scope: Scope,
	isOpen: UsedAs<boolean>,
	anchorUri: UsedAs<StudioUri>,
	anchorGui: UsedAs<GuiBase2d?>?,
	onClose: () -> (),
	position: UsedAs<PanelPosition>,
	depth: UsedAs<number?>?,
	parentPopoverId: UsedAs<string?>?,
	registerPanelAsync: (
		anchorUri: StudioUri,
		position: PanelPosition,
		onClose: () -> (),
		depth: number?,
		parentPopoverId: string?
	) -> (PanelHandle, () -> ()),
}

return function(options: UsePanelOptions): UsedAs<PanelHandle?>
	local scope = options.scope
	local panelState = scope:Value(nil :: PanelHandle?)

	local currentClosePanel: (() -> ())? = nil
	local registerThread: thread? = nil
	local updateThread: thread? = nil

	local function cleanUpPanel()
		if registerThread then
			task.cancel(registerThread)
			registerThread = nil
		end
		if currentClosePanel then
			currentClosePanel()
			currentClosePanel = nil
		end
		panelState:set(nil)
	end

	local function handleRegistration()
		local isOpen = unwrap(options.isOpen)
		if not isOpen then
			cleanUpPanel()
			return
		end

		if registerThread or unwrap(panelState) then
			return
		end

		registerThread = task.spawn(function()
			local success, panelHandle, onClose = xpcall(function()
				return options.registerPanelAsync(
					unwrap(options.anchorUri),
					unwrap(options.position),
					options.onClose,
					unwrap(options.depth),
					unwrap(options.parentPopoverId)
				)
			end, function(problem)
				warn("Failed to register panel asynchronously: " .. tostring(problem))
			end)

			registerThread = nil

			if success and panelHandle then
				currentClosePanel = onClose
				panelState:set(panelHandle)
			end
		end)
	end

	local function handleUpdate()
		local panel = unwrap(panelState)
		if not panel then return end

		if updateThread then
			task.cancel(updateThread)
		end

		updateThread = task.spawn(function()
			xpcall(function()
				local currentPosition = unwrap(options.position)
				panel.updateAsync({
					targetWidgetUri = unwrap(options.anchorUri),
					targetAnchorPoint = currentPosition.targetAnchorPoint,
					subjectAnchorPoint = currentPosition.subjectAnchorPoint,
					offset = currentPosition.offset,
				})
			end, function(problem)
				warn("Failed to update panel properties asynchronously: " .. tostring(problem))
			end)

			updateThread = nil
		end)
	end

	if isState(options.isOpen) then
		scope:Observer(options.isOpen):onChange(handleRegistration)
	end

	local updateDependencies = scope:Computed(function(use: Use)
		return {
			panel = unwrap(panelState, use),
			anchorUri = unwrap(options.anchorUri, use),
			anchorGui = if options.anchorGui then unwrap(options.anchorGui, use) else nil,
			position = unwrap(options.position, use),
		}
	end)

	scope:Observer(updateDependencies):onChange(handleUpdate)

	handleRegistration()

	table.insert(scope, function()
		cleanUpPanel()
		if updateThread then
			task.cancel(updateThread)
			updateThread = nil
		end
	end)

	return panelState
end