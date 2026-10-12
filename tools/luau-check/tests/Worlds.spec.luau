Color3 = { fromRGB = function(r, g, b)
	return { r, g, b }
end }

local Worlds = require("@shared/Config/Worlds")
local t = require("@test")

t.test("world 1 is free and the default", function()
	local first = Worlds.List[1]
	t.equal(first.id, Worlds.Default)
	t.equal(Worlds.isUnlocked(first, nil), true)
end)

t.test("later worlds need unlocking", function()
	local second = Worlds.List[2]
	t.equal(Worlds.isUnlocked(second, {}), false)
	t.equal(Worlds.isUnlocked(second, { [second.id] = true }), true)
end)

t.test("z bands map to the right world and never overlap", function()
	for _, world in Worlds.List do
		t.equal(Worlds.indexAtZ(world.offsetZ), world.index)
		t.equal(Worlds.indexAtZ(world.offsetZ + 300), world.index)
	end
	for i = 2, #Worlds.List do
		local gap = Worlds.List[i].offsetZ - Worlds.List[i - 1].offsetZ
		assert(gap > Worlds.BandHalfWidth * 2, "world bands overlap")
	end
	t.equal(Worlds.indexAtZ(-99999), nil)
end)

t.test("rewards grow with each world", function()
	for i = 2, #Worlds.List do
		assert(Worlds.List[i].rewardScale > Worlds.List[i - 1].rewardScale, "reward scale must grow")
		assert(Worlds.List[i].gateHops > Worlds.List[i - 1].gateHops, "gate must grow")
	end
end)
