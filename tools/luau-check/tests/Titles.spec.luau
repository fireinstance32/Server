local Titles = require("@shared/Config/Titles")
local t = require("@test")

local function data(overrides)
	local d = {
		stats = { launches = 0, hatched = 0, timePlayed = 0, winsEarned = 0 },
		bestDistance = 0,
		frogs = { Basic = true },
		discovered = {},
		rebirths = 0,
		level = 1,
		titles = {},
	}
	for k, v in overrides do
		d[k] = v
	end
	return d
end

t.test("there are 27 titles with unique ids", function()
	t.equal(#Titles.List, 27)
	local seen = {}
	for _, title in Titles.List do
		t.equal(seen[title.id], nil)
		seen[title.id] = true
	end
end)

t.test("a new player has earned nothing", function()
	t.equal(#Titles.newlyEarned(data({})), 0)
end)

t.test("first throw earns Tadpole", function()
	local earned = Titles.newlyEarned(data({ stats = { launches = 1, hatched = 0, timePlayed = 0, winsEarned = 0 } }))
	t.equal(#earned, 1)
	t.equal(earned[1], "Tadpole")
end)

t.test("titles already owned are not earned again", function()
	local d = data({ stats = { launches = 1, hatched = 0, timePlayed = 0, winsEarned = 0 }, titles = { Tadpole = true } })
	t.equal(#Titles.newlyEarned(d), 0)
end)

t.test("progress is capped at the target", function()
	local current, target = Titles.progress(Titles.ById.Splasher, data({ bestDistance = 400 }))
	t.equal(current, 100)
	t.equal(target, 100)
end)

t.test("frog and pet counts read table sizes", function()
	t.equal(Titles.isUnlocked(Titles.ById.FrogFan, data({ frogs = { a = true, b = true, c = true } })), true)
	t.equal(Titles.isUnlocked(Titles.ById.PetPal, data({ discovered = { a = true } })), false)
end)

t.test("descriptions and bonus text", function()
	t.equal(Titles.describe(Titles.ById.RiverRunner), "Reach 1,000 studs")
	t.equal(Titles.describe(Titles.ById.Regular), "Play 30 minutes")
	t.equal(Titles.describe(Titles.ById.Tadpole), "Throw 1 time")
	t.equal(Titles.bonusText(Titles.ById.Reborn), "x1.1 Wins")
	t.equal(Titles.bonusText(Titles.ById.Trainee), "+2 Hops")
end)

t.test("every title uses a known rarity", function()
	local known = { Common = true, Uncommon = true, Rare = true, Epic = true, Legendary = true, Rainbow = true }
	for _, title in Titles.List do
		t.equal(known[title.rarity], true)
	end
end)
