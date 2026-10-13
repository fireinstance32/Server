--!strict
-- Throw-lane zones for World 1 (other worlds are built from these below). A
-- throw that lands at or past a zone's distance earns that zone's Wins.
-- Distances are studs from the river origin.

local Worlds = require(script.Parent.Worlds) :: any
local WorldContent = require(script.Parent.WorldContent) :: { any }

export type PropKind =
	"tree" | "palm" | "willow" | "rock" | "reed" | "flower" | "mushroom"
	| "cactus" | "autumn" | "pine" | "ice" | "lollipop" | "candy" | "crystal" | "pumpkin" | "bush"

export type Zone = {
	index: number,
	name: string,
	icon: string, -- emoji either side of the zone's sign over the lane
	distance: number,
	wins: number,
	color: Color3, -- sign + toast colour
	-- Biome look for this stretch of the throw lane (reference: every zone
	-- has its own grass, checker walls and water tint):
	bank: Color3, -- grass on top of the banks
	wall: { Color3 }, -- the two checker colours of the lane walls
	water: Color3, -- riverbed tint seen through the water
	props: { PropKind },
}

local rgb = Color3.fromRGB

local Zones: { Zone } = {
	{
		index = 1, name = "Pebble Beach", icon = "🌴", distance = 0, wins = 1,
		color = rgb(90, 225, 215),
		bank = rgb(120, 215, 100), wall = { rgb(205, 110, 80), rgb(240, 175, 130) }, water = rgb(40, 190, 235),
		props = { "palm", "bush", "rock", "flower" },
	},
	{
		index = 2, name = "Cactus Canyon", icon = "🌵", distance = 100, wins = 3,
		color = rgb(130, 215, 110),
		bank = rgb(240, 205, 140), wall = { rgb(215, 150, 95), rgb(245, 215, 165) }, water = rgb(60, 200, 210),
		props = { "cactus", "cactus", "rock" },
	},
	{
		index = 3, name = "Maple Woods", icon = "🍁", distance = 250, wins = 8,
		color = rgb(255, 150, 70),
		bank = rgb(230, 160, 75), wall = { rgb(150, 70, 50), rgb(205, 120, 80) }, water = rgb(245, 150, 90),
		props = { "autumn", "autumn", "pumpkin" },
	},
	{
		index = 4, name = "Snowy Pines", icon = "❄️", distance = 450, wins = 20,
		color = rgb(150, 210, 255),
		bank = rgb(240, 246, 255), wall = { rgb(170, 185, 230), rgb(225, 232, 250) }, water = rgb(150, 195, 245),
		props = { "pine", "pine", "ice" },
	},
	{
		index = 5, name = "Toadstool Bog", icon = "🍄", distance = 700, wins = 50,
		color = rgb(150, 230, 90),
		bank = rgb(115, 175, 80), wall = { rgb(85, 70, 60), rgb(130, 105, 85) }, water = rgb(140, 200, 90),
		props = { "mushroom", "mushroom", "reed", "bush" },
	},
	{
		index = 6, name = "Candy Coast", icon = "🍭", distance = 1000, wins = 120,
		color = rgb(255, 130, 200),
		bank = rgb(255, 190, 220), wall = { rgb(235, 130, 180), rgb(255, 220, 238) }, water = rgb(255, 120, 200),
		props = { "lollipop", "candy", "lollipop" },
	},
	{
		index = 7, name = "Crystal Caverns", icon = "💎", distance = 1400, wins = 300,
		color = rgb(170, 140, 255),
		bank = rgb(150, 125, 220), wall = { rgb(95, 75, 165), rgb(165, 145, 235) }, water = rgb(135, 100, 245),
		props = { "crystal", "crystal", "rock" },
	},
	{
		index = 8, name = "Sunset Lagoon", icon = "🌅", distance = 1900, wins = 700,
		color = rgb(255, 150, 90),
		bank = rgb(250, 205, 145), wall = { rgb(230, 125, 90), rgb(250, 185, 135) }, water = rgb(255, 140, 110),
		props = { "palm", "flower", "rock" },
	},
	{
		index = 9, name = "King's Quarry", icon = "👑", distance = 2500, wins = 1600,
		color = rgb(255, 205, 50),
		bank = rgb(130, 205, 90), wall = { rgb(200, 145, 40), rgb(250, 210, 85) }, water = rgb(255, 205, 80),
		props = { "tree", "rock", "rock", "bush" },
	},
}

local RiverLength = 3200

-- Worlds 2–5 reuse World 1's distances with their own names and biomes
-- (WorldContent/<World>.luau: { name, bank colour, material (unused), props });
-- the walls and water are derived from the bank colour, and Wins are scaled
-- by the world's rewardScale.
local white, black = Color3.new(1, 1, 1), Color3.new(0, 0, 0)
local function scaled(base: { Zone }, overrides: { any }, scale: number): { Zone }
	local result = {}
	for i, zone in base do
		local o: any = overrides[i]
		local bank: Color3 = o[2]
		result[i] = {
			index = zone.index,
			name = o[1],
			icon = o[5] or "✨",
			distance = zone.distance,
			wins = zone.wins * scale,
			color = bank:Lerp(white, 0.35),
			bank = bank,
			wall = { bank:Lerp(black, 0.35), bank:Lerp(white, 0.3) },
			water = bank:Lerp(rgb(60, 180, 230), 0.45),
			props = o[4],
		}
	end
	return result
end

local ByWorld: { [string]: { Zone } } = { Lily = Zones }
for _, content in WorldContent do
	ByWorld[content.world] = scaled(Zones, content.zones, Worlds.ById[content.world].rewardScale)
end

local function zoneForDistance(distance: number, worldId: string?): Zone
	local list = ByWorld[worldId or "Lily"] or Zones
	local reached = list[1]
	for _, zone in list do
		if distance >= zone.distance then
			reached = zone
		end
	end
	return reached
end

return {
	List = Zones,
	ByWorld = ByWorld,
	RiverLength = RiverLength,
	zoneForDistance = zoneForDistance,
}
