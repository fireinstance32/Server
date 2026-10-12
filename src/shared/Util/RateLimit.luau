--!strict
-- Token bucket: `burst` requests at once, refilling at `rate` per second.
-- Pure (time is passed in) so it is unit-tested.

export type Bucket = { tokens: number, at: number }

local RateLimit = {}

function RateLimit.new(burst: number, now: number): Bucket
	return { tokens = burst, at = now }
end

-- Spends one token if available. Returns whether the request may go ahead.
function RateLimit.take(bucket: Bucket, rate: number, burst: number, now: number): boolean
	bucket.tokens = math.min(burst, bucket.tokens + (now - bucket.at) * rate)
	bucket.at = now
	if bucket.tokens >= 1 then
		bucket.tokens -= 1
		return true
	end
	return false
end

return RateLimit
