-- Loads, saves and replicates player data. Every other service mutates the
-- profile table returned by DataService.get and then calls DataService.changed.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)
local Frogs = require(Shared.Config.Frogs)
local Pets = require(Shared.Config.Pets)
local DailyRewards = require(Shared.Config.DailyRewards)
local Quests = require(Shared.Config.Quests)
local Levels = require(Shared.Config.Levels)
local Net = require(Shared.Net)

local Stats = require(script.Parent.Parent.Stats)
local Passes = require(script.Parent.Parent.Passes)
local Leaderstats = require(script.Parent.Parent.Leaderstats)

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
		level = 1,
		xp = 0, -- progress toward the next level
		bestDistance = 0,
		frogs = { [Frogs.Default] = true },
		equippedFrog = Frogs.Default,
		pets = {}, -- [uid: string] = { id: string, equipped: boolean, locked: boolean? }
		discovered = {}, -- [petId] = true once hatched (for NEW! and the index)
		autoDelete = {}, -- [rarity] = true: delete those pets right after hatching
		trails = {}, -- [trailId] = true (equippedTrail: string? is set when one is worn)
		potions = {}, -- [potionId] = count
		activePotions = {}, -- [potionId] = expiry (os.time)
		daily = { lastDay = 0, streak = 0 }, -- UTC day number of the last claim
		lastSeen = 0, -- os.time() of the last save (offline training)
		questStep = 1, -- current tutorial quest (past the end = done)
		stats = { winsEarned = 0, launches = 0, hatched = 0 }, -- lifetime counters
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
	for key, value in template().stats do
		if data.stats[key] == nil then
			data.stats[key] = value
		end
	end
	-- Convert pets from the v0.1 test build to their new ids.
	for _, pet in data.pets do
		local newId = Pets.Legacy[pet.id]
		if newId then
			pet.id = newId
		end
		data.discovered[pet.id] = true
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

-- Daily reward status, without requiring DailyService (it requires us).
local function dailyStatus(data: any)
	local today = DailyRewards.dayNumber(os.time())
	local canClaim, day = DailyRewards.status(data.daily.lastDay, data.daily.streak, today)
	return { canClaim = canClaim, day = day, streak = data.daily.streak }
end

-- Current tutorial quest for the quest bar, or nil when finished.
local function questStatus(data: any)
	local quest = Quests.List[data.questStep]
	if not quest then
		return nil
	end
	return {
		step = data.questStep,
		text = quest.text,
		progress = math.min(quest.progress(data), quest.target),
		target = quest.target,
	}
end

-- Seconds left on each active potion.
local function potionTimers(data: any): { [string]: number }
	local timers = {}
	for id, expiry in data.activePotions do
		timers[id] = math.max(expiry - os.time(), 0)
	end
	return timers
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
		level = data.level,
		xp = data.xp,
		xpToNext = Levels.xpForLevel(data.level),
		levelCap = Levels.capFor(data.rebirths),
		maxEquippedPets = Stats.maxEquippedPets(player),
		maxPetInventory = Stats.maxPetInventory(player),
		discovered = data.discovered,
		autoDelete = data.autoDelete,
		trails = data.trails,
		potions = data.potions,
		potionTimers = potionTimers(data),
		daily = dailyStatus(data),
		quest = questStatus(data),
		equippedTrail = data.equippedTrail,
		passes = Passes.ownedList(player),
		friendBoost = player:GetAttribute("FriendBoost") or 0,
	}
end

function DataService.get(player: Player): any?
	return profiles[player]
end

-- Replace a player's profile with a fresh one (dev/testing only).
function DataService.reset(player: Player)
	if profiles[player] then
		profiles[player] = template()
		DataService.changed(player)
	end
end

-- Fires (player, data) after every change, for server systems that react
-- to data (e.g. the frog held in hand).
local changedEvent = Instance.new("BindableEvent")
DataService.Changed = changedEvent.Event

-- Fires (player, data) once a player's profile has loaded.
local loadedEvent = Instance.new("BindableEvent")
DataService.Loaded = loadedEvent.Event

function DataService.changed(player: Player)
	local data = profiles[player]
	if not data then
		return
	end
	Leaderstats.update(player, data)
	Net.event("DataChanged"):FireClient(player, snapshot(player, data))
	changedEvent:Fire(player, data)
end

local function save(player: Player)
	local data = profiles[player]
	if not data or not store or not loaded[player] then
		return
	end
	data.lastSeen = os.time()
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
	Leaderstats.setup(player)

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
	loadedEvent:Fire(player, data)
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
