-- Worlds. Each world is a full hub (plaza, Hop Zone, river, ponds, frog
-- podiums, eggs) built in the same local layout and moved to its own place
-- along +Z. Runtime code converts a world position to (world, local
-- position) and reuses the World 1 layout functions.

export type World = {
	index: number,
	id: string,
	name: string,
	gateHops: number, -- Hops needed (once) to unlock
	rewardScale: number, -- zone Wins multiplier in this world
	offsetZ: number,
	color: Color3,
}

local Worlds = {}

Worlds.List = {
	{ index = 1, id = "Lily", name = "Lily Valley", gateHops = 0, rewardScale = 1, offsetZ = 0, color = Color3.fromRGB(110, 200, 90) },
	{ index = 2, id = "Swamp", name = "Mushroom Swamp", gateHops = 1e6, rewardScale = 25, offsetZ = 4000, color = Color3.fromRGB(150, 90, 200) },
	{ index = 3, id = "Candy", name = "Candy Falls", gateHops = 50e6, rewardScale = 600, offsetZ = 8000, color = Color3.fromRGB(255, 130, 200) },
	{ index = 4, id = "Space", name = "Cosmic Cove", gateHops = 2.5e9, rewardScale = 15000, offsetZ = 12000, color = Color3.fromRGB(90, 110, 255) },
	{ index = 5, id = "Lava", name = "Lava Springs", gateHops = 100e9, rewardScale = 400000, offsetZ = 16000, color = Color3.fromRGB(255, 100, 40) },
} :: { World }

Worlds.ById = {} :: { [string]: World }
for _, world in Worlds.List do
	Worlds.ById[world.id] = world
end

Worlds.Default = "Lily"
Worlds.BandHalfWidth = 1000 -- a position belongs to the world whose offsetZ is within this

-- Which world a Z coordinate is in (pure, testable).
function Worlds.indexAtZ(z: number): number?
	for _, world in Worlds.List do
		if math.abs(z - world.offsetZ) <= Worlds.BandHalfWidth then
			return world.index
		end
	end
	return nil
end

function Worlds.offset(world: World): Vector3
	return Vector3.new(0, 0, world.offsetZ)
end

-- (world, position relative to that world's layout), or nil outside all worlds.
function Worlds.toLocal(position: Vector3): (World?, Vector3)
	local index = Worlds.indexAtZ(position.Z)
	local world = index and Worlds.List[index]
	if not world then
		return nil, position
	end
	return world, position - Worlds.offset(world)
end

function Worlds.isUnlocked(world: World, worldsUnlocked: { [string]: boolean }?): boolean
	return world.gateHops <= 0 or (worldsUnlocked ~= nil and worldsUnlocked[world.id] == true)
end

return Worlds
