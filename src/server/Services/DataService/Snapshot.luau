-- What the client sees: raw data plus derived numbers it shouldn't compute itself.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local DailyRewards = require(Shared.Config.DailyRewards)
local Quests = require(Shared.Config.Quests)
local Levels = require(Shared.Config.Levels)

local Stats = require(script.Parent.Parent.Parent.Stats)
local Passes = require(script.Parent.Parent.Parent.Passes)

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

return function(player: Player, data: any)
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
		oneTime = data.oneTime,
		worldsUnlocked = data.worldsUnlocked,
		equippedTrail = data.equippedTrail,
		event = data.event,
		passes = Passes.ownedList(player),
		friendBoost = player:GetAttribute("FriendBoost") or 0,
	}
end
