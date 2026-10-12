-- Buying and equipping frogs with Wins.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Frogs = require(Shared.Config.Frogs)
local Worlds = require(Shared.Config.Worlds)

local DataService = require(script.Parent.DataService)
local AnalyticsTracker = require(script.Parent.AnalyticsTracker)
local Remotes = require(script.Parent.Parent.Remotes)

local ShopService = {}

local function buyFrog(player: Player, frogId: unknown): (boolean, string)
	if typeof(frogId) ~= "string" then
		return false, "Invalid frog"
	end
	local frog = Frogs.ById[frogId]
	local data = DataService.get(player)
	if not frog or not data then
		return false, "Invalid frog"
	end
	if data.frogs[frog.id] then
		return false, "You already own this frog"
	end
	if frog.robuxOnly then
		return false, "This frog is sold for Robux"
	end
	if frog.rewardOnly then
		return false, `Get it from: {frog.rewardOnly}`
	end
	local world = Worlds.ById[frog.world or Worlds.Default]
	if world and not Worlds.isUnlocked(world, data.worldsUnlocked) then
		return false, `Unlock {world.name} first`
	end
	if data.wins < frog.price then
		return false, "Not enough Wins"
	end

	data.wins -= frog.price
	AnalyticsTracker.spend(player, frog.price, data.wins, "Frog", frog.id)
	data.frogs[frog.id] = true
	data.equippedFrog = frog.id
	DataService.changed(player)
	return true, `Unlocked {frog.name}!`
end

local function equipFrog(player: Player, frogId: unknown): (boolean, string)
	if typeof(frogId) ~= "string" then
		return false, "Invalid frog"
	end
	local data = DataService.get(player)
	if not data or not data.frogs[frogId] then
		return false, "You don't own this frog"
	end
	data.equippedFrog = frogId
	DataService.changed(player)
	return true, "Equipped!"
end

function ShopService.start()
	Remotes.handle("BuyFrog", buyFrog)
	Remotes.handle("EquipFrog", equipFrog)
end

return ShopService
