local Hatch = require("@shared/Util/Hatch")
local t = require("@test")

local entries = {
	{ pet = "A", weight = 40 },
	{ pet = "B", weight = 30 },
	{ pet = "C", weight = 20 },
	{ pet = "D", weight = 10 },
}
local function noneLucky()
	return false
end
local function rareLucky(id)
	return id == "C" or id == "D"
end

t.test("chances add up to 100", function()
	local chances = Hatch.chances(entries, Hatch.weights(entries, 1, noneLucky))
	local sum = 0
	for _, c in chances do
		sum += c
	end
	t.near(sum, 100, 1e-6)
	t.near(chances.A, 40, 1e-6)
end)

t.test("luck only boosts lucky pets", function()
	local w = Hatch.weights(entries, 2, rareLucky)
	t.equal(w[1], 40)
	t.equal(w[3], 40)
	t.equal(w[4], 20)
end)

t.test("luck below 1 never lowers odds", function()
	local w = Hatch.weights(entries, 0.5, rareLucky)
	t.equal(w[4], 10)
end)

t.test("pick follows the weight bands", function()
	local w = Hatch.weights(entries, 1, noneLucky)
	t.equal(Hatch.pick(entries, w, 0), "A")
	t.equal(Hatch.pick(entries, w, 0.39), "A")
	t.equal(Hatch.pick(entries, w, 0.41), "B")
	t.equal(Hatch.pick(entries, w, 0.95), "D")
	t.equal(Hatch.pick(entries, w, 1), "D")
end)

t.test("percent text formatting", function()
	t.equal(Hatch.percentText(40), "40%")
	t.equal(Hatch.percentText(2.5), "2.5%")
	t.equal(Hatch.percentText(0.1), "0.1%")
end)
