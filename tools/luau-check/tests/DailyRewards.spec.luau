local Daily = require("@shared/Config/DailyRewards")
local t = require("@test")

t.test("first ever claim is day 1", function()
	local can, day = Daily.status(0, 0, 20000)
	t.equal(can, true)
	t.equal(day, 1)
end)

t.test("claiming the next day continues the streak", function()
	local can, day = Daily.status(19999, 3, 20000)
	t.equal(can, true)
	t.equal(day, 4)
end)

t.test("can't claim twice in one day", function()
	local can, day = Daily.status(20000, 4, 20000)
	t.equal(can, false)
	t.equal(day, 4)
end)

t.test("missing a day restarts at day 1", function()
	local _, day = Daily.status(19990, 5, 20000)
	t.equal(day, 1)
end)

t.test("after day 7 it wraps to day 1", function()
	local _, day = Daily.status(19999, 7, 20000)
	t.equal(day, 1)
end)

t.test("day number is UTC days", function()
	t.equal(Daily.dayNumber(86400 * 3 + 5), 3)
end)
