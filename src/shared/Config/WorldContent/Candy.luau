-- World 3: Candy Falls.

local rgb = Color3.fromRGB

return {
	world = "Candy",
	frogs = {
		{ id = "Gummy", name = "Gummy Frog", price = 2_500_000, perBounce = 40_000, color = rgb(255, 120, 150) },
		{ id = "Lollipop", name = "Lollipop Frog", price = 10_000_000, perBounce = 100_000, color = rgb(255, 80, 200) },
		{ id = "Cupcake", name = "Cupcake Frog", price = 36_000_000, perBounce = 250_000, color = rgb(250, 200, 160) },
		{ id = "CandyKing", name = "Candy King", price = 150_000_000, perBounce = 600_000, color = rgb(255, 230, 90) },
	},
	pets = {
		{ id = "GummyBear", name = "Gummy Bear", rarity = "Uncommon", bonus = 3_500, color = rgb(255, 110, 110) },
		{ id = "CottonLamb", name = "Cotton Candy Lamb", rarity = "Rare", bonus = 5_000, color = rgb(255, 190, 230) },
		{ id = "LollipopPup", name = "Lollipop Pup", rarity = "Epic", bonus = 8_000, color = rgb(160, 120, 255) },
		{ id = "ChocoBunny", name = "Choco Bunny", rarity = "Rare", bonus = 12_000, color = rgb(120, 70, 40) },
		{ id = "CandyUnicorn", name = "Candy Unicorn", rarity = "Epic", bonus = 20_000, color = rgb(255, 240, 250) },
		{ id = "SugarDragon", name = "Sugar Dragon", rarity = "Legendary", bonus = 36_000, color = rgb(120, 230, 255) },
	},
	eggs = {
		{
			id = "Candy",
			name = "Candy Egg",
			price = 3_600_000,
			color = rgb(255, 150, 200),
			position = Vector3.new(-75, 0, -50),
			pets = { { pet = "GummyBear", weight = 60 }, { pet = "CottonLamb", weight = 30 }, { pet = "LollipopPup", weight = 10 } },
		},
		{
			id = "Cupcake",
			name = "Cupcake Egg",
			price = 48_000_000,
			color = rgb(250, 210, 170),
			position = Vector3.new(-55, 0, -50),
			pets = { { pet = "ChocoBunny", weight = 60 }, { pet = "CandyUnicorn", weight = 35 }, { pet = "SugarDragon", weight = 5 } },
		},
	},
	zones = {
		{ "Sprinkle Shore", rgb(255, 200, 220), Enum.Material.SmoothPlastic, { "flower", "mushroom" } },
		{ "Gumdrop Bend", rgb(255, 150, 180), Enum.Material.SmoothPlastic, { "mushroom", "flower" } },
		{ "Lollipop Lane", rgb(200, 160, 255), Enum.Material.SmoothPlastic, { "tree", "flower" } },
		{ "Taffy Twist", rgb(255, 180, 140), Enum.Material.SmoothPlastic, { "rock", "flower" } },
		{ "Chocolate Falls", rgb(130, 80, 50), Enum.Material.Mud, { "rock", "mushroom" } },
		{ "Marshmallow Meadow", rgb(250, 245, 240), Enum.Material.Snow, { "tree", "flower" } },
		{ "Jellybean Jungle", rgb(140, 230, 140), Enum.Material.SmoothPlastic, { "palm", "mushroom" } },
		{ "Caramel Canyon", rgb(220, 150, 70), Enum.Material.Sandstone, { "rock", "palm" } },
		{ "Candy King's Castle", rgb(255, 220, 100), Enum.Material.SmoothPlastic, { "tree", "flower", "mushroom" } },
	},
}
