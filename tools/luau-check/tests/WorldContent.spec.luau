-- Every world's frogs, eggs, pets and zones fit together.
local function color(r, g, b)
	return setmetatable({ r, g, b }, { __index = { Lerp = function(self)
		return self
	end } })
end
Color3 = { fromRGB = color, new = color }
Vector3 = { new = function(x, y, z)
	return { X = x, Y = y, Z = z }
end }
Enum = setmetatable({}, { __index = function(_, kind)
	return setmetatable({}, { __index = function(_, item)
		return `{kind}.{item}`
	end })
end })

local Worlds = require("@shared/Config/Worlds")
local Frogs = require("@shared/Config/Frogs")
local Pets = require("@shared/Config/Pets")
local Zones = require("@shared/Config/Zones")
local t = require("@test")

t.test("every world has frogs, two-plus eggs and 9 zones", function()
	for _, world in Worlds.List do
		assert(#Frogs.forWorld(world.id) >= 4, `{world.id} needs frogs`)
		assert(#Pets.eggsForWorld(world.id) >= 2, `{world.id} needs eggs`)
		t.equal(#Zones.ByWorld[world.id], 9)
	end
end)

t.test("ids are unique and egg pets exist", function()
	local frogIds, petIds, eggIds = {}, {}, {}
	for _, frog in Frogs.List do
		assert(not frogIds[frog.id], `duplicate frog {frog.id}`)
		frogIds[frog.id] = true
	end
	for _, pet in Pets.List do
		assert(not petIds[pet.id], `duplicate pet {pet.id}`)
		petIds[pet.id] = true
	end
	for _, egg in Pets.Eggs do
		assert(not eggIds[egg.id], `duplicate egg {egg.id}`)
		eggIds[egg.id] = true
		for _, entry in egg.pets do
			assert(Pets.ById[entry.pet], `{egg.id} egg has unknown pet {entry.pet}`)
		end
	end
end)

t.test("each world's frogs out-earn the previous world's best", function()
	local best = 0
	for _, world in Worlds.List do
		local frogs = Frogs.forWorld(world.id)
		local top = 0
		for _, frog in frogs do
			if not frog.robuxOnly and not frog.rewardOnly then
				assert(frog.perBounce > best, `{frog.id} is weaker than the last world`)
				top = math.max(top, frog.perBounce)
			end
		end
		best = top
	end
end)

t.test("zone Wins scale with the world", function()
	for _, world in Worlds.List do
		local top = Zones.ByWorld[world.id][9]
		t.equal(top.wins, Zones.List[9].wins * world.rewardScale)
	end
end)

t.test("every zone has a sign icon, its lane look and known props", function()
	-- Props/init.luau's MODELS (plus willow, which is part-built only).
	local kinds = {}
	for _, kind in { "tree", "palm", "willow", "rock", "reed", "flower", "mushroom", "cactus", "autumn", "pine", "ice", "lollipop", "candy", "crystal", "pumpkin", "bush", "voxel" } do
		kinds[kind] = true
	end
	for _, world in Worlds.List do
		for _, zone in Zones.ByWorld[world.id] do
			local where = `{world.id} {zone.name}`
			assert(type(zone.icon) == "string" and #zone.icon > 0, `{where} needs an icon`)
			assert(zone.bank and zone.water and zone.color, `{where} needs bank, water and sign colours`)
			t.equal(#zone.wall, 2)
			assert(#zone.props > 0, `{where} needs props`)
			for _, kind in zone.props do
				assert(kinds[kind], `{where} has unknown prop {kind}`)
			end
		end
	end
end)
