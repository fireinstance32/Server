--!strict
-- Redeemable codes. Keys are upper-case; input is upper-cased before lookup.

export type Reward = { wins: number?, hops: number? }

local Codes: { [string]: Reward } = {
	WELCOME = { wins = 25 },
	STRONG = { hops = 100 },
	ROCKON = { wins = 100, hops = 250 },
}

return Codes
