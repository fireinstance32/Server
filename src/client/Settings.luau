-- The local player's settings (Config/Settings), from the latest snapshot.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = require(ReplicatedStorage:WaitForChild("Shared").Config.Settings)

local State = require(script.Parent.State)

local ClientSettings = {}

function ClientSettings.get(id: string): boolean
	local saved = State.data and State.data.settings
	if saved and saved[id] ~= nil then
		return saved[id]
	end
	local setting = Settings.ById[id]
	return if setting then setting.default else true
end

return ClientSettings
