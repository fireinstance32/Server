-- Color3/Vector3 don't exist offline; stub them so the config table loads.
Color3 = { fromRGB = function(r, g, b)
	return { r, g, b }
end }

local Ponds = require("@shared/Config/Ponds")
local t = require("@test")

local function owns(set)
	return function(pass)
		return set[pass] == true
	end
end

t.test("ponds are listed in index order with unique ids", function()
	local seen = {}
	for i, pond in Ponds.List do
		t.equal(pond.index, i)
		assert(not seen[pond.id], "duplicate id " .. pond.id)
		seen[pond.id] = true
		t.equal(Ponds.ById[pond.id], pond)
	end
end)

t.test("every pond has exactly one unlock rule", function()
	for _, pond in Ponds.List do
		assert((pond.rebirths ~= nil) ~= (pond.pass ~= nil), pond.id .. " needs rebirths OR pass")
	end
end)

t.test("starter pond is always unlocked", function()
	t.equal(Ponds.isUnlocked(Ponds.ById.Starter, 0, owns({})), true)
end)

t.test("rebirth ponds unlock at their rebirth count", function()
	local lotus = Ponds.ById.Lotus
	t.equal(Ponds.isUnlocked(lotus, lotus.rebirths - 1, owns({})), false)
	t.equal(Ponds.isUnlocked(lotus, lotus.rebirths, owns({})), true)
	t.equal(Ponds.lockReason(lotus, 0, owns({})), `Needs {lotus.rebirths} rebirths`)
end)

t.test("robux ponds need their pass, not rebirths", function()
	local golden = Ponds.ById.Golden
	t.equal(Ponds.isUnlocked(golden, 999, owns({})), false)
	t.equal(Ponds.isUnlocked(golden, 0, owns({ [golden.pass] = true })), true)
	t.equal(Ponds.lockReason(golden, 0, owns({})), "Robux pond")
end)

t.test("rebirth pond multipliers increase", function()
	local last = 0
	for _, pond in Ponds.List do
		if pond.rebirths then
			assert(pond.multiplier > last, pond.id .. " should beat the previous pond")
			last = pond.multiplier
		end
	end
end)
