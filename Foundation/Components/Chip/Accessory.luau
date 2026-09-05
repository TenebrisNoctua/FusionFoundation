local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local BuilderIcons = PackageManager.getPackage("BuilderIcons")
local migrationLookup = BuilderIcons.Migration["uiblox"]

local Components = Foundation.Components
local Utility = Foundation.Utility
local Enums = Foundation.Enums

local useAccessoryVariants = require(script.Parent.useAccessoryVariants)

local Icon = require(Components.Icon)
local View = require(Components.View)
local Image = require(Components.Image)
local AvatarGroup = require(Components.AvatarGroup)

local unwrap = require(Utility.unwrap)
local withDefaults = require(Utility.withDefaults)
local isBuilderIcon = require(Utility.isBuilderIcon)
local iconMigrationUtils = require(Utility.iconMigrationUtils)
local Types = require(Utility.Types)

local ChipSize = require(Enums.ChipSize)

local ThemeProvider = require(Foundation.Providers.ThemeProvider)

local function AvatarGroupWrapper(props: AccessoryProps<AvatarGroupConfig>, scope: Scope)
	local config = props.config :: AvatarGroupConfig
	local avatarGroupProps = table.clone(config.props) :: any
	avatarGroupProps.scope = scope
	avatarGroupProps.size = props.size
	avatarGroupProps.isIconSize = true
	return AvatarGroup(avatarGroupProps :: AvatarGroupProps)
end

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope
type Use = Types.Use

type ChipSize = ChipSize.ChipSize
type ColorStyleValue = Types.ColorStyleValue
type AvatarGroupProps = AvatarGroup.AvatarGroupProps

type IconConfig = {
	type: nil,
	iconName: string,
	iconVariant: any?,
	isCircular: boolean?,
	onActivated: (() -> ())?
}

type Config = string | Accessory

type AccessoryProps<Config = Config> = {
	scope: Scope,
	isLeading: boolean,
	config: Config,
	size: ChipSize,
	contentStyle: UsedAs<ColorStyleValue>,
	isDisabled: UsedAs<boolean>?,
	LayoutOrder: UsedAs<number>?
}

export type AvatarGroupConfig = {
	type: "AvatarGroup",
	-- Only subset of the properties is allowed explicitly, the rest come from the Chip
	props: {
		avatars: { { userId: number } | number },
		type: any?,
		max: number?,
	},
	onActivated: nil,
	isCircular: nil,
}

export type Accessory = IconConfig | AvatarGroupConfig

return function(accessoryProps: AccessoryProps)
	local scope = accessoryProps.scope
	local theme = ThemeProvider()
	assert(scope, "A scope has not been provided for the Chip Accessory component.")

	return scope:Computed(function(use: Use, innerScope: Scope)
		local tokens = unwrap(theme.Tokens, use)
		local rawConfig = accessoryProps.config

		local fullConfig: Accessory = if type(rawConfig) == "string"
			then {
				iconName = rawConfig,
				isCircular = false,
			} :: Accessory
			else rawConfig

		local isAvatarGroup = fullConfig.type == "AvatarGroup"
		local isCircular = isAvatarGroup or fullConfig.isCircular or false

		local variants = useAccessoryVariants(
			unwrap(theme.Theme, use),
			tokens,
			accessoryProps.size,
			accessoryProps.isLeading,
			isCircular
		)

		local element
		if isAvatarGroup then
			element = AvatarGroupWrapper(accessoryProps :: AccessoryProps<AvatarGroupConfig>, innerScope)
		else
			local iconName = (fullConfig :: IconConfig).iconName
			local iconVariant = (fullConfig :: IconConfig).iconVariant
			local sizeOffset = variants.accessory.Size.Y.Offset

			-- Icon's internal sizing (useIconSize) only accepts a raw pixel offset
			-- when the name is a *genuine, non-migrated* Builder Icon - for a
			-- migrated legacy icon or a plain image asset it requires a fixed
			-- IconSize enum step instead, which doesn't line up with our
			-- token-driven accessory sizes.
			if isBuilderIcon(iconName) then
				element = Icon {
					scope = innerScope,
					name = iconName,
					variant = iconVariant,
					size = sizeOffset,
					style = accessoryProps.contentStyle,
				}
			elseif iconMigrationUtils.isMigrated(iconName) then
				local migrated = migrationLookup[iconName]
				element = Icon {
					scope = innerScope,
					name = migrated.name,
					variant = migrated.variant or iconVariant,
					size = sizeOffset,
					style = accessoryProps.contentStyle,
				}
			else
				element = Image {
					scope = innerScope,
					imageStyle = accessoryProps.contentStyle,
					Image = iconName,
					Size = UDim2.fromOffset(sizeOffset, sizeOffset),
				}
			end
		end

		return View {
			scope = innerScope,
			tag = "auto-xy",
			padding = variants.accessory.padding,
			onActivated = if not isAvatarGroup then (fullConfig :: IconConfig).onActivated else nil,
			-- No transparency is needed here when disabled, it's handled by the Chip.
			isDisabled = accessoryProps.isDisabled,
			LayoutOrder = if accessoryProps.isLeading then 1 else 3,
			children = { Content = element }
		}
	end)
end
