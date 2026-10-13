-- "~ Boosts ~" (reference): the full-width Boost Bundle (Potion Pack) and
-- two single boosts. Contents and durations come from Config.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Monetization = require(Shared.Config.Monetization)
local Potions = require(Shared.Config.Potions)

local Purchases = require(script.Parent.Parent.Parent.Parent.Purchases)
local Cards = require(script.Parent.Cards)

local BoostSection = {}

local CREAM = Color3.fromRGB(255, 243, 180)
local LEFT = Enum.TextXAlignment.Left
local RIGHT = Enum.TextXAlignment.Right
local POTION_ICON = { Hops = "potion_hops", Wins = "potion_wins", Luck = "potion_luck" }

local SINGLES = {
	{ product = "HopsBoost", potion = "Hops", colors = "Rose" },
	{ product = "WinsBoost", potion = "Wins", colors = "Lemon" },
}

local function buyButtons(card: Frame, product: string, giftAt: Vector2, priceAt: Vector2, priceWidth: number, giftOver: GuiObject)
	Cards.gift(card, giftAt, Vector2.new(80, 72), product, giftOver)
	Cards.buy(card, priceAt, Vector2.new(priceWidth, 72), `{Cards.Robux}{Purchases.price("product", product)}`, function()
		Purchases.product(product)
	end)
end

local function bundle(list: ScrollingFrame, order: number, giftOver: GuiObject)
	local card = Cards.card(list, { name = "BoostBundle", size = Vector2.new(894, 267), order = order, colors = "Ocean", horizontal = true, edge = 8 })
	Cards.icon(card, "star", Vector2.new(110, 150), 150, -12, 3)
	Cards.icon(card, "star", Vector2.new(175, 110), 150, 8, 3)
	for i, line in { "Boost", "Bundle" } do
		Cards.text(card, { text = line, size = 66, at = Vector2.new(142, 73 + (i - 1) * 75), anchor = Vector2.new(0, 0.5), align = LEFT, color = CREAM, stroke = 5 })
	end
	local rewards = Monetization.Bundles.PotionPack.rewards
	for i, reward in rewards do
		local potion = Potions.ById[reward.id or ""]
		Cards.text(card, {
			text = `- {reward.amount} {potion and potion.name or reward.kind}s`,
			size = 34,
			at = Vector2.new(457, 70 + (i - 1) * 40 - (#rewards - 2) * 20),
			anchor = Vector2.new(0, 0.5),
			align = LEFT,
			stroke = 3,
		})
	end
	Cards.struck(card, Vector2.new(520, 208), Monetization.Bundles.PotionPack.was or 0)
	buyButtons(card, "PotionPack", Vector2.new(650, 168), Vector2.new(740, 168), 125, giftOver)
end

local function single(row: Frame, x: number, spec: any, giftOver: GuiObject)
	local potion = Potions.ById[spec.potion]
	local card = Cards.card(row, { name = spec.product, size = Vector2.new(440, 266), position = Vector2.new(x, 0), colors = spec.colors, horizontal = true, edge = 8 })
	Cards.icon(card, POTION_ICON[spec.potion], Vector2.new(117, 138), 175, 0, 3)
	Cards.text(card, { text = potion.name, size = 40, at = Vector2.new(415, 72), anchor = Vector2.new(1, 0.5), align = RIGHT, width = 400, color = CREAM, stroke = 4 })
	for i, line in { `{potion.factor}x {Potions.StatWord[potion.stat]}`, `for {math.floor(potion.duration / 60)} min` } do
		Cards.text(card, { text = line, size = 26, at = Vector2.new(217, 126 + (i - 1) * 25), anchor = Vector2.new(0, 0.5), align = LEFT, width = 220, stroke = 3 })
	end
	buyButtons(card, spec.product, Vector2.new(197, 168), Vector2.new(289, 168), 123, giftOver)
end

function BoostSection.build(list: ScrollingFrame, order: number, giftOver: GuiObject)
	Cards.header(list, "Boosts", order)
	bundle(list, order + 1, giftOver)
	local row = Cards.row(list, 266, order + 2)
	for i, spec in SINGLES do
		single(row, if i == 1 then 8 else 462, spec, giftOver)
	end
end

return BoostSection
