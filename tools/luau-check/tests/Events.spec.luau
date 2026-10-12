Color3 = { fromRGB = function(r, g, b)
	return { r, g, b }
end }
Vector3 = { new = function(x, y, z)
	return { X = x, Y = y, Z = z }
end }

local Events = require("@shared/Config/Events")
local t = require("@test")

local halloween = Events.List[1]

t.test("active only between start and end", function()
	t.equal(Events.active(halloween.startsAt - 1), nil)
	t.equal(Events.active(halloween.startsAt), halloween)
	t.equal(Events.active(halloween.endsAt), nil)
end)

t.test("Studio override forces an event on or off", function()
	t.equal(Events.active(0, halloween.id), halloween)
	t.equal(Events.active(halloween.startsAt, "none"), nil)
end)

t.test("time left text", function()
	t.equal(Events.timeLeftText(halloween, halloween.endsAt - (3 * 86400 + 4 * 3600)), "3d 4h")
	t.equal(Events.timeLeftText(halloween, halloween.endsAt - 300), "5m")
end)

t.test("event egg pets exist in the event", function()
	for _, event in Events.List do
		local ids = {}
		for _, p in event.pets do
			ids[p.id] = true
		end
		for _, entry in event.egg.pets do
			assert(ids[entry.pet], `{entry.pet} missing`)
		end
	end
end)
