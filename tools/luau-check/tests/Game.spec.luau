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

t.test("metres are whole numbers and never negative", function()
	t.equal(Game.metersFor(0), 0)
	t.equal(Game.metersFor(-50), 0)
	t.equal(Game.metersFor(101), math.floor(101 * Game.MetersPerStud))
end)

t.test("offline hops: short breaks give nothing, long ones are capped", function()
	t.equal(Game.offlineHops(Game.OfflineMinSeconds - 1, 1, 1, false), 0)
	local cap = Game.offlineHops(Game.OfflineMaxHours * 3600, 1, 1, false)
	t.equal(Game.offlineHops(Game.OfflineMaxHours * 3600 * 10, 1, 1, false), cap)
end)

t.test("offline hops scale with frog, multiplier and the x2 pass", function()
	local base = Game.offlineHops(3600, 2, 3, false)
	t.equal(base, math.floor(3600 * Game.OfflinePadsPerSecond * 6))
	t.equal(Game.offlineHops(3600, 2, 3, true), base * 2)
end)
