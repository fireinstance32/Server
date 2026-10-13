-- Pets and eggs. Pets are cube animals (reference: Pebble Pup, Brook Otter,
-- Clover Bun). Each pet ADDS its bonus to the Hops multiplier ("+2" means
-- x7 → x9), like the reference game.

local WorldContent = require(script.Parent.WorldContent) :: { any }
local Lobby = require(script.Parent.Lobby)
local Events = require(script.Parent.Events) :: any

export type Rarity = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary" | "Rainbow"

export type Pet = {
	id: string,
	name: string,
	rarity: Rarity,
	bonus: number, -- added to the Hops multiplier while equipped
	color: Color3,
}

export type EggEntry = { pet: string, weight: number }

export type Egg = {
	id: string,
	name: string,
	price: number, -- Wins (ignored for Robux eggs)
	product: string?, -- Robux developer product name (Config/Monetization)
	color: Color3,
	position: Vector3, -- local position within its world's layout
	world: string?, -- nil = Lily Valley
	event: string?, -- seasonal event id: price is in that event's currency
	pets: { EggEntry },
}

-- Rarity tiers in order. Luck multiplies the hatch weight of every pet at
-- LuckMinRarity or rarer.
local RarityOrder: { [Rarity]: number } = {
	Common = 1,
	Uncommon = 2,
	Rare = 3,
	Epic = 4,
	Legendary = 5,
	Rainbow = 6,
}
local LuckMinRarity = 3

local RarityColors: { [Rarity]: Color3 } = {
	Common = Color3.fromRGB(200, 200, 200),
	Uncommon = Color3.fromRGB(90, 220, 90),
	Rare = Color3.fromRGB(70, 150, 255),
	Epic = Color3.fromRGB(180, 80, 255),
	Legendary = Color3.fromRGB(255, 180, 30),
	Rainbow = Color3.fromRGB(255, 80, 160),
}

local function pet(id: string, name: string, rarity: Rarity, bonus: number, color: Color3): Pet
	return { id = id, name = name, rarity = rarity, bonus = bonus, color = color }
end

local Pets: { Pet } = {
	-- Common Egg
	pet("PebblePup", "Pebble Pup", "Common", 1, Color3.fromRGB(220, 170, 120)),
	pet("CloverBun", "Clover Bun", "Uncommon", 1.5, Color3.fromRGB(170, 230, 170)),
	pet("BrookOtter", "Brook Otter", "Rare", 2, Color3.fromRGB(190, 110, 60)),
	pet("MossTurtle", "Moss Turtle", "Epic", 3, Color3.fromRGB(80, 150, 80)),
	-- Uncommon Egg
	pet("LilyFrogling", "Moss Golem", "Common", 3, Color3.fromRGB(120, 210, 90)),
	pet("ReedFox", "Reed Fox", "Uncommon", 4, Color3.fromRGB(240, 140, 60)),
	pet("PondPanda", "Bamboo Panda", "Rare", 6, Color3.fromRGB(240, 240, 240)),
	pet("DragonflyKitty", "Dragonfly Kitty", "Epic", 9, Color3.fromRGB(110, 200, 240)),
	-- Rare Egg
	pet("FireflyBear", "Firefly Bear", "Uncommon", 8, Color3.fromRGB(250, 220, 90)),
	pet("WillowOwl", "Willow Owl", "Rare", 12, Color3.fromRGB(150, 120, 90)),
	pet("CrystalAxolotl", "Crystal Axolotl", "Epic", 18, Color3.fromRGB(255, 160, 210)),
	pet("GoldenToad", "Golden Toad", "Legendary", 30, Color3.fromRGB(255, 200, 40)),
	-- Reward-only (daily rewards)
	pet("FortuneNeko", "Fortune Neko", "Rare", 5, Color3.fromRGB(255, 225, 190)),
	-- Reward-only (Starter Pack)
	pet("StarterUnicat", "Rainbow Unicat", "Legendary", 25, Color3.fromRGB(250, 245, 255)),
	-- Rainbow Egg (Robux)
	pet("RainbowFrog", "Rainbow Golem", "Legendary", 40, Color3.fromRGB(255, 90, 160)),
	pet("GalaxyCat", "Galaxy Cat", "Legendary", 60, Color3.fromRGB(90, 70, 200)),
	pet("PrismDragon", "Prism Dragon", "Rainbow", 120, Color3.fromRGB(120, 255, 230)),
}

local Eggs: { Egg } = {
	{
		id = "Common",
		name = "Common Egg",
		price = 50,
		color = Color3.fromRGB(245, 245, 245),
		position = Lobby.egg(2),
		pets = {
			{ pet = "PebblePup", weight = 40 },
			{ pet = "CloverBun", weight = 30 },
			{ pet = "BrookOtter", weight = 20 },
			{ pet = "MossTurtle", weight = 10 },
		},
	},
	{
		id = "Uncommon",
		name = "Uncommon Egg",
		price = 500,
		color = Color3.fromRGB(110, 220, 110),
		position = Lobby.egg(3),
		pets = {
			{ pet = "LilyFrogling", weight = 40 },
			{ pet = "ReedFox", weight = 30 },
			{ pet = "PondPanda", weight = 20 },
			{ pet = "DragonflyKitty", weight = 10 },
		},
	},
	{
		id = "Rare",
		name = "Rare Egg",
		price = 4000,
		color = Color3.fromRGB(90, 170, 255),
		position = Lobby.egg(4),
		pets = {
			{ pet = "FireflyBear", weight = 45 },
			{ pet = "WillowOwl", weight = 35 },
			{ pet = "CrystalAxolotl", weight = 17 },
			{ pet = "GoldenToad", weight = 3 },
		},
	},
	{
		id = "Rainbow",
		name = "Rainbow Egg",
		price = 0,
		product = "RainbowEgg",
		color = Color3.fromRGB(255, 120, 200),
		position = Lobby.egg(5),
		pets = {
			{ pet = "RainbowFrog", weight = 60 },
			{ pet = "GalaxyCat", weight = 35 },
			{ pet = "PrismDragon", weight = 5 },
		},
	},
}

-- Pets and eggs for Worlds 2–5 live in WorldContent/<World>.luau.
for _, content in WorldContent do
	for _, p in content.pets do
		table.insert(Pets, p :: Pet)
	end
	for _, egg in content.eggs do
		local entry: Egg = table.clone(egg)
		entry.world = content.world
		table.insert(Eggs, entry)
	end
end

-- Seasonal event pets and eggs (Config/Events); event eggs stand in Lily Valley.
for _, event in Events.List do
	for _, p in event.pets do
		table.insert(Pets, p :: Pet)
	end
	table.insert(Eggs, event.egg :: Egg)
end

-- Multi-hatch: how many eggs at once each pass allows (reference "+3 / +8").
local MultiHatch = {
	{ count = 3, pass = "HatchTriple" },
	{ count = 8, pass = "HatchOcto" },
}

local petsById: { [string]: Pet } = {}
for _, p in Pets do
	petsById[p.id] = p
end

local eggsById: { [string]: Egg } = {}
for _, egg in Eggs do
	eggsById[egg.id] = egg
end

-- Eggs placed in a world's hub.
local function eggsForWorld(worldId: string): { Egg }
	local list = {}
	for _, egg in Eggs do
		if (egg.world or "Lily") == worldId then
			table.insert(list, egg)
		end
	end
	return list
end

return {
	eggsForWorld = eggsForWorld,
	List = Pets,
	ById = petsById,
	Eggs = Eggs,
	EggsById = eggsById,
	RarityColors = RarityColors,
	RarityOrder = RarityOrder,
	LuckMinRarity = LuckMinRarity,
	MultiHatch = MultiHatch,
}
