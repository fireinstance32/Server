-- Trails follow your frog while it hops (reference: Void Trail, Rainbow
-- Trail). Each adds a small bonus to the Hops multiplier while equipped.

export type Trail = {
	id: string,
	name: string,
	price: number, -- Wins (ignored when product is set)
	product: string?, -- Robux developer product name (Config/Monetization)
	bonus: number,
	colors: { Color3 },
}

local Trails: { Trail } = {
	{ id = "Leaf", name = "Leaf Trail", price = 1000, bonus = 0.5, colors = { Color3.fromRGB(120, 220, 90), Color3.fromRGB(40, 140, 50) } },
	{ id = "Bubble", name = "Bubble Trail", price = 10000, bonus = 1, colors = { Color3.fromRGB(180, 230, 255), Color3.fromRGB(80, 160, 255) } },
	{ id = "Firefly", name = "Firefly Trail", price = 50000, bonus = 2, colors = { Color3.fromRGB(255, 240, 120), Color3.fromRGB(255, 170, 40) } },
	{ id = "Sunset", name = "Sunset Trail", price = 250000, bonus = 4, colors = { Color3.fromRGB(255, 120, 80), Color3.fromRGB(180, 60, 200) } },
	{
		id = "Rainbow",
		name = "Rainbow Trail",
		price = 0,
		product = "RainbowTrail",
		bonus = 10,
		colors = {
			Color3.fromRGB(255, 70, 70),
			Color3.fromRGB(255, 200, 40),
			Color3.fromRGB(80, 220, 90),
			Color3.fromRGB(70, 160, 255),
			Color3.fromRGB(190, 90, 255),
		},
	},
	{ id = "Void", name = "Void Trail", price = 0, product = "VoidTrail", bonus = 15, colors = { Color3.fromRGB(120, 40, 200), Color3.fromRGB(10, 10, 20) } },
}

local byId: { [string]: Trail } = {}
for _, trail in Trails do
	byId[trail.id] = trail
end

return {
	List = Trails,
	ById = byId,
}
