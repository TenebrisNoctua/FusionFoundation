local Foundation = script.Parent.Parent
local RunService = game:GetService("RunService")

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local Icon = require(Components.Icon)
local View = require(Components.View)

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local withCommonProps = require(Utility.withCommonProps)
local Types = require(Utility.Types)

local IconSize = require(Enums.IconSize)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local DEGREES_PER_SECOND = 360

local defaultProps = {
	size = IconSize.Large,
	isDisabled = false
}

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type IconSize = IconSize.IconSize

export type LoadingProps = {
	-- The scope the component will be created in.
	scope: Scope,
	size: UsedAs<IconSize>?,
	-- Whether the spinner is stopped. While true, the icon stops rotating and keeps its current angle.
	isDisabled: UsedAs<boolean>?
} & Types.CommonProps

return function(loadingProps: LoadingProps)
	local scope = loadingProps.scope
	assert(scope, "A scope has not been provided for the Loading component.")

	local theme = ThemeProvider()
	local props = withDefaults(loadingProps, defaultProps)

	-- useRotation always follows the clock, so it can't be paused. The rotation is accumulated per frame instead,
	-- and frames are skipped while isDisabled is true.
	local rotation = scope:Value(0)
	local connection = RunService.Heartbeat:Connect(function(deltaTime: number)
		if unwrap(props.isDisabled) then return end
		rotation:set((unwrap(rotation) + deltaTime * DEGREES_PER_SECOND) % 360)
	end)
	table.insert(scope, function()
		connection:Disconnect()
	end)

	local iconProps = {
		scope = scope,
		name = "icons/graphic/loadingspinner",
		size = props.size,
		style = scope:Computed(function(use: Use)
			return unwrap(theme.Tokens, use).DarkMode.Content.Emphasis
		end),
		Rotation = rotation
	}

	local viewProps = withCommonProps(props, {
		scope = scope,
		tag = "auto-xy",
		children = {
			Icon = Icon(iconProps)
		}
	})

	return View(viewProps)
end
