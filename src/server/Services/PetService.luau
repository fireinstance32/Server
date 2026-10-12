-- Egg hatching, pet equipping, and the physical pet models that follow players.
-- Models live in Workspace.Pets.<UserId>; each client moves them locally
-- (see client PetFollowController), so the server only creates/destroys them.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)
local Pets = require(Shared.Config.Pets)
local Models = require(Shared.Util.Models)
local Net = require(Shared.Net)

local Stats = require(script.Parent.Parent.Stats)
local DataService = require(script.Parent.DataService)

local PetService = {}

local random = Random.new()
local petsFolder: Folder

local function countPets(data: any): (number, number)
	local total, equipped = 0, 0
	for _, pet in data.pets do
		total += 1
		if pet.equipped then
			equipped += 1
		end
	end
	return total, equipped
end

local function roll(egg: Pets.Egg): string
	local totalWeight = 0
	for _, entry in egg.pets do
		totalWeight += entry.weight
	end
	local pick = random:NextNumber(0, totalWeight)
	for _, entry in egg.pets do
		pick -= entry.weight
		if pick <= 0 then
			return entry.pet
		end
	end
	return egg.pets[#egg.pets].pet
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

local function hatchEgg(player: Player, eggId: unknown): (boolean, string)
	if typeof(eggId) ~= "string" then
		return false, "Invalid egg"
	end
	local egg = Pets.EggsById[eggId]
	local data = DataService.get(player)
	if not egg or not data then
		return false, "Invalid egg"
	end
	if data.wins < egg.price then
		return false, "Not enough Wins"
	end
	local total, equipped = countPets(data)
	if total >= Game.MaxPetInventory then
		return false, "Your pet inventory is full"
	end

	data.wins -= egg.price
	local petId = roll(egg)
	local uid = tostring(data.nextPetUid)
	data.nextPetUid += 1
	-- Auto-equip while there are free slots so new players feel the boost.
	data.pets[uid] = { id = petId, equipped = equipped < Stats.maxEquippedPets(player) }

	DataService.changed(player)
	PetService.refreshModels(player)
	return true, petId
end

local function equipPet(player: Player, uid: unknown): (boolean, string)
	local data = DataService.get(player)
	if typeof(uid) ~= "string" or not data or not data.pets[uid] then
		return false, "Invalid pet"
	end
	local _, equipped = countPets(data)
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

function PetService.init()
	petsFolder = Instance.new("Folder")
	petsFolder.Name = "Pets"
	petsFolder.Parent = workspace
end

function PetService.start()
	Net.func("HatchEgg").OnServerInvoke = hatchEgg
	Net.func("EquipPet").OnServerInvoke = equipPet
	Net.func("UnequipPet").OnServerInvoke = unequipPet

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

return PetService
