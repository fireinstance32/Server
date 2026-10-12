-- Pets ride along and multiply Hops. Equipped multipliers stack additively:
-- total = 1 + sum(multiplier - 1).

export type Rarity = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary" | "Rainbow"

export type Pet = {
	id: string,
	name: string,
	rarity: Rarity,
	multiplier: number,
	color: Color3,
}

export type EggEntry = { pet: string, weight: number }

export type Egg = {
	id: string,
	name: string,
	price: number, -- Wins
	position: Vector3, -- where the egg stand is built
	pets: { EggEntry },
}

local RarityColors: { [Rarity]: Color3 } = {
	Common = Color3.fromRGB(200, 200, 200),
	Uncommon = Color3.fromRGB(90, 220, 90),
	Rare = Color3.fromRGB(70, 150, 255),
	Epic = Color3.fromRGB(180, 80, 255),
	Legendary = Color3.fromRGB(255, 180, 30),
	Rainbow = Color3.fromRGB(255, 80, 160),
}

local Pets: { Pet } = {
	{ id = "Fly", name = "Fly", rarity = "Common", multiplier = 1.1, color = Color3.fromRGB(60, 60, 60) },
	{ id = "Snail", name = "Snail", rarity = "Uncommon", multiplier = 1.25, color = Color3.fromRGB(230, 170, 90) },
	{ id = "Dragonfly", name = "Dragonfly", rarity = "Rare", multiplier = 1.5, color = Color3.fromRGB(70, 200, 230) },
	{ id = "Turtle", name = "Turtle", rarity = "Epic", multiplier = 2, color = Color3.fromRGB(60, 140, 60) },
	{ id = "Duck", name = "Duck", rarity = "Common", multiplier = 1.4, color = Color3.fromRGB(255, 230, 60) },
	{ id = "Fish", name = "Koi Fish", rarity = "Uncommon", multiplier = 1.8, color = Color3.fromRGB(255, 120, 60) },
	{ id = "Crab", name = "Crab", rarity = "Rare", multiplier = 2.5, color = Color3.fromRGB(230, 60, 50) },
	{ id = "Axolotl", name = "Axolotl", rarity = "Legendary", multiplier = 4, color = Color3.fromRGB(255, 150, 200) },
	{ id = "RainbowToad", name = "Rainbow Toad", rarity = "Rainbow", multiplier = 8, color = Color3.fromRGB(255, 80, 160) },
}

local Eggs: { Egg } = {
	{
		id = "Pond",
		name = "Pond Egg",
		price = 50,
		position = Vector3.new(-40, 0, -50),
		pets = {
			{ pet = "Fly", weight = 50 },
			{ pet = "Snail", weight = 30 },
			{ pet = "Dragonfly", weight = 15 },
			{ pet = "Turtle", weight = 5 },
		},
	},
	{
		id = "Swamp",
		name = "Swamp Egg",
		price = 2500,
		position = Vector3.new(-15, 0, -50),
		pets = {
			{ pet = "Duck", weight = 50 },
			{ pet = "Fish", weight = 32 },
			{ pet = "Crab", weight = 15 },
			{ pet = "Axolotl", weight = 2.9 },
			{ pet = "RainbowToad", weight = 0.1 },
		},
	},
}

local petsById: { [string]: Pet } = {}
for _, pet in Pets do
	petsById[pet.id] = pet
end

local eggsById: { [string]: Egg } = {}
for _, egg in Eggs do
	eggsById[egg.id] = egg
end

return {
	List = Pets,
	ById = petsById,
	Eggs = Eggs,
	EggsById = eggsById,
	RarityColors = RarityColors,
}
