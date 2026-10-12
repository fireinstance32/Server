-- Saves the player's settings (Config/Settings) from the Settings menu.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = require(ReplicatedStorage:WaitForChild("Shared").Config.Settings)

local DataService = require(script.Parent.DataService)
local Remotes = require(script.Parent.Parent.Remotes)

local SettingsService = {}

local function set(player: Player, id: unknown, value: unknown): (boolean, string)
	local setting = typeof(id) == "string" and Settings.ById[id]
	local clean = setting and Settings.sanitize(setting, value)
	if not setting or clean == nil then
		return false, "Invalid setting"
	end
	local data = DataService.get(player)
	if not data then
		return false, "Still loading..."
	end
	data.settings[setting.id] = clean
	DataService.changed(player)
	if setting.kind == "slider" then
		return true, `{setting.label}: {clean}`
	end
	return true, `{setting.label}: {if clean then "ON" else "OFF"}`
end

function SettingsService.start()
	Remotes.handle("SetSetting", set)
end

return SettingsService
