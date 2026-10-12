-- Loads, saves and replicates player data. Every other service mutates the
-- profile table returned by DataService.get and then calls DataService.changed.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)
local Frogs = require(Shared.Config.Frogs)
local Rebirths = require(Shared.Config.Rebirths)
local Net = require(Shared.Net)

local Stats = require(script.Parent.Parent.Stats)

local DataService = {}

local profiles: { [Player]: any } = {}
local loaded: { [Player]: boolean } = {}
local store: DataStore? = nil

local function template()
	return {
		version = 1,
		hops = 0,
		wins = 0,
		rebirths = 0,
		bestDistance = 0,
		frogs = { [Frogs.Default] = true },
		equippedFrog = Frogs.Default,
		pets = {}, -- [uid: string] = { id: string, equipped: boolean }
		nextPetUid = 1,
		codes = {}, -- [code: string] = true
	}
end

-- Fill in fields added after a player's data was first saved.
local function reconcile(data: any)
	for key, value in template() do
		if data[key] == nil then
			data[key] = value
		end
	end
	if not data.frogs[data.equippedFrog] then
		data.equippedFrog = Frogs.Default
	end
	return data
end

local function retry<T>(attempts: number, fn: () -> T): (boolean, T | string)
	local lastError = ""
	for attempt = 1, attempts do
		local ok, result = pcall(fn)
		if ok then
			return true, result
		end
		lastError = tostring(result)
		task.wait(attempt)
	end
	return false, lastError
end

local function keyFor(player: Player): string
	return "player_" .. player.UserId
end

local function setupLeaderstats(player: Player)
	local folder = Instance.new("Folder")
	folder.Name = "leaderstats"
	for _, name in { "Hops", "Wins", "Rebirths" } do
		local value = Instance.new("NumberValue")
		value.Name = name
		value.Parent = folder
	end
	folder.Parent = player
end

local function updateLeaderstats(player: Player, data: any)
	local folder = player:FindFirstChild("leaderstats")
	if not folder then
		return
	end
	(folder :: any).Hops.Value = data.hops;
	(folder :: any).Wins.Value = data.wins;
	(folder :: any).Rebirths.Value = data.rebirths
end

-- What the client sees: raw data plus derived numbers it shouldn't compute itself.
local function snapshot(player: Player, data: any)
	local multipliers = Stats.snapshot(player, data)
	return {
		hops = data.hops,
		wins = data.wins,
		rebirths = data.rebirths,
		bestDistance = data.bestDistance,
		frogs = data.frogs,
		equippedFrog = data.equippedFrog,
		pets = data.pets,
		multipliers = multipliers, -- full breakdown per stat: { total, parts }
		hopsMultiplier = multipliers.hops.total,
		winsMultiplier = multipliers.wins.total,
		rebirthCost = Rebirths.costFor(data.rebirths),
		maxEquippedPets = Stats.maxEquippedPets(player),
	}
end

function DataService.get(player: Player): any?
	return profiles[player]
end

function DataService.changed(player: Player)
	local data = profiles[player]
	if not data then
		return
	end
	updateLeaderstats(player, data)
	Net.event("DataChanged"):FireClient(player, snapshot(player, data))
end

local function save(player: Player)
	local data = profiles[player]
	if not data or not store or not loaded[player] then
		return
	end
	local ok, err = retry(3, function()
		return (store :: DataStore):UpdateAsync(keyFor(player), function()
			return data
		end)
	end)
	if not ok then
		warn(`[DataService] Failed to save {player.Name}: {err}`)
	end
end

local function onPlayerAdded(player: Player)
	setupLeaderstats(player)

	local data = template()
	if store then
		local ok, result = retry(3, function()
			return (store :: DataStore):GetAsync(keyFor(player))
		end)
		if ok then
			if result ~= nil then
				data = reconcile(result)
			end
			loaded[player] = true
		else
			-- Don't let a failed load overwrite real data with an empty profile.
			warn(`[DataService] Failed to load {player.Name}, saving disabled this session: {result}`)
		end
	end

	if not player.Parent then
		return
	end
	profiles[player] = data
	DataService.changed(player)
end

local function onPlayerRemoving(player: Player)
	save(player)
	profiles[player] = nil
	loaded[player] = nil
end

function DataService.init()
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore(Game.DataStoreName)
	end)
	if ok then
		store = result
	else
		warn(`[DataService] DataStores unavailable ({result}). Progress will not save.`)
		if RunService:IsStudio() then
			warn("[DataService] Enable Game Settings > Security > Enable Studio Access to API Services.")
		end
	end
end

function DataService.start()
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end

	task.spawn(function()
		while true do
			task.wait(Game.AutosaveInterval)
			for player in profiles do
				task.spawn(save, player)
			end
		end
	end)

	game:BindToClose(function()
		local pending = 0
		for player in profiles do
			pending += 1
			task.spawn(function()
				save(player)
				pending -= 1
			end)
		end
		local deadline = os.clock() + 25
		while pending > 0 and os.clock() < deadline do
			task.wait(0.1)
		end
	end)
end

return DataService
