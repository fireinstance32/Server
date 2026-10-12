-- World 2: Mushroom Swamp.

local rgb = Color3.fromRGB

return {
	world = "Swamp",
	frogs = {
		{ id = "Swamp", name = "Swamp Frog", price = 100_000, perBounce = 1_000, color = rgb(90, 130, 80) },
		{ id = "Mushroom", name = "Mushroom Frog", price = 400_000, perBounce = 2_500, color = rgb(220, 70, 70) },
		{ id = "Bog", name = "Bog Frog", price = 1_500_000, perBounce = 6_000, color = rgb(110, 90, 60) },
		{ id = "ToadKing", name = "Toad King", price = 6_000_000, perBounce = 15_000, color = rgb(170, 110, 230), ultimate = true },
	},
	pets = {
		{ id = "SporeSlime", name = "Spore Slime", rarity = "Uncommon", bonus = 150, color = rgb(150, 230, 120) },
		{ id = "BogBat", name = "Bog Bat", rarity = "Rare", bonus = 220, color = rgb(90, 70, 120) },
		{ id = "CapToad", name = "Cap Toad", rarity = "Epic", bonus = 350, color = rgb(230, 80, 80) },
		{ id = "GlowMoth", name = "Glow Moth", rarity = "Rare", bonus = 500, color = rgb(190, 240, 255) },
		{ id = "WitchCat", name = "Witch Cat", rarity = "Epic", bonus = 800, color = rgb(60, 40, 90) },
		{ id = "SwampDragon", name = "Swamp Dragon", rarity = "Legendary", bonus = 1_500, color = rgb(80, 160, 110) },
	},
	eggs = {
		{
			id = "Swamp",
			name = "Swamp Egg",
			price = 150_000,
			color = rgb(120, 170, 110),
			position = Vector3.new(-75, 0, -50),
			pets = { { pet = "SporeSlime", weight = 60 }, { pet = "BogBat", weight = 30 }, { pet = "CapToad", weight = 10 } },
		},
		{
			id = "Mushroom",
			name = "Mushroom Egg",
			price = 2_000_000,
			color = rgb(220, 90, 90),
			position = Vector3.new(-55, 0, -50),
			pets = { { pet = "GlowMoth", weight = 60 }, { pet = "WitchCat", weight = 35 }, { pet = "SwampDragon", weight = 5 } },
		},
	},
	zones = {
		{ "Toadstool Shore", rgb(120, 110, 150), Enum.Material.Mud, { "mushroom", "reed" } },
		{ "Bog Bend", rgb(95, 120, 100), Enum.Material.Mud, { "reed", "willow" } },
		{ "Glowcap Grove", rgb(80, 90, 130), Enum.Material.LeafyGrass, { "mushroom", "tree" } },
		{ "Murky Mire", rgb(85, 100, 80), Enum.Material.Mud, { "willow", "rock" } },
		{ "Spore Falls", rgb(110, 90, 140), Enum.Material.Slate, { "rock", "mushroom" } },
		{ "Witch's Hollow", rgb(70, 60, 100), Enum.Material.LeafyGrass, { "tree", "mushroom" } },
		{ "Fogfen", rgb(120, 130, 125), Enum.Material.Mud, { "reed", "rock" } },
		{ "Moonlit Marsh", rgb(60, 70, 120), Enum.Material.Grass, { "willow", "mushroom" } },
		{ "Swamp King's Throne", rgb(150, 110, 200), Enum.Material.Grass, { "mushroom", "tree", "rock" } },
	},
}
