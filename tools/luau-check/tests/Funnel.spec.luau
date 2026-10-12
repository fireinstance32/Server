local Funnel = require("@shared/Config/Funnel")
local t = require("@test")

local function player(overrides)
	local data = {
		hops = 0,
		rebirths = 0,
		frogs = { Baby = true },
		stats = { launches = 0, hatched = 0 },
		worldsUnlocked = { Lily = true },
	}
	for k, v in overrides do
		data[k] = v
	end
	return data
end

t.test("a new player only reaches Joined", function()
	local steps = Funnel.newSteps(player({}), 0)
	t.equal(#steps, 1)
	t.equal(steps[1], 1)
end)

t.test("steps are logged in order and only once", function()
	local data = player({ hops = 10, stats = { launches = 2, hatched = 1 } })
	local steps = Funnel.newSteps(data, 1)
	t.equal(#steps, 2) -- First Hops, First River Hop; stops at Bought a Frog
	t.equal(steps[2], 3)
	t.equal(#Funnel.newSteps(data, 3), 0)
end)
