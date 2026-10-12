-- Pets: equipping, Equip Best, and the pet models that follow players.
-- Hatching lives in Hatching.luau. Models live in Workspace.Pets.<UserId>;
-- each client moves them locally (client PetFollowController).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Pets = require(Shared.Config.Pets)
local Models = require(Shared.Util.Models)

local Stats = require(script.Parent.Parent.Stats)
local DataService = require(script.Parent.DataService)
local Hatching = require(script.Hatching)
local Management = require(script.Management)
local Remotes = require(script.Parent.Parent.Remotes)

local PetService = {}

local petsFolder: Folder

function PetService.countPets(data: any): (number, number)
	local total, equipped = 0, 0
	for _, pet in data.pets do
		total += 1
		if pet.equipped then
			equipped += 1
		end
	end
	return total, equipped
end

function PetService.refreshModels(player: Player)
	local data = DataService.get(player)
	local existing = petsFolder:FindFirstChild(tostring(player.UserId))
	if existing then
		existing:Destroy()
	end
	if not data then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = tostring(player.UserId)
	local slot = 0
	for _, pet in data.pets do
		local def = Pets.ById[pet.id]
		if pet.equipped and def then
			slot += 1
			local model = Models.pet(def.name, def.color)
			model:SetAttribute("Slot", slot)
			model.Parent = folder
		end
	end
	folder.Parent = petsFolder
end

local function equipPet(player: Player, uid: unknown): (boolean, string)
	local data = DataService.get(player)
	if typeof(uid) ~= "string" or not data or not data.pets[uid] then
		return false, "Invalid pet"
	end
	local _, equipped = PetService.countPets(data)
	if equipped >= Stats.maxEquippedPets(player) then
		return false, "All pet slots are full"
	end
	data.pets[uid].equipped = true
	DataService.changed(player)
	PetService.refreshModels(player)
	return true, "Equipped!"
end

local function unequipPet(player: Player, uid: unknown): (boolean, string)
	local data = DataService.get(player)
	if typeof(uid) ~= "string" or not data or not data.pets[uid] then
		return false, "Invalid pet"
	end
	data.pets[uid].equipped = false
	DataService.changed(player)
	PetService.refreshModels(player)
	return true, "Unequipped"
end

-- Equips the strongest pets up to the slot limit.
local function equipBest(player: Player): (boolean, string)
	local data = DataService.get(player)
	if not data then
		return false, "Still loading..."
	end
	local ranked = {}
	for uid, pet in data.pets do
		local def = Pets.ById[pet.id]
		if def then
			table.insert(ranked, { uid = uid, bonus = def.bonus })
		end
	end
	table.sort(ranked, function(a, b)
		return a.bonus > b.bonus
	end)
	local slots = Stats.maxEquippedPets(player)
	for i, entry in ranked do
		data.pets[entry.uid].equipped = i <= slots
	end
	DataService.changed(player)
	PetService.refreshModels(player)
	return true, "Equipped your best pets!"
end

function PetService.init()
	petsFolder = Instance.new("Folder")
	petsFolder.Name = "Pets"
	petsFolder.Parent = workspace
end

function PetService.start()
	Hatching.onHatched = PetService.refreshModels
	Remotes.handle("HatchEgg", function(player, eggId, count)
		return Hatching.hatch(player, eggId, count)
	end)
	Remotes.handle("EquipPet", equipPet)
	Remotes.handle("UnequipPet", unequipPet)
	Remotes.handle("EquipBestPets", equipBest)
	Remotes.handle("DeletePets", function(player, uids)
		local ok, message = Management.delete(player, uids)
		if ok then
			PetService.refreshModels(player)
		end
		return ok, message
	end)
	Remotes.handle("LockPet", Management.lock)
	Remotes.handle("SetAutoDelete", Management.setAutoDelete)

	local function onPlayer(player: Player)
		-- Wait for the profile to load, then spawn saved pets.
		task.spawn(function()
			local deadline = os.clock() + 30
			while player.Parent and not DataService.get(player) and os.clock() < deadline do
				task.wait(0.5)
			end
			if player.Parent then
				PetService.refreshModels(player)
			end
		end)
	end
	Players.PlayerAdded:Connect(onPlayer)
	for _, player in Players:GetPlayers() do
		onPlayer(player)
	end
	Players.PlayerRemoving:Connect(function(player)
		local folder = petsFolder:FindFirstChild(tostring(player.UserId))
		if folder then
			folder:Destroy()
		end
	end)
end

-- Used by MonetizationService for Robux eggs.
PetService.grantHatch = Hatching.grant

return PetService
