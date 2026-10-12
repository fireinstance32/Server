local Format = require("@shared/Util/Format")
local t = require("@test")

t.test("clock shows hours only when needed", function()
	t.equal(Format.clock(76413), "21:13:33")
	t.equal(Format.clock(65), "01:05")
	t.equal(Format.clock(-3), "00:00")
end)

t.test("abbreviate", function()
	t.equal(Format.abbreviate(1234), "1.23K")
	t.equal(Format.abbreviate(999), "999")
end)
