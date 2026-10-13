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
	{ index = 1, id = "Lily", name = "Stone Valley", gateHops = 0, rewardScale = 1, offsetZ = 0, color = Color3.fromRGB(110, 200, 90) },
	{ index = 2, id = "Swamp", name = "Mushroom Swamp", gateHops = 1e6, rewardScale = 25, offsetZ = 4000, color = Color3.fromRGB(150, 90, 200) },
	{ index = 3, id = "Candy", name = "Candy Falls", gateHops = 50e6, rewardScale = 600, offsetZ = 8000, color = Color3.fromRGB(255, 130, 200) },
	{ index = 4, id = "Space", name = "Cosmic Cove", gateHops = 2.5e9, rewardScale = 15000, offsetZ = 12000, color = Color3.fromRGB(90, 110, 255) },
	{ index = 5, id = "Lava", name = "Lava Springs", gateHops = 100e9, rewardScale = 400000, offsetZ = 16000, color = Color3.fromRGB(255, 100, 40) },
} :: { World }

-- Look of each world: plaza checker colours, lily pads, and the lighting
-- the client fades to when you're in that world (Controllers/WorldLighting).
export type Theme = {
	plaza: Color3,
	plazaAlt: Color3,
	pad: Color3,
	lighting: {
		ClockTime: number,
		Brightness: number,
		OutdoorAmbient: Color3,
		atmosphere: Color3,
		density: number,
		tint: Color3,
	},
}

local rgb = Color3.fromRGB
Worlds.Themes = {
	Lily = {
		plaza = rgb(110, 200, 90),
		plazaAlt = rgb(126, 214, 104),
		pad = rgb(70, 175, 70),
		lighting = { ClockTime = 14, Brightness = 2.5, OutdoorAmbient = rgb(150, 150, 150), atmosphere = rgb(200, 230, 255), density = 0.25, tint = rgb(255, 255, 255) },
	},
	Swamp = {
		plaza = rgb(95, 122, 95),
		plazaAlt = rgb(108, 136, 106),
		pad = rgb(95, 155, 90),
		lighting = { ClockTime = 18.2, Brightness = 1.6, OutdoorAmbient = rgb(130, 110, 150), atmosphere = rgb(170, 140, 200), density = 0.35, tint = rgb(235, 225, 255) },
	},
	Candy = {
		plaza = rgb(255, 188, 218),
		plazaAlt = rgb(255, 206, 230),
		pad = rgb(255, 150, 200),
		lighting = { ClockTime = 13, Brightness = 2.8, OutdoorAmbient = rgb(180, 150, 170), atmosphere = rgb(255, 210, 235), density = 0.25, tint = rgb(255, 242, 250) },
	},
	Space = {
		plaza = rgb(78, 80, 112),
		plazaAlt = rgb(94, 96, 132),
		pad = rgb(130, 110, 220),
		lighting = { ClockTime = 0, Brightness = 1.4, OutdoorAmbient = rgb(120, 120, 175), atmosphere = rgb(90, 90, 160), density = 0.2, tint = rgb(220, 226, 255) },
	},
	Lava = {
		plaza = rgb(92, 72, 66),
		plazaAlt = rgb(108, 82, 74),
		pad = rgb(75, 68, 66),
		lighting = { ClockTime = 17.4, Brightness = 1.8, OutdoorAmbient = rgb(170, 110, 90), atmosphere = rgb(255, 140, 90), density = 0.35, tint = rgb(255, 230, 215) },
	},
} :: { [string]: Theme }

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

function Worlds.theme(world: World): Theme
	return Worlds.Themes[world.id] or Worlds.Themes.Lily
end

function Worlds.isUnlocked(world: World, worldsUnlocked: { [string]: boolean }?): boolean
	return world.gateHops <= 0 or (worldsUnlocked ~= nil and worldsUnlocked[world.id] == true)
end

return Worlds
