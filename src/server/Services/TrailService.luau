-- Buying and equipping trails. Robux trails are granted by
-- MonetizationService through TrailService.grant.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Trails = require(Shared.Config.Trails)
local Net = require(Shared.Net)

local DataService = require(script.Parent.DataService)

local TrailService = {}

-- Gives a trail and equips it (no payment, no replication).
function TrailService.grant(data: any, trailId: string)
	data.trails[trailId] = true
	data.equippedTrail = trailId
end

local function buy(player: Player, trailId: unknown): (boolean, string)
	local trail = typeof(trailId) == "string" and Trails.ById[trailId]
	local data = DataService.get(player)
	if not trail or not data then
		return false, "Invalid trail"
	end
	if data.trails[trail.id] then
		return false, "You already own this trail"
	end
	if trail.product then
		return false, "This trail is sold for Robux"
	end
	if data.wins < trail.price then
		return false, "Not enough Wins"
	end
	data.wins -= trail.price
	TrailService.grant(data, trail.id)
	DataService.changed(player)
	return true, `Unlocked {trail.name}!`
end

-- EquipTrail remote: (trailId | "") -> "" unequips.
local function equip(player: Player, trailId: unknown): (boolean, string)
	local data = DataService.get(player)
	if not data or typeof(trailId) ~= "string" then
		return false, "Invalid trail"
	end
	if trailId == "" then
		data.equippedTrail = nil
	elseif data.trails[trailId] then
		data.equippedTrail = trailId
	else
		return false, "You don't own this trail"
	end
	DataService.changed(player)
	return true, if trailId == "" then "Trail removed" else "Equipped!"
end

function TrailService.start()
	Net.func("BuyTrail").OnServerInvoke = buy
	Net.func("EquipTrail").OnServerInvoke = equip
end

return TrailService
