-- Pet inventory management: delete (one or many), lock favourites so they
-- can't be deleted, and auto-delete rarities straight after hatching.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Pets = require(Shared.Config.Pets)

local DataService = require(script.Parent.Parent.DataService)

local Management = {}

local MAX_BATCH = 200

-- DeletePets remote: (uids: { string }) -> ok, message
function Management.delete(player: Player, uids: unknown): (boolean, string)
	local data = DataService.get(player)
	if not data or typeof(uids) ~= "table" then
		return false, "Invalid request"
	end
	local removed = 0
	for i, uid in uids :: { any } do
		if i > MAX_BATCH then
			break
		end
		local pet = typeof(uid) == "string" and data.pets[uid]
		if pet and not pet.locked then
			data.pets[uid] = nil
			removed += 1
		end
	end
	if removed == 0 then
		return false, "Nothing to delete (locked pets are protected)"
	end
	DataService.changed(player)
	return true, `Deleted {removed} pet{if removed == 1 then "" else "s"}`
end

-- LockPet remote: (uid, locked) -> ok, message
function Management.lock(player: Player, uid: unknown, locked: unknown): (boolean, string)
	local data = DataService.get(player)
	if not data or typeof(uid) ~= "string" or not data.pets[uid] or typeof(locked) ~= "boolean" then
		return false, "Invalid pet"
	end
	data.pets[uid].locked = locked or nil
	DataService.changed(player)
	return true, if locked then "Locked 🔒" else "Unlocked"
end

-- SetAutoDelete remote: (rarity, enabled) -> ok, message
function Management.setAutoDelete(player: Player, rarity: unknown, enabled: unknown): (boolean, string)
	local data = DataService.get(player)
	if not data or typeof(rarity) ~= "string" or not Pets.RarityOrder[rarity] or typeof(enabled) ~= "boolean" then
		return false, "Invalid setting"
	end
	-- Never auto-delete the best rarities.
	if Pets.RarityOrder[rarity] >= Pets.RarityOrder.Legendary then
		return false, "Can't auto-delete that rarity"
	end
	data.autoDelete[rarity] = enabled or nil
	DataService.changed(player)
	return true, `Auto delete {rarity}: {if enabled then "ON" else "OFF"}`
end

-- True when a freshly hatched pet should be deleted instead of kept.
function Management.shouldAutoDelete(data: any, petId: string): boolean
	local def = Pets.ById[petId]
	return def ~= nil and data.autoDelete[def.rarity] == true
end

return Management
