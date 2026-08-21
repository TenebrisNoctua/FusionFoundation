-- Theme is used for selecting between dark and light token generators.
-- ColorMode is used for selecting color namespaces within a theme.
export type Theme = "Dark" | "Light"

local Theme = {
	Dark = "Dark" :: "Dark",
	Light = "Light" :: "Light",
}

return Theme
