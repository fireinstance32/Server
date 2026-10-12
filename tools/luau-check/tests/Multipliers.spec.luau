local Multipliers = require("@shared/Util/Multipliers")
local t = require("@test")

local function part(kind, value)
	return { id = kind .. tostring(value), label = "", kind = kind, value = value }
end

t.test("no parts is x1", function()
	t.equal(Multipliers.combine({}), 1)
end)

t.test("adds are summed before mults", function()
	-- (1 + 0.5 + 0.25) * 2 * 3 = 10.5
	local total = Multipliers.combine({ part("add", 0.5), part("mult", 2), part("add", 0.25), part("mult", 3) })
	t.near(total, 10.5)
end)

t.test("order does not matter", function()
	local a = Multipliers.combine({ part("mult", 2), part("add", 1) })
	local b = Multipliers.combine({ part("add", 1), part("mult", 2) })
	t.near(a, b)
end)

t.test("breakdown drops neutral parts but keeps the total", function()
	local result = Multipliers.breakdown({ part("mult", 1), part("add", 0), part("mult", 2) })
	t.equal(#result.parts, 1)
	t.near(result.total, 2)
end)

t.test("negative adds never push the total below zero", function()
	t.equal(Multipliers.combine({ part("add", -5), part("mult", 3) }), 0)
end)
