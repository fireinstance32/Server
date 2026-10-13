-- "~ Limited Offer ~" (reference "Admin Egg" card): the Robux Rainbow Egg
-- with its pets and odds, and Buy 8 / Buy 3 / Buy 1, each giftable.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Pets = require(ReplicatedStorage:WaitForChild("Shared").Config.Pets)

local PetImage = require(script.Parent.Parent.Parent.Components.PetImage)
local Purchases = require(script.Parent.Parent.Parent.Parent.Purchases)
local Cards = require(script.Parent.Cards)

local LimitedSection = {}

local EGG = "Rainbow"
-- Product, label and the gift / price buttons' left edges (outer px).
local OFFERS = {
	{ product = "RainbowEgg8", label = "Buy 8", gift = 157, price = 247 },
	{ product = "RainbowEgg3", label = "Buy 3", gift = 392, price = 485 },
	{ product = "RainbowEgg", label = "Buy 1", gift = 632, price = 723 },
}

local function percent(chance: number): string
	local value = chance * 100
	return if value >= 1 then `{math.floor(value + 0.5)}%` else `{string.format("%.1f", value)}%`
end

function LimitedSection.build(list: ScrollingFrame, order: number, giftOver: GuiObject)
	Cards.header(list, "Limited Offer", order)
	local egg = Pets.EggsById[EGG]
	local card = Cards.card(list, { name = "LimitedEgg", size = Vector2.new(894, 396), order = order + 1, colors = "Lime", edge = 8 })

	Cards.icon(card, "egg_rainbow", Vector2.new(182, 232), 250, -6)
	Cards.text(card, {
		text = egg.name,
		size = 56,
		at = Vector2.new(32, 62),
		anchor = Vector2.new(0, 0.5),
		align = Enum.TextXAlignment.Left,
		color = Color3.fromRGB(9, 20, 9),
		stroke = 5,
	}):FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(80, 245, 60)

	-- Pets and their odds, spread over the space right of the egg.
	local total = 0
	for _, entry in egg.pets do
		total += entry.weight
	end
	local count = #egg.pets
	local step = math.min(123, 500 / math.max(count - 1, 1))
	for i, entry in egg.pets do
		local x = 560 + (i - (count + 1) / 2) * step
		PetImage.new("pet", entry.pet, {
			Size = UDim2.fromOffset(110, 110),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(x, 172),
			ZIndex = 3,
			Parent = card,
		})
		Cards.text(card, { text = percent(entry.weight / total), size = 32, at = Vector2.new(x, 242), width = 140, stroke = 3 })
	end

	for _, offer in OFFERS do
		Cards.gift(card, Vector2.new(offer.gift, 287), Vector2.new(75, 73), offer.product, giftOver)
		Cards.buy(card, Vector2.new(offer.price, 287), Vector2.new(133, 73), `{Cards.Robux}{Purchases.price("product", offer.product)}`, function()
			Purchases.product(offer.product)
		end)
		Cards.text(card, {
			text = offer.label,
			size = 28,
			at = Vector2.new(offer.price + 66, 364),
			width = 140,
			color = Color3.fromRGB(255, 214, 40),
			stroke = 3,
			zIndex = 8,
		})
	end
end

return LimitedSection
