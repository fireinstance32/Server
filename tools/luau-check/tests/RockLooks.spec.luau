-- Every rock has a Blender shape that build_rocks.py actually makes.
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

local Frogs = require("@shared/Config/Frogs")
local RockLooks = require("@shared/Config/RockLooks")
local t = require("@test")

local known = {}
for _, shape in RockLooks.Shapes do
	known[shape] = true
end

t.test("every rock uses a known shape", function()
	for _, rock in Frogs.List do
		local shape = RockLooks.shapeFor(rock.id)
		assert(known[shape], `{rock.id} uses unknown shape {shape}`)
		assert(RockLooks.ByRock[rock.id], `{rock.id} has no shape picked`)
	end
end)

t.test("only real rocks are listed", function()
	for id in RockLooks.ByRock do
		assert(Frogs.ById[id], `RockLooks lists unknown rock {id}`)
	end
	for id in RockLooks.Crowned do
		assert(Frogs.ById[id], `RockLooks crowns unknown rock {id}`)
	end
end)

t.test("unknown rocks fall back to the plain rock", function()
	t.equal(RockLooks.shapeFor(nil), "Rock")
	t.equal(RockLooks.shapeFor("Nope"), "Rock")
end)

local Codes = require("@shared/Config/Codes")
local DailyRewards = require("@shared/Config/DailyRewards")
local Gifts = require("@shared/Config/Gifts")

local function earnedRock(id: string, from: string)
	local rock = Frogs.ById[id]
	assert(rock, `{from} gives unknown rock {id}`)
	assert(rock.rewardOnly or rock.robuxOnly, `{from} gives {id}, which is also sold`)
end

t.test("rock rewards point at earn-only rocks", function()
	for code, reward in Codes do
		if reward.rock then
			earnedRock(reward.rock, `code {code}`)
		end
	end
	for day, reward in DailyRewards.Days do
		if reward.kind == "frog" then
			earnedRock(reward.id, `daily day {day}`)
		end
	end
	for i, gift in Gifts.List do
		if gift.reward.kind == "frog" then
			earnedRock(gift.reward.id :: string, `gift {i}`)
		end
	end
end)

t.test("podium-less rocks are earned and stay off the podiums", function()
	for _, rock in Frogs.List do
		if rock.noPodium then
			assert(rock.rewardOnly, `{rock.id} has no podium and no way to get it`)
			for _, onPodium in Frogs.forWorld(rock.world or "Lily") do
				assert(onPodium.id ~= rock.id, `{rock.id} is on a podium`)
			end
		end
	end
end)
