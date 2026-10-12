-- Anti-abuse numbers: remote rate limits and data session locking.

local Security = {}

-- Requests per second (rate) and how many may arrive at once (burst), per
-- player per remote. Remotes not listed use Default.
Security.Default = { rate = 4, burst = 8 }
Security.RateLimits = {
	Hop = { rate = 4, burst = 6 }, -- auto-train asks every 0.6 s
	HatchEgg = { rate = 3, burst = 5 },
	DeletePets = { rate = 2, burst = 4 },
	RedeemCode = { rate = 0.2, burst = 3 },
	RequestGift = { rate = 0.5, burst = 3 },
	TravelWorld = { rate = 0.5, burst = 2 },
	ClaimDaily = { rate = 0.5, burst = 2 },
	ClaimGift = { rate = 1, burst = 3 },
}

-- A save written by another server counts as still in use for this long
-- (several autosaves), so a crashed server can't lock a player out for good.
Security.SessionLockSeconds = 300
-- How long a joining player waits for another server to let go of their data.
Security.SessionWaitAttempts = 5
Security.SessionWaitSeconds = 4

function Security.limitFor(remote: string)
	return Security.RateLimits[remote] or Security.Default
end

return Security
