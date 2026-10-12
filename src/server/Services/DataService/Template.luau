-- The shape of a brand-new profile, and upgrading older saves to it.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Frogs = require(Shared.Config.Frogs)
local Settings = require(Shared.Config.Settings)

local Template = {}

-- Old pet ids from the v0.1 test build, converted on load so nobody loses pets.
local Legacy: { [string]: string } = {
	Fly = "PebblePup",
	Snail = "CloverBun",
	Dragonfly = "BrookOtter",
	Turtle = "MossTurtle",
	Duck = "LilyFrogling",
	Fish = "ReedFox",
	Crab = "PondPanda",
	Axolotl = "CrystalAxolotl",
	RainbowToad = "RainbowFrog",
}

function Template.new()
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
		-- Lifetime counters (quests, leaderboards, analytics).
		stats = { winsEarned = 0, launches = 0, hatched = 0, timePlayed = 0, robuxSpent = 0 },
		funnelStep = 0, -- last onboarding analytics step logged
		event = { id = "", currency = 0 }, -- current seasonal event and its currency
		receipts = {}, -- [PurchaseId] = true for recent Robux receipts (no double grants)
		receiptOrder = {}, -- oldest → newest PurchaseIds, trimmed to the last 50
		oneTime = {}, -- [productName] = true for one-time offers already bought
		giftedPasses = {}, -- [passName] = true for passes received as gifts
		worldsUnlocked = { Lily = true }, -- [worldId] = true once unlocked
		nextPetUid = 1,
		codes = {}, -- [code: string] = true
		settings = Settings.defaults(), -- [settingId] = on/off or 0-100 (Config/Settings)
		titles = {}, -- [titleId] = true once unlocked (Config/Titles)
		equippedTitle = "", -- worn title id, "" for none
	}
end

-- Fill in fields added after a player's data was first saved.
function Template.reconcile(data: any)
	local fresh = Template.new()
	for key, value in fresh do
		if data[key] == nil then
			data[key] = value
		end
	end
	if not data.frogs[data.equippedFrog] then
		data.equippedFrog = Frogs.Default
	end
	for key, value in fresh.stats do
		if data.stats[key] == nil then
			data.stats[key] = value
		end
	end
	for key, value in fresh.settings do
		local clean = Settings.sanitize(Settings.ById[key], data.settings[key])
		data.settings[key] = if clean == nil then value else clean
	end
	-- Convert pets from the v0.1 test build to their new ids.
	for _, pet in data.pets do
		local newId = Legacy[pet.id]
		if newId then
			pet.id = newId
		end
		data.discovered[pet.id] = true
	end
	return data
end

return Template
