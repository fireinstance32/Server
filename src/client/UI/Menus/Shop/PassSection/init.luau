-- "~ Gamepasses ~" laid out like the reference shop: a row of three narrow
-- cards, half-width pairs, and one full-width card. Prices, gifting and
-- OWNED come from Config/Monetization and Purchases; text/icons are here.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Monetization = require(Shared.Config.Monetization)
local Ponds = require(Shared.Config.Ponds)

local Purchases = require(script.Parent.Parent.Parent.Parent.Purchases)
local Cards = require(script.Parent.Cards)
local Tall = require(script.Tall)
local Wide = require(script.Wide)

local PassSection = {}

local TALL: { Tall.Spec } = {
	{ pass = "ExtraPetSlots", title = "+2 Pet Slots", icon = "pet", tag = "+2", colors = "Blue" },
	{ pass = "HatchTriple", title = "Hatch x3", icon = "egg", tag = "x3", colors = "Purple" },
	{ pass = "HatchOcto", title = "Hatch x8", icon = "egg_golden", tag = "x8", colors = "Red" },
}

local function pondCaption(pass: string): string
	for _, pond in Ponds.ById do
		if pond.pass == pass then
			return `{pond.multiplier}x STRENGTH`
		end
	end
	return ""
end

-- Rows top to bottom: a pair = half-width cards, a single = full width.
local ROWS: { { Wide.Spec } } = {
	{
		{ pass = "AutoHop", caption = "AFK LIFTING", title = "Auto\nLift", icon = "auto", colors = "Orange" },
		{ pass = "AutoRebirth", caption = "AFK REBIRTHS", title = "Auto\nRebirth", icon = "rebirth", colors = "Cyan" },
	},
	{
		{ pass = "PondCosmic", caption = pondCaption("PondCosmic"), title = "Cosmic Gym", icon = "portal", colors = "Green", ink = Color3.fromRGB(96, 240, 88) },
	},
	{
		{ pass = "PondGolden", caption = pondCaption("PondGolden"), title = "Golden\nGym", icon = "globe", colors = "Pink" },
		{ pass = "PondRainbow", caption = pondCaption("PondRainbow"), title = "Rainbow\nGym", icon = "portal", colors = "Gold", ink = Color3.fromRGB(255, 226, 70) },
	},
	{
		{ pass = "DoubleHops", caption = "2X STRENGTH", title = "Double\nStrength", icon = "bolt", colors = "Blue" },
		{ pass = "DoubleWins", caption = "2X WINS", title = "Double\nWins", icon = "trophy", colors = "Purple" },
	},
	{
		{ pass = "PetStorage", caption = "+100 STORAGE", title = "Pet\nStorage", icon = "inventory", colors = "Red" },
		{ pass = "OfflineDouble", caption = "OFFLINE 2X", title = "Offline\nBoost", icon = "daily", colors = "Cyan" },
	},
}

function PassSection.build(list: ScrollingFrame, order: number, giftOver: GuiObject)
	Cards.header(list, "Gamepasses", order)
	local buttons: { [string]: TextButton } = {}
	local tall = Cards.row(list, 324, order + 1)
	for i, spec in TALL do
		buttons[spec.pass] = Tall(tall, ({ 10, 312, 614 })[i], spec, giftOver)
	end
	for i, row in ROWS do
		if #row == 1 then
			buttons[row[1].pass] = Wide.full(list, order + 1 + i, row[1], giftOver)
		else
			local holder = Cards.row(list, 328, order + 1 + i)
			for j, spec in row do
				buttons[spec.pass] = Wide.half(holder, if j == 1 then 8 else 462, spec, giftOver)
			end
		end
	end

	return function()
		for name, button in buttons do
			local owned = Purchases.owns(name)
			Cards.setPrice(button, if owned then "OWNED" else `{Cards.Robux}{Monetization.Passes[name].price}`, owned)
		end
	end
end

return PassSection
