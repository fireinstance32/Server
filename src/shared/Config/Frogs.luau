--!strict
-- Frogs are the "stones" of Frog Hop: the equipped frog sets Hops gained per pad.
-- Prices step up ~3x, mirroring the pacing of +1 Stone Skipping's World 1.

export type Frog = {
	id: string,
	name: string,
	price: number, -- Wins; ignored when robuxOnly
	perBounce: number,
	color: Color3,
	robuxOnly: boolean?,
}

local Frogs: { Frog } = {
	{ id = "Baby", name = "Baby Frog", price = 0, perBounce = 1, color = Color3.fromRGB(120, 200, 90) },
	{ id = "Leaf", name = "Leaf Frog", price = 2, perBounce = 2, color = Color3.fromRGB(80, 170, 60) },
	{ id = "Mud", name = "Mud Frog", price = 10, perBounce = 4, color = Color3.fromRGB(130, 95, 60) },
	{ id = "Pond", name = "Pond Frog", price = 40, perBounce = 8, color = Color3.fromRGB(60, 150, 140) },
	{ id = "Tree", name = "Tree Frog", price = 150, perBounce = 15, color = Color3.fromRGB(110, 230, 70) },
	{ id = "Dart", name = "Poison Dart Frog", price = 500, perBounce = 30, color = Color3.fromRGB(40, 120, 255) },
	{ id = "Bull", name = "Bullfrog", price = 1500, perBounce = 60, color = Color3.fromRGB(95, 120, 50) },
	{ id = "Golden", name = "Golden Frog", price = 4500, perBounce = 120, color = Color3.fromRGB(255, 200, 40) },
	{ id = "Ninja", name = "Ninja Frog", price = 14000, perBounce = 250, color = Color3.fromRGB(40, 40, 50) },
	{ id = "Royal", name = "Royal Frog", price = 40000, perBounce = 500, color = Color3.fromRGB(170, 70, 220) },
	{
		id = "Phoenix",
		name = "Phoenix Frog",
		price = 0,
		perBounce = 1000,
		color = Color3.fromRGB(255, 90, 30),
		robuxOnly = true,
	},
}

local byId: { [string]: Frog } = {}
for _, frog in Frogs do
	byId[frog.id] = frog
end

return {
	List = Frogs,
	ById = byId,
	Default = "Baby",
}
