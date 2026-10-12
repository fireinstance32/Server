--!strict
-- Game pass and developer product IDs. 0 means "not created yet"; services skip
-- unconfigured IDs, so the game runs in Studio before anything is published.

return {
	Passes = {
		DoubleWins = 0,
		DoubleHops = 0,
		AutoHop = 0,
		ExtraPetSlots = 0,
	},
	Products = {
		PhoenixFrog = 0,
		WinsSmall = 0,
		HopsSmall = 0,
	},
}
