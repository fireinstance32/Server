-- World 5: Lava Springs.

local rgb = Color3.fromRGB

return {
	world = "Lava",
	frogs = {
		{ id = "Ember", name = "Ember Frog", price = 1_600_000_000, perBounce = 60_000_000, color = rgb(255, 140, 50) },
		{ id = "Magma", name = "Magma Frog", price = 6_500_000_000, perBounce = 150_000_000, color = rgb(230, 70, 30) },
		{ id = "Obsidian", name = "Obsidian Frog", price = 24_000_000_000, perBounce = 400_000_000, color = rgb(40, 30, 50) },
		{ id = "VolcanoKing", name = "Volcano King", price = 95_000_000_000, perBounce = 1_000_000_000, color = rgb(255, 60, 20) },
	},
	pets = {
		{ id = "EmberPup", name = "Ember Pup", rarity = "Uncommon", bonus = 2_000_000, color = rgb(255, 150, 70) },
		{ id = "MagmaMole", name = "Magma Mole", rarity = "Rare", bonus = 3_000_000, color = rgb(170, 70, 40) },
		{ id = "LavaLizard", name = "Lava Lizard", rarity = "Epic", bonus = 4_800_000, color = rgb(255, 90, 30) },
		{ id = "FireFox", name = "Fire Fox", rarity = "Rare", bonus = 7_000_000, color = rgb(255, 120, 40) },
		{ id = "PhoenixOwl", name = "Phoenix Owl", rarity = "Epic", bonus = 11_000_000, color = rgb(255, 200, 60) },
		{ id = "InfernoDragon", name = "Inferno Dragon", rarity = "Legendary", bonus = 21_000_000, color = rgb(180, 20, 20) },
	},
	eggs = {
		{
			id = "Ember",
			name = "Ember Egg",
			price = 2_400_000_000,
			color = rgb(255, 130, 60),
			position = Vector3.new(-75, 0, -50),
			pets = { { pet = "EmberPup", weight = 60 }, { pet = "MagmaMole", weight = 30 }, { pet = "LavaLizard", weight = 10 } },
		},
		{
			id = "Inferno",
			name = "Inferno Egg",
			price = 32_000_000_000,
			color = rgb(200, 30, 30),
			position = Vector3.new(-55, 0, -50),
			pets = { { pet = "FireFox", weight = 60 }, { pet = "PhoenixOwl", weight = 35 }, { pet = "InfernoDragon", weight = 5 } },
		},
	},
	zones = {
		{ "Ash Shore", rgb(110, 105, 100), Enum.Material.Basalt, { "rock" } },
		{ "Cinder Bend", rgb(90, 80, 75), Enum.Material.Basalt, { "rock", "reed" } },
		{ "Ember Flats", rgb(140, 70, 40), Enum.Material.CrackedLava, { "rock", "rock" } },
		{ "Smoky Steps", rgb(80, 75, 75), Enum.Material.Slate, { "rock", "tree" } },
		{ "Magma Falls", rgb(200, 80, 30), Enum.Material.CrackedLava, { "rock", "mushroom" } },
		{ "Obsidian Ridge", rgb(40, 35, 45), Enum.Material.Basalt, { "rock", "rock" } },
		{ "Sulfur Springs", rgb(210, 190, 80), Enum.Material.Sandstone, { "rock", "reed" } },
		{ "Inferno Gorge", rgb(170, 50, 30), Enum.Material.CrackedLava, { "rock", "tree" } },
		{ "Volcano King's Crater", rgb(255, 90, 30), Enum.Material.CrackedLava, { "rock", "mushroom", "tree" } },
	},
}
