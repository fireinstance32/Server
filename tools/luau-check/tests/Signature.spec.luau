local Signature = require("@shared/Util/Signature")
local t = require("@test")

t.test("key order doesn't change the signature", function()
	t.equal(Signature.of({ a = 1, b = 2 }), Signature.of({ b = 2, a = 1 }))
end)

t.test("different values give different signatures", function()
	t.equal(Signature.of({ a = 1 }) == Signature.of({ a = 2 }), false)
	t.equal(Signature.of("1") == Signature.of(1), false)
	t.equal(Signature.of(nil, 1) == Signature.of(1, nil), false)
end)

t.test("guard only renders when the key changes", function()
	local renders = 0
	local render = Signature.guard(function(d)
		return Signature.of(d.x)
	end, function()
		renders += 1
	end)
	render({ x = 1, noise = 1 })
	render({ x = 1, noise = 2 })
	t.equal(renders, 1)
	render({ x = 2, noise = 2 })
	t.equal(renders, 2)
end)
