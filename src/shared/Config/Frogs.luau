--!strict
-- Rocks (code name: frogs, kept so saves work): the equipped rock sets
-- Strength gained per bounce.
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
	{ id = "Baby", name = "Pebble", price = 0, perBounce = 1, color = Color3.fromRGB(150, 150, 155) },
	{ id = "Leaf", name = "Mossy Stone", price = 2, perBounce = 2, color = Color3.fromRGB(105, 140, 85) },
	{ id = "Mud", name = "Clay Rock", price = 10, perBounce = 4, color = Color3.fromRGB(170, 110, 70) },
	{ id = "Pond", name = "River Stone", price = 40, perBounce = 8, color = Color3.fromRGB(95, 130, 150) },
	{ id = "Tree", name = "Granite", price = 150, perBounce = 15, color = Color3.fromRGB(185, 160, 155) },
	{ id = "Dart", name = "Toxic Rock", price = 500, perBounce = 30, color = Color3.fromRGB(120, 220, 60) },
	{ id = "Bull", name = "Boulder", price = 1500, perBounce = 60, color = Color3.fromRGB(115, 105, 95) },
	{ id = "Golden", name = "Gold Nugget", price = 4500, perBounce = 120, color = Color3.fromRGB(255, 200, 40) },
	{ id = "Ninja", name = "Shadow Rock", price = 14000, perBounce = 250, color = Color3.fromRGB(55, 45, 75) },
	{ id = "Royal", name = "Royal Gem", price = 40000, perBounce = 500, color = Color3.fromRGB(170, 70, 220) },
	{
		id = "ShootingStar",
		name = "Meteorite",
		price = 0,
		perBounce = 300,
		color = Color3.fromRGB(120, 200, 255),
		rewardOnly = "Daily Day 7",
		ultimate = true,
	},
	{
		id = "Phoenix",
		name = "Phoenix Stone",
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
