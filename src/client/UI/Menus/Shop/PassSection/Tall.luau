-- A narrow pass card from the reference "+1 Pet Slot" row (three per row):
-- title, big icon with a "+N" tag, gift and price buttons.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Monetization = require(ReplicatedStorage:WaitForChild("Shared").Config.Monetization)

local Purchases = require(script.Parent.Parent.Parent.Parent.Parent.Purchases)
local Cards = require(script.Parent.Parent.Cards)

export type Spec = { pass: string, title: string, icon: string, tag: string, colors: string }

return function(row: Frame, x: number, spec: Spec, giftOver: GuiObject): TextButton
	local card = Cards.card(row, { name = spec.pass, size = Vector2.new(286, 324), position = Vector2.new(x, 0), colors = spec.colors })
	local mid = 143
	Cards.text(card, { text = spec.title, size = 40, at = Vector2.new(mid, 52), width = 280, stroke = 4 })
	Cards.icon(card, spec.icon, Vector2.new(mid, 160), 150)
	Cards.text(card, { text = spec.tag, size = 57, at = Vector2.new(mid + 52, 112), width = 140, stroke = 5, zIndex = 5 })
	if Monetization.GiftIds[spec.pass] then
		Cards.gift(card, Vector2.new(13, 227), Vector2.new(80, 75), spec.pass, giftOver)
	end
	return Cards.buy(card, Vector2.new(105, 227), Vector2.new(147, 75), `{Cards.Robux}{Monetization.Passes[spec.pass].price}`, function()
		if not Purchases.owns(spec.pass) then
			Purchases.pass(spec.pass)
		end
	end)
end
