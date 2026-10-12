local Gifts = require("@shared/Config/Gifts")
local t = require("@test")

t.test("gift is ready only after its minutes", function()
	local first = Gifts.List[1]
	t.equal(Gifts.isReady(1, first.minutes * 60 - 1), false)
	t.equal(Gifts.isReady(1, first.minutes * 60), true)
	t.equal(Gifts.isReady(999, 1e9), false)
end)

t.test("next gift countdown skips claimed ones", function()
	t.equal(Gifts.nextIn(0, {}), Gifts.List[1].minutes * 60)
	t.equal(Gifts.nextIn(0, { [1] = true }), Gifts.List[2].minutes * 60)
	t.equal(Gifts.nextIn(Gifts.List[1].minutes * 60, {}), 0)
end)

t.test("all claimed means no next gift", function()
	local all = {}
	for i in Gifts.List do
		all[i] = true
	end
	t.equal(Gifts.nextIn(0, all), nil)
end)

t.test("claimed list round-trips through the attribute string", function()
	local claimed = Gifts.parseClaimed("1,3,10")
	t.equal(claimed[1], true)
	t.equal(claimed[3], true)
	t.equal(claimed[10], true)
	t.equal(claimed[2], nil)
end)
