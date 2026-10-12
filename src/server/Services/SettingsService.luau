-- Saves the player's settings (Config/Settings) from the Settings menu.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = require(ReplicatedStorage:WaitForChild("Shared").Config.Settings)

local DataService = require(script.Parent.DataService)
local Remotes = require(script.Parent.Parent.Remotes)

local SettingsService = {}

local function set(player: Player, id: unknown, value: unknown): (boolean, string)
	if typeof(id) ~= "string" or typeof(value) ~= "boolean" or not Settings.ById[id] then
		return false, "Invalid setting"
	end
	local data = DataService.get(player)
	if not data then
		return false, "Still loading..."
	end
	data.settings[id] = value
	DataService.changed(player)
	return true, `{Settings.ById[id].label}: {if value then "ON" else "OFF"}`
end

function SettingsService.start()
	Remotes.handle("SetSetting", set)
end

return SettingsService
