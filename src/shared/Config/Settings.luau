--!strict
-- Player settings (Settings menu), saved with the profile. Toggles are
-- on/off; sliders are 0–100 (volumes).

export type Setting = {
	id: string,
	label: string,
	icon: string,
	kind: "toggle" | "slider",
	default: boolean | number,
}

local Settings = {}

Settings.List = {
	{ id = "sfx", label = "Sound Effects", icon = "speaker", kind = "slider", default = 100 },
	{ id = "music", label = "Music", icon = "music", kind = "slider", default = 100 },
	{ id = "shake", label = "Camera Shake", icon = "bolt", kind = "toggle", default = true },
	{ id = "effects", label = "Effects", icon = "trails", kind = "toggle", default = true },
	{ id = "otherPets", label = "Other Players' Pets", icon = "pets", kind = "toggle", default = true },
} :: { Setting }

Settings.ById = {} :: { [string]: Setting }
for _, setting in Settings.List do
	Settings.ById[setting.id] = setting
end

function Settings.defaults(): { [string]: boolean | number }
	local values = {}
	for _, setting in Settings.List do
		values[setting.id] = setting.default
	end
	return values
end

-- A valid value for `setting`, or nil if `value` can't be one. Sliders take
-- whole numbers 0–100; an old on/off save becomes 100/0.
function Settings.sanitize(setting: Setting, value: unknown): (boolean | number)?
	if setting.kind == "toggle" then
		return if typeof(value) == "boolean" then value else nil
	end
	if typeof(value) == "boolean" then
		return if value then 100 else 0
	end
	if typeof(value) ~= "number" or value ~= value then
		return nil
	end
	return math.clamp(math.floor(value + 0.5), 0, 100)
end

return Settings
