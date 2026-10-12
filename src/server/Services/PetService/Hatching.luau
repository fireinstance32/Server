-- Egg hatching: Wins eggs (1, 3 or 8 at once with the multi-hatch passes)
-- and Robux eggs (granted by MonetizationService). Tracks discovered pets so
-- the reveal can say NEW!. The roll maths is in Shared.Util.Hatch.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Pets = require(Shared.Config.Pets)
local Worlds = require(Shared.Config.Worlds)
local Hatch = require(Shared.Util.Hatch)

local Stats = require(script.Parent.Parent.Parent.Stats)
local Passes = require(script.Parent.Parent.Parent.Passes)
local DataService = require(script.Parent.Parent.DataService)
local Management = require(script.Parent.Management)

local Hatching = {}

local random = Random.new()

export type Result = { pet: string, isNew: boolean, chance: number, deleted: boolean? }

local function isLucky(petId: string): boolean
	local def = Pets.ById[petId]
	return def ~= nil and Pets.RarityOrder[def.rarity] >= Pets.LuckMinRarity
end

local function inventoryCount(data: any): (number, number)
	local total, equipped = 0, 0
	for _, pet in data.pets do
		total += 1
		if pet.equipped then
			equipped += 1
		end
	end
	return total, equipped
end

-- Largest batch this player may hatch (1, 3 or 8).
function Hatching.maxCount(player: Player): number
	local best = 1
	for _, option in Pets.MultiHatch do
		if option.count > best and Passes.owns(player, option.pass) then
			best = option.count
		end
	end
	return best
end

-- Rolls `count` pets from `egg` into the player's data. No checks, no
-- payment, no replication: callers do those. Returns the results.
function Hatching.grant(player: Player, data: any, egg: Pets.Egg, count: number): { Result }
	local weights = Hatch.weights(egg.pets, Stats.luck(player, data), isLucky)
	local chances = Hatch.chances(egg.pets, weights)
	local _, equipped = inventoryCount(data)
	local slots = Stats.maxEquippedPets(player)
	local results = {}
	for _ = 1, count do
		local petId = Hatch.pick(egg.pets, weights, random:NextNumber())
		data.stats.hatched += 1
		local isNew = not data.discovered[petId]
		data.discovered[petId] = true
		-- Auto delete (never on a first discovery, so the index still fills).
		if not isNew and Management.shouldAutoDelete(data, petId) then
			table.insert(results, { pet = petId, isNew = false, chance = chances[petId], deleted = true })
			continue
		end
		local uid = tostring(data.nextPetUid)
		data.nextPetUid += 1
		-- Auto-equip while there are free slots so new players feel the boost.
		local equip = equipped < slots
		if equip then
			equipped += 1
		end
		data.pets[uid] = { id = petId, equipped = equip }
		table.insert(results, { pet = petId, isNew = isNew, chance = chances[petId] })
	end
	return results
end

-- HatchEgg remote: (eggId, count?) -> ok, results | message
function Hatching.hatch(player: Player, eggId: unknown, count: unknown): (boolean, any)
	if typeof(eggId) ~= "string" then
		return false, "Invalid egg"
	end
	local egg = Pets.EggsById[eggId]
	local data = DataService.get(player)
	if not egg or not data then
		return false, "Invalid egg"
	end
	if egg.product then
		return false, "This egg is bought with Robux"
	end
	local world = Worlds.ById[egg.world or Worlds.Default]
	if world and not Worlds.isUnlocked(world, data.worldsUnlocked) then
		return false, `Unlock {world.name} first`
	end
	local n = if typeof(count) == "number" then math.floor(count) else 1
	if n ~= 1 and n ~= 3 and n ~= 8 then
		return false, "Invalid amount"
	end
	if n > Hatching.maxCount(player) then
		return false, `You need the +{n} Eggs pass`
	end
	local cost = egg.price * n
	if data.wins < cost then
		return false, "Not enough Wins"
	end
	local total = inventoryCount(data)
	if total + n > Stats.maxPetInventory(player) then
		return false, "Your pet inventory is full"
	end

	data.wins -= cost
	local results = Hatching.grant(player, data, egg, n)
	DataService.changed(player)
	-- Models refresh is done by PetService (it requires this module, not the reverse).
	Hatching.onHatched(player)
	return true, results
end

-- Set by PetService so new pets appear without a circular require.
function Hatching.onHatched(_player: Player) end

return Hatching
