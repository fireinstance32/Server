--!strict
-- Redeemable codes. Keys are upper-case; input is upper-cased before lookup.

-- rock: a Config/Frogs id (a reward-only rock) granted with the code.
export type Reward = { wins: number?, hops: number?, rock: string? }

local Codes: { [string]: Reward } = {
	WELCOME = { wins = 25 },
	STRONG = { hops = 100 },
	ROCKON = { wins = 100, hops = 250 },
	MOSSY = { rock = "Mossy" },
	SLIME = { rock = "Toxic" },
	ROYAL = { rock = "RoyalGem" },
}

return Codes
