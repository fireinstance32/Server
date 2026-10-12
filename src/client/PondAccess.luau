-- Client view of which training ponds the player can use (for signs, the
-- HOP button and auto-train). The server re-checks every training request.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ponds = require(ReplicatedStorage:WaitForChild("Shared").Config.Ponds)

local State = require(script.Parent.State)
local Purchases = require(script.Parent.Purchases)

local PondAccess = {}

function PondAccess.lockReason(pond: Ponds.Pond): string?
	local rebirths = if State.data then State.data.rebirths else 0
	return Ponds.lockReason(pond, rebirths, Purchases.owns)
end

function PondAccess.isUnlocked(pond: Ponds.Pond): boolean
	return PondAccess.lockReason(pond) == nil
end

return PondAccess
