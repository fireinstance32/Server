--!strict
-- River zones for World 1. A hop that lands at or past a zone's distance earns
-- that zone's Wins. Distances are studs from the river origin.

export type Zone = {
	index: number,
	name: string,
	distance: number,
	wins: number,
	color: Color3,
}

local Zones: { Zone } = {
	{ index = 1, name = "Lily Shallows", distance = 0, wins = 1, color = Color3.fromRGB(120, 220, 120) },
	{ index = 2, name = "Reed Bend", distance = 100, wins = 3, color = Color3.fromRGB(150, 210, 90) },
	{ index = 3, name = "Mossy Rocks", distance = 250, wins = 8, color = Color3.fromRGB(110, 180, 110) },
	{ index = 4, name = "Willow Run", distance = 450, wins = 20, color = Color3.fromRGB(90, 200, 170) },
	{ index = 5, name = "Firefly Glade", distance = 700, wins = 50, color = Color3.fromRGB(240, 220, 90) },
	{ index = 6, name = "Waterfall Steps", distance = 1000, wins = 120, color = Color3.fromRGB(90, 170, 240) },
	{ index = 7, name = "Misty Marsh", distance = 1400, wins = 300, color = Color3.fromRGB(170, 170, 220) },
	{ index = 8, name = "Sunset Lagoon", distance = 1900, wins = 700, color = Color3.fromRGB(255, 150, 90) },
	{ index = 9, name = "King's Pond", distance = 2500, wins = 1600, color = Color3.fromRGB(255, 200, 40) },
}

local RiverLength = 3200

local function zoneForDistance(distance: number): Zone
	local reached = Zones[1]
	for _, zone in Zones do
		if distance >= zone.distance then
			reached = zone
		end
	end
	return reached
end

return {
	List = Zones,
	RiverLength = RiverLength,
	zoneForDistance = zoneForDistance,
}
