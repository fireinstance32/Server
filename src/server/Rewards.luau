-- Grants a reward table ({ kind, id?, amount? }) to a player's data. Shared
-- by daily rewards, playtime gifts, quests and codes. No replication: the
-- caller calls DataService.changed afterwards.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Pets = require(Shared.Config.Pets)
local Frogs = require(Shared.Config.Frogs)
local Potions = require(Shared.Config.Potions)
local Hatch = require(Shared.Util.Hatch)

local Rewards = {}

function Rewards.addPet(data: any, petId: string)
	if not Pets.ById[petId] then
		return
	end
	local uid = tostring(data.nextPetUid)
	data.nextPetUid += 1
	data.pets[uid] = { id = petId, equipped = false }
	data.discovered[petId] = true
end

function Rewards.grant(data: any, reward: any)
	local amount = reward.amount or 1
	if reward.kind == "potion" and Potions.ById[reward.id] then
		data.potions[reward.id] = (data.potions[reward.id] or 0) + amount
	elseif reward.kind == "pet" then
		for _ = 1, amount do
			Rewards.addPet(data, reward.id)
		end
	elseif reward.kind == "egg" and Pets.EggsById[reward.id] then
		-- A free hatch (no luck boost) straight into the inventory.
		local egg = Pets.EggsById[reward.id]
		local weights = Hatch.weights(egg.pets, 1, function()
			return false
		end)
		for _ = 1, amount do
			Rewards.addPet(data, Hatch.pick(egg.pets, weights, math.random()))
		end
	elseif reward.kind == "frog" and Frogs.ById[reward.id] then
		data.frogs[reward.id] = true
	elseif reward.kind == "wins" then
		data.wins += amount
	elseif reward.kind == "hops" then
		data.hops += amount
	end
end

return Rewards
