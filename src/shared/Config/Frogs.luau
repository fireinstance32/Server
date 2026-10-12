--!strict
-- Frogs are the "stones" of Frog Hop: the equipped frog sets Hops gained per pad.
-- Prices step up ~3x, mirroring the pacing of +1 Stone Skipping's World 1.

local WorldContent = require(script.Parent.WorldContent) :: { any }

export type Frog = {
	id: string,
	name: string,
	price: number, -- Wins; ignored when robuxOnly
	perBounce: number,
	color: Color3,
	robuxOnly: boolean?,
	rewardOnly: string?, -- can't be bought; how to get it (shown on the podium)
	world: string?, -- world whose podiums sell it (nil = Lily Valley)
	ultimate: boolean?, -- river hops play the ultimate cut-in (cosmetic)
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
		id = "ShootingStar",
		name = "Shooting Star Frog",
		price = 0,
		perBounce = 300,
		color = Color3.fromRGB(120, 200, 255),
		rewardOnly = "Daily Day 7",
		ultimate = true,
	},
	{
		id = "Phoenix",
		name = "Phoenix Frog",
		price = 0,
		perBounce = 1000,
		color = Color3.fromRGB(255, 90, 30),
		robuxOnly = true,
		ultimate = true,
	},
}

-- Frogs for Worlds 2–5 live in WorldContent/<World>.luau.
for _, content in WorldContent do
	for _, frog in content.frogs do
		local entry: Frog = table.clone(frog)
		entry.world = content.world
		table.insert(Frogs, entry)
	end
end

local byId: { [string]: Frog } = {}
for _, frog in Frogs do
	byId[frog.id] = frog
end

-- Podium row in the plaza (reference: stones on pedestals). Computed in a
-- function so this module still loads in offline tests.
local PodiumRowZ = -120
local PodiumStartX = -235
local PodiumSpacing = 20

-- Frogs sold in a world, in podium order.
local function forWorld(worldId: string): { Frog }
	local list = {}
	for _, frog in Frogs do
		if (frog.world or "Lily") == worldId then
			table.insert(list, frog)
		end
	end
	return list
end

-- Local position (within a world's layout) of the index-th podium.
local function podiumPosition(index: number): Vector3
	return Vector3.new(PodiumStartX + (index - 1) * PodiumSpacing, 0.5, PodiumRowZ)
end

return {
	List = Frogs,
	ById = byId,
	Default = "Baby",
	podiumPosition = podiumPosition,
	forWorld = forWorld,
}
