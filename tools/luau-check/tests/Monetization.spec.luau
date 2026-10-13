local Monetization = require("@shared/Config/Monetization")
local t = require("@test")

local function owning(list: { string }): (string) -> boolean
	local set = {}
	for _, pass in list do
		set[pass] = true
	end
	return function(pass)
		return set[pass] == true
	end
end

t.test("strength tiers are 2x 4x 8x 16x for 5 19 49 129", function()
	local factors, prices = {}, {}
	for _, tier in Monetization.StrengthTiers do
		table.insert(factors, tier.factor)
		table.insert(prices, Monetization.Passes[tier.pass].price)
	end
	t.equal(table.concat(factors, " "), "2 4 8 16")
	t.equal(table.concat(prices, " "), "5 19 49 129")
end)

t.test("best strength tier owned counts and the next one is offered", function()
	local best, nextTier = Monetization.strengthTier(owning({}))
	t.equal(best, nil)
	t.equal(nextTier and nextTier.pass, "DoubleHops")
	best, nextTier = Monetization.strengthTier(owning({ "DoubleHops", "StrengthX4" }))
	t.equal(best, 4)
	t.equal(nextTier and nextTier.pass, "StrengthX8")
	-- Bought out of order: the highest still counts, the offer is above it.
	best, nextTier = Monetization.strengthTier(owning({ "StrengthX8" }))
	t.equal(best, 8)
	t.equal(nextTier and nextTier.pass, "StrengthX16")
	best, nextTier = Monetization.strengthTier(owning({ "StrengthX16" }))
	t.equal(best, 16)
	t.equal(nextTier, nil)
end)
