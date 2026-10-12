-- The local player's settings (Config/Settings), from the latest snapshot.
-- A slider being dragged overrides its saved value until the server agrees.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = require(ReplicatedStorage:WaitForChild("Shared").Config.Settings)

local State = require(script.Parent.State)

local ClientSettings = {}

local pending: { [string]: any } = {}

local function raw(id: string): any
	local value = pending[id]
	if value == nil then
		local saved = State.data and State.data.settings
		value = saved and saved[id]
	end
	local setting = Settings.ById[id]
	if setting then
		local clean = Settings.sanitize(setting, value)
		if clean == nil then
			return setting.default
		end
		return clean
	end
	return if value == nil then true else value
end

-- On/off. A slider counts as on above 0.
function ClientSettings.get(id: string): boolean
	local value = raw(id)
	if typeof(value) == "number" then
		return value > 0
	end
	return value == true
end

-- A slider as 0..1 (1 for a toggle that's on, 0 when off).
function ClientSettings.level(id: string): number
	local value = raw(id)
	if typeof(value) == "number" then
		return value / 100
	end
	return if value then 1 else 0
end

-- Shows a value locally right away (while dragging); cleared once the
-- snapshot carries it.
function ClientSettings.preview(id: string, value: any)
	pending[id] = value
end

function ClientSettings.settle(id: string)
	pending[id] = nil
end

return ClientSettings
