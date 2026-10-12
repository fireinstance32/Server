local SessionLock = require("@shared/Util/SessionLock")
local t = require("@test")

t.test("reads old bare profiles and new wrapped records", function()
	local old = { hops = 5 }
	local profile, session = SessionLock.unwrap(old)
	t.equal(profile, old)
	t.equal(session, nil)
	local record = SessionLock.wrap({ hops = 7 }, { job = "A", at = 10 })
	profile, session = SessionLock.unwrap(record)
	t.equal(profile.hops, 7)
	t.equal(session and session.job, "A")
	t.equal(SessionLock.unwrap(nil), nil)
end)

t.test("a fresh lock from another server blocks; a stale one doesn't", function()
	local lock = { job = "A", at = 100 }
	t.equal(SessionLock.heldByOther(lock, "B", 150, 300), true)
	t.equal(SessionLock.heldByOther(lock, "B", 500, 300), false)
	t.equal(SessionLock.heldByOther(lock, "A", 150, 300), false)
	t.equal(SessionLock.heldByOther(nil, "B", 150, 300), false)
end)

t.test("only the owner may save", function()
	t.equal(SessionLock.canSave({ job = "A", at = 0 }, "A"), true)
	t.equal(SessionLock.canSave({ job = "A", at = 0 }, "B"), false)
	t.equal(SessionLock.canSave(nil, "B"), true)
end)
