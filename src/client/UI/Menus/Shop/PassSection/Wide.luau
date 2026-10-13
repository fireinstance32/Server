-- Half-width and full-width pass cards from the reference ("AFK WINS / Auto
-- Win", "Koi Zone", "Admin Zone"): a small caption, a big two-line title,
-- the icon on the right (on the left with rays when full width), gift and
-- price buttons along the bottom.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Monetization = require(ReplicatedStorage:WaitForChild("Shared").Config.Monetization)

local Rays = require(script.Parent.Parent.Parent.Parent.Components.Rays)
local Purchases = require(script.Parent.Parent.Parent.Parent.Parent.Purchases)
local Cards = require(script.Parent.Parent.Cards)

export type Spec = {
	pass: string,
	caption: string,
	title: string, -- "Auto\nLift"
	icon: string,
	colors: string,
	ink: Color3?, -- title colour (default white)
}

local LEFT = Enum.TextXAlignment.Left
local RIGHT = Enum.TextXAlignment.Right

local function buy(card: Frame, spec: Spec, giftAt: Vector2, priceAt: Vector2, priceSize: Vector2, giftOver: GuiObject): TextButton
	if Monetization.GiftIds[spec.pass] then
		Cards.gift(card, giftAt, Vector2.new(80, priceSize.Y), spec.pass, giftOver)
	end
	return Cards.buy(card, priceAt, priceSize, `{Cards.Robux}{Monetization.Passes[spec.pass].price}`, function()
		-- The Strength card sells the next tier (2x → 4x → 8x → 16x).
		local pass = spec.pass
		if pass == "DoubleHops" then
			local _, nextTier = Monetization.strengthTier(Purchases.owns)
			pass = if nextTier then nextTier.pass else pass
		end
		if not Purchases.owns(pass) then
			Purchases.pass(pass)
		end
	end)
end

local Wide = {}

-- 440×328 card at `x` in `row`.
function Wide.half(row: Frame, x: number, spec: Spec, giftOver: GuiObject): TextButton
	local card = Cards.card(row, { name = spec.pass, size = Vector2.new(440, 328), position = Vector2.new(x, 0), colors = spec.colors, edge = 8 })
	Cards.icon(card, spec.icon, Vector2.new(327, 160), 175, 0, 3)
	Cards.text(card, { text = spec.caption, size = 36, at = Vector2.new(37, 56), anchor = Vector2.new(0, 0.5), align = LEFT, width = 400, stroke = 3 })
	local lines = string.split(spec.title, "\n")
	for i, line in lines do
		Cards.text(card, {
			text = line,
			size = 64,
			at = Vector2.new(32, 125 + (i - 1) * 63),
			anchor = Vector2.new(0, 0.5),
			align = LEFT,
			width = 400,
			color = spec.ink,
			stroke = 5,
		})
	end
	return buy(card, spec, Vector2.new(22, 228), Vector2.new(114, 228), Vector2.new(288, 75), giftOver)
end

-- Full-width 894×328 card: art with rays on the left, text on the right.
function Wide.full(list: ScrollingFrame, order: number, spec: Spec, giftOver: GuiObject): TextButton
	local card = Cards.card(list, { name = spec.pass, size = Vector2.new(894, 328), order = order, colors = spec.colors, edge = 8 })
	Rays.new({
		Size = UDim2.fromOffset(520, 520),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(232, 164),
		ZIndex = 2,
		Parent = card,
	}, Color3.new(1, 1, 1), 12, false, 0.35)
	card.ClipsDescendants = true
	Cards.icon(card, spec.icon, Vector2.new(232, 167), 260, -8, 3)
	local title = Cards.text(card, {
		text = (string.gsub(spec.title, "\n", " ")),
		size = 57,
		at = Vector2.new(857, 77),
		anchor = Vector2.new(1, 0.5),
		align = RIGHT,
		width = 600,
		color = spec.ink,
		stroke = 5,
	})
	title.ZIndex = 5
	Cards.text(card, { text = spec.caption, size = 40, at = Vector2.new(857, 154), anchor = Vector2.new(1, 0.5), align = RIGHT, width = 500, stroke = 4 })
	return buy(card, spec, Vector2.new(420, 215), Vector2.new(512, 215), Vector2.new(348, 73), giftOver)
end

return Wide
