-- Client-side mirror of the player's profile, pushed by the server.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage:WaitForChild("Shared").Net)

local State = {}

State.data = nil :: any
local changed = Instance.new("BindableEvent")

-- Calls fn now (if data is loaded) and on every update.
function State.observe(fn: (any) -> ())
	if State.data then
		task.spawn(fn, State.data)
	end
	return changed.Event:Connect(fn)
end

Net.event("DataChanged").OnClientEvent:Connect(function(snapshot)
	State.data = snapshot
	changed:Fire(snapshot)
end)

return State
