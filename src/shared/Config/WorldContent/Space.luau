-- World 4: Cosmic Cove.

local rgb = Color3.fromRGB

return {
	world = "Space",
	frogs = {
		{ id = "Astro", name = "Moon Rock", price = 60_000_000, perBounce = 1_500_000, color = rgb(230, 230, 240) },
		{ id = "Comet", name = "Comet Rock", price = 250_000_000, perBounce = 4_000_000, color = rgb(110, 200, 255) },
		{ id = "Nebula", name = "Nebula Rock", price = 900_000_000, perBounce = 10_000_000, color = rgb(170, 90, 255) },
		{ id = "GalaxyKing", name = "Galaxy King", price = 3_600_000_000, perBounce = 25_000_000, color = rgb(60, 40, 160), ultimate = true },
	},
	pets = {
		{ id = "MoonMouse", name = "Moon Mouse", rarity = "Uncommon", bonus = 80_000, color = rgb(210, 210, 220) },
		{ id = "StarPuppy", name = "Star Puppy", rarity = "Rare", bonus = 120_000, color = rgb(255, 230, 120) },
		{ id = "AlienCat", name = "Alien Cat", rarity = "Epic", bonus = 190_000, color = rgb(120, 255, 120) },
		{ id = "CometFox", name = "Comet Fox", rarity = "Rare", bonus = 280_000, color = rgb(120, 190, 255) },
		{ id = "AstroOwl", name = "Astro Owl", rarity = "Epic", bonus = 450_000, color = rgb(80, 80, 140) },
		{ id = "NebulaDragon", name = "Nebula Dragon", rarity = "Legendary", bonus = 850_000, color = rgb(200, 90, 255) },
	},
	eggs = {
		{
			id = "Moon",
			name = "Moon Egg",
			price = 90_000_000,
			color = rgb(200, 200, 215),
			position = Vector3.new(-75, 0, -50),
			pets = { { pet = "MoonMouse", weight = 60 }, { pet = "StarPuppy", weight = 30 }, { pet = "AlienCat", weight = 10 } },
		},
		{
			id = "Galaxy",
			name = "Galaxy Egg",
			price = 1_200_000_000,
			color = rgb(110, 70, 220),
			position = Vector3.new(-55, 0, -50),
			pets = { { pet = "CometFox", weight = 60 }, { pet = "AstroOwl", weight = 35 }, { pet = "NebulaDragon", weight = 5 } },
		},
	},
	zones = {
		{ "Launch Pad", rgb(170, 170, 185), Enum.Material.DiamondPlate, { "rock", "crystal" }, "🚀" },
		{ "Moon Dust", rgb(200, 200, 205), Enum.Material.Sand, { "rock", "rock" }, "🌕" },
		{ "Crater Bend", rgb(140, 140, 155), Enum.Material.Slate, { "rock", "crystal" }, "☄️" },
		{ "Asteroid Belt", rgb(110, 100, 95), Enum.Material.Basalt, { "rock", "rock", "crystal" }, "☄️" },
		{ "Starlight Shore", rgb(90, 90, 160), Enum.Material.Glacier, { "crystal", "flower" }, "⭐" },
		{ "Ring Rapids", rgb(210, 180, 130), Enum.Material.Sandstone, { "rock", "crystal" }, "🪐" },
		{ "Nebula Mist", rgb(130, 80, 180), Enum.Material.Glacier, { "crystal", "mushroom" }, "🌌" },
		{ "Comet Trail", rgb(80, 140, 200), Enum.Material.Ice, { "ice", "crystal" }, "☄️" },
		{ "Galaxy King's Station", rgb(60, 50, 130), Enum.Material.DiamondPlate, { "crystal", "crystal", "rock" }, "👑" },
	},
}
