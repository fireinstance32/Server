--!strict
-- Game passes and developer products. `id = 0` means "not created yet": the
-- game runs fine, buttons show "Not on sale yet". Create the item on the
-- Roblox Creator Dashboard, then paste its id here. `price` is only what the
-- UI displays (keep it in sync with the dashboard).

export type Item = { id: number, price: number, label: string }

local Passes: { [string]: Item } = {
	AutoHop = { id = 0, price = 23, label = "Auto Hop" },
	AutoRebirth = { id = 0, price = 99, label = "Auto Rebirth" },
	DoubleHops = { id = 0, price = 5, label = "+2x Hops" },
	DoubleWins = { id = 0, price = 54, label = "2x Wins" },
	ExtraPetSlots = { id = 0, price = 149, label = "+2 Pet Slots" },
	HatchTriple = { id = 0, price = 149, label = "+3 Eggs (hatch 3 at once)" },
	HatchOcto = { id = 0, price = 399, label = "+8 Eggs (hatch 8 at once)" },
	PetStorage = { id = 0, price = 99, label = "+100 Pet Storage" },
	OfflineDouble = { id = 0, price = 79, label = "Offline Rewards x2" },
	-- Robux training ponds (Config/Ponds), valid in all worlds.
	PondGolden = { id = 0, price = 90, label = "Golden Pond (3x)" },
	PondRainbow = { id = 0, price = 225, label = "Rainbow Pond (15x)" },
	PondCosmic = { id = 0, price = 540, label = "Cosmic Pond (50x)" },
}

local Products: { [string]: Item } = {
	StarterPack = { id = 0, price = 36, label = "Starter Pack" },
	HopsPack1 = { id = 0, price = 10, label = "+10K Hops" },
	HopsPack2 = { id = 0, price = 41, label = "+100K Hops" },
	HopsPack3 = { id = 0, price = 86, label = "+1M Hops" },
	SkipRebirth = { id = 0, price = 25, label = "Skip Rebirth" },
	PhoenixFrog = { id = 0, price = 199, label = "Phoenix Frog" },
	RainbowEgg = { id = 0, price = 41, label = "Rainbow Egg" },
	RainbowTrail = { id = 0, price = 99, label = "Rainbow Trail" },
	PotionPack = { id = 0, price = 49, label = "Potion Pack (3 of each)" },
	VoidTrail = { id = 0, price = 149, label = "Void Trail" },
}

-- What each Hops pack gives (shown on the buttons too).
local HopsPacks = {
	HopsPack1 = 10_000,
	HopsPack2 = 100_000,
	HopsPack3 = 1_000_000,
}

-- Contents of the Starter Pack (shown in the Shop).
local StarterPack = {
	originalPrice = 199,
	hops = 10_000,
	wins = 500,
	rebirths = 1,
}

-- Potion Pack: this many of every potion.
local PotionPackEach = 3

-- Limited stock across all servers (shown as "STOCK n / limit").
local Limited: { [string]: number } = {
	PhoenixFrog = 1000,
}

-- "[GIFT]" developer products: one per giftable item (a pass or product
-- name above). 0 = not created yet. Price shown = the item's price.
local GiftIds: { [string]: number } = {
	DoubleHops = 0,
	DoubleWins = 0,
	AutoHop = 0,
	HatchTriple = 0,
	HatchOcto = 0,
	ExtraPetSlots = 0,
	PetStorage = 0,
	OfflineDouble = 0,
	HopsPack1 = 0,
	HopsPack2 = 0,
	HopsPack3 = 0,
	RainbowEgg = 0,
	PotionPack = 0,
}

return {
	Passes = Passes,
	Products = Products,
	HopsPacks = HopsPacks,
	StarterPack = StarterPack,
	PotionPackEach = PotionPackEach,
	Limited = Limited,
	GiftIds = GiftIds,
}
