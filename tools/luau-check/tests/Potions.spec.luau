local Potions = require("@shared/Config/Potions")
local t = require("@test")

t.test("drinking with none active starts from now", function()
	t.equal(Potions.extend(nil, 1000, 600), 1600)
	t.equal(Potions.extend(500, 1000, 600), 1600) -- expired one doesn't count
end)

t.test("drinking while active stacks the time", function()
	t.equal(Potions.extend(1300, 1000, 600), 1900)
end)

t.test("remaining never goes negative", function()
	t.equal(Potions.remaining(1600, 1000), 600)
	t.equal(Potions.remaining(900, 1000), 0)
	t.equal(Potions.remaining(nil, 1000), 0)
end)

t.test("every potion boosts a known stat", function()
	for _, potion in Potions.List do
		assert(potion.stat == "hops" or potion.stat == "wins" or potion.stat == "luck", potion.id)
		assert(potion.factor > 1 and potion.duration > 0, potion.id)
	end
end)
