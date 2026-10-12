local RateLimit = require("@shared/Util/RateLimit")
local t = require("@test")

t.test("allows a burst, then blocks", function()
	local bucket = RateLimit.new(3, 0)
	for _ = 1, 3 do
		t.equal(RateLimit.take(bucket, 1, 3, 0), true)
	end
	t.equal(RateLimit.take(bucket, 1, 3, 0), false)
end)

t.test("refills at the rate and never above the burst", function()
	local bucket = RateLimit.new(2, 0)
	RateLimit.take(bucket, 2, 2, 0)
	RateLimit.take(bucket, 2, 2, 0)
	t.equal(RateLimit.take(bucket, 2, 2, 0.25), false)
	t.equal(RateLimit.take(bucket, 2, 2, 0.5), true)
	RateLimit.take(bucket, 2, 2, 100)
	t.near(bucket.tokens, 1, 1e-9)
end)
