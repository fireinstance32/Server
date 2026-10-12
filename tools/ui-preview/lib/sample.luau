-- A believable mid-game player snapshot (same shape as the server's
-- DataService/Snapshot) for UI previews.

local function breakdown(total, parts)
	return { total = total, parts = parts }
end

return function(overrides: { [string]: any }?)
	local data = {
		hops = 128_400,
		wins = 5_230,
		rebirths = 3,
		bestDistance = 980,
		frogs = { Baby = true, Leaf = true, Mud = true, Pond = true, Tree = true },
		equippedFrog = "Tree",
		pets = {
			["1"] = { id = "BrookOtter", equipped = true },
			["2"] = { id = "ReedFox", equipped = true },
			["3"] = { id = "PebblePup", equipped = true },
			["4"] = { id = "CloverBun", equipped = false },
			["5"] = { id = "MossTurtle", equipped = false, locked = true },
		},
		multipliers = {
			hops = breakdown(9.2, {
				{ id = "rebirth", label = "Rebirths", kind = "add", value = 3 },
				{ id = "pets", label = "Pets", kind = "add", value = 7 },
				{ id = "level", label = "Level", kind = "add", value = 0.36 },
			}),
			wins = breakdown(2, { { id = "doubleWins", label = "2x Wins", kind = "mult", value = 2 } }),
			luck = breakdown(1, {}),
		},
		hopsMultiplier = 9.2,
		winsMultiplier = 2,
		level = 18,
		xp = 61,
		xpToNext = 120,
		levelCap = 80,
		maxEquippedPets = 3,
		maxPetInventory = 50,
		discovered = { BrookOtter = true, ReedFox = true, PebblePup = true, CloverBun = true, MossTurtle = true },
		autoDelete = {},
		trails = { Leaf = true },
		equippedTrail = "Leaf",
		potions = { Hops = 2, Wins = 1, Luck = 0 },
		potionTimers = { Hops = 312 },
		daily = { canClaim = true, day = 3, streak = 2 },
		quest = { step = 3, text = "Hatch an egg", progress = 0, target = 1 },
		oneTime = {},
		worldsUnlocked = { Lily = true },
		event = { id = "Halloween2026", currency = 120 },
		passes = { "DoubleWins" },
		friendBoost = 0.1,
	}
	for k, v in overrides or {} do
		data[k] = v
	end
	return data
end
