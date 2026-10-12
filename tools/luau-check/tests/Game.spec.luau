-- Vector3 doesn't exist offline; a tiny stub lets the config load.
Vector3 = { new = function(x, y, z)
	return { X = x, Y = y, Z = z }
end }

local Game = require("@shared/Config/Game")
local t = require("@test")

t.test("hop zone centre is inside, far away is outside", function()
	t.equal(Game.inHopZone(Game.HopZoneCenterX, Game.HopZoneCenterZ), true)
	t.equal(Game.inHopZone(Game.HopZoneCenterX + 500, Game.HopZoneCenterZ), false)
end)

t.test("hop zone edges are inclusive", function()
	local x = Game.HopZoneCenterX + Game.HopZoneSizeX / 2
	local z = Game.HopZoneCenterZ - Game.HopZoneSizeZ / 2
	t.equal(Game.inHopZone(x, z), true)
	t.equal(Game.inHopZone(x + 0.01, z), false)
	t.equal(Game.inHopZone(x, z - 0.01), false)
end)

t.test("hop zone sits before the river (river starts at x = 0)", function()
	assert(Game.HopZoneCenterX + Game.HopZoneSizeX / 2 <= 0, "zone must not overlap the river")
end)

t.test("flight time includes the toss wind-up and caps visual hops", function()
	local one = Game.flightTime(1)
	t.near(one, Game.TossWindup + Game.SecondsPerVisualHop + Game.LandingPause)
	t.near(Game.flightTime(10_000), Game.flightTime(Game.MaxVisualHops))
end)

t.test("distance grows with hops", function()
	assert(Game.distanceForHops(1000) > Game.distanceForHops(10), "more hops should go farther")
	t.equal(Game.distanceForHops(0), Game.DistanceBase)
end)
