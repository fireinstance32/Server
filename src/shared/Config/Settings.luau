--!strict
-- Player settings (Settings menu). Saved with the profile; all on/off.

export type Setting = { id: string, label: string, icon: string, default: boolean }

local Settings = {}

Settings.List = {
	{ id = "sfx", label = "Sound effects", icon = "speaker", default = true },
	{ id = "music", label = "Music", icon = "music", default = true },
	{ id = "otherPets", label = "Show other players' pets", icon = "pets", default = true },
	{ id = "effects", label = "Big effects (splashes, confetti)", icon = "trails", default = true },
} :: { Setting }

Settings.ById = {} :: { [string]: Setting }
for _, setting in Settings.List do
	Settings.ById[setting.id] = setting
end

function Settings.defaults(): { [string]: boolean }
	local values = {}
	for _, setting in Settings.List do
		values[setting.id] = setting.default
	end
	return values
end

return Settings
