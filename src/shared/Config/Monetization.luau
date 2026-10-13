--!strict
-- Game passes and developer products. `id = 0` means "not created yet": the
-- game runs fine, buttons show "Not on sale yet". Create the item on the
-- Roblox Creator Dashboard, then paste its id here. `price` is only what the
-- UI displays (keep it in sync with the dashboard).

export type Item = { id: number, price: number, label: string }

local Passes: { [string]: Item } = {
	AutoHop = { id = 0, price = 23, label = "Auto Lift" },
	AutoRebirth = { id = 0, price = 99, label = "Auto Rebirth" },
	DoubleHops = { id = 0, price = 5, label = "+2x Strength" },
	DoubleWins = { id = 0, price = 54, label = "2x Wins" },
	ExtraPetSlots = { id = 0, price = 149, label = "+2 Pet Slots" },
	HatchTriple = { id = 0, price = 149, label = "+3 Eggs (hatch 3 at once)" },
	HatchOcto = { id = 0, price = 399, label = "+8 Eggs (hatch 8 at once)" },
	PetStorage = { id = 0, price = 99, label = "+100 Pet Storage" },
	OfflineDouble = { id = 0, price = 79, label = "Offline Rewards x2" },
	-- Robux training ponds (Config/Ponds), valid in all worlds.
	PondGolden = { id = 0, price = 90, label = "Golden Gym (3x)" },
	PondRainbow = { id = 0, price = 225, label = "Rainbow Gym (15x)" },
	PondCosmic = { id = 0, price = 540, label = "Cosmic Gym (50x)" },
}

local Products: { [string]: Item } = {
	StarterPack = { id = 0, price = 36, label = "Starter Pack" },
	HopsPack1 = { id = 0, price = 10, label = "+10K Strength" },
	HopsPack2 = { id = 0, price = 41, label = "+100K Strength" },
	HopsPack3 = { id = 0, price = 86, label = "+1M Strength" },
	SkipRebirth = { id = 0, price = 25, label = "Skip Rebirth" },
	PhoenixFrog = { id = 0, price = 199, label = "Phoenix Stone" },
	RainbowEgg = { id = 0, price = 41, label = "Rainbow Egg" },
	RainbowTrail = { id = 0, price = 99, label = "Rainbow Trail" },
	PotionPack = { id = 0, price = 49, label = "Boost Bundle (3 of each potion)" },
	VoidTrail = { id = 0, price = 149, label = "Void Trail" },
	-- Shop (reference shop video): second pack, egg bundles, single boosts, Wins packs.
	GalaxyPack = { id = 0, price = 270, label = "Galaxy Pack" },
	RainbowEgg3 = { id = 0, price = 107, label = "3 Rainbow Eggs" },
	RainbowEgg8 = { id = 0, price = 269, label = "8 Rainbow Eggs" },
	HopsBoost = { id = 0, price = 27, label = "Strength Boost" },
	WinsBoost = { id = 0, price = 27, label = "Wins Boost" },
	WinsPack1 = { id = 0, price = 23, label = "Tiny Pack" },
	WinsPack2 = { id = 0, price = 54, label = "Small Pack" },
	WinsPack3 = { id = 0, price = 104, label = "Medium Pack" },
	WinsPack4 = { id = 0, price = 207, label = "Large Pack" },
	WinsPackMega = { id = 0, price = 414, label = "Mega Pack (first time)" },
	WinsPackMega2 = { id = 0, price = 518, label = "Mega Pack" },
}

-- What each Hops pack gives (shown on the buttons too).
local HopsPacks = {
	HopsPack1 = 10_000,
	HopsPack2 = 100_000,
	HopsPack3 = 1_000_000,
}

-- Bundles: what each of these products gives (Rewards.grant entries, in the
-- order the Shop shows them). `was` = struck-out price in the Shop;
-- `oneTime` = can only be bought once (data.oneTime).
export type Bundle = { rewards: { { kind: string, id: string?, amount: number } }, was: number?, oneTime: boolean? }

local Bundles: { [string]: Bundle } = {
	StarterPack = {
		was = 199,
		oneTime = true,
		rewards = {
			{ kind = "hops", amount = 10_000 },
			{ kind = "wins", amount = 500 },
			{ kind = "potion", id = "Hops", amount = 1 },
			{ kind = "rebirths", amount = 1 },
		},
	},
	GalaxyPack = {
		was = 799,
		rewards = {
			{ kind = "pet", id = "GalaxyCat", amount = 1 },
			{ kind = "potion", id = "Hops", amount = 3 },
			{ kind = "potion", id = "Wins", amount = 3 },
			{ kind = "potion", id = "Luck", amount = 3 },
			{ kind = "hops", amount = 1_000_000 },
			{ kind = "rebirths", amount = 10 },
		},
	},
	PotionPack = { -- "Boost Bundle"
		was = 243, -- 9 single boosts
		rewards = {
			{ kind = "potion", id = "Hops", amount = 3 },
			{ kind = "potion", id = "Wins", amount = 3 },
			{ kind = "potion", id = "Luck", amount = 3 },
		},
	},
	HopsBoost = { rewards = { { kind = "potion", id = "Hops", amount = 1 } } },
	WinsBoost = { rewards = { { kind = "potion", id = "Wins", amount = 1 } } },
	WinsPack1 = { rewards = { { kind = "wins", amount = 10_000 } } },
	WinsPack2 = { rewards = { { kind = "wins", amount = 50_000 } } },
	WinsPack3 = { rewards = { { kind = "wins", amount = 200_000 } } },
	WinsPack4 = { rewards = { { kind = "wins", amount = 500_000 } } },
	WinsPackMega = { was = 518, oneTime = true, rewards = { { kind = "wins", amount = 1_000_000 } } },
	WinsPackMega2 = { rewards = { { kind = "wins", amount = 1_000_000 } } },
}

-- Several hatches of a Robux egg in one product (Shop "Buy 3 / Buy 8").
local EggBundles: { [string]: { egg: string, count: number } } = {
	RainbowEgg3 = { egg = "Rainbow", count = 3 },
	RainbowEgg8 = { egg = "Rainbow", count = 8 },
}

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
	RainbowEgg3 = 0,
	RainbowEgg8 = 0,
	PotionPack = 0,
	GalaxyPack = 0,
	HopsBoost = 0,
	WinsBoost = 0,
	AutoRebirth = 0,
	PondGolden = 0,
	PondRainbow = 0,
	PondCosmic = 0,
}

return {
	Passes = Passes,
	Products = Products,
	HopsPacks = HopsPacks,
	Bundles = Bundles,
	EggBundles = EggBundles,
	Limited = Limited,
	GiftIds = GiftIds,
}
