-- "~ Wins Pack ~" (reference): four packs in a 2×2 grid with a growing pile
-- of trophies, then the full-width Mega Pack with its first-time discount
-- (WinsPackMega once, WinsPackMega2 after). Amounts: Config/Monetization.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Monetization = require(Shared.Config.Monetization)
local Format = require(Shared.Util.Format)

local Purchases = require(script.Parent.Parent.Parent.Parent.Purchases)
local Cards = require(script.Parent.Cards)

local WinsSection = {}

local CREAM = Color3.fromRGB(255, 243, 180)
local RIGHT = Enum.TextXAlignment.Right
local LEFT = Enum.TextXAlignment.Left

local PACKS = { "WinsPack1", "WinsPack2", "WinsPack3", "WinsPack4" }
local PILES = { 1, 3, 5, 9 } -- trophies in each pack's pile

local function wins(product: string): string
	return `+{Format.abbreviate(Monetization.Bundles[product].rewards[1].amount)} Wins`
end

-- `count` trophies stacked in rows (back rows smaller and higher).
local function pile(card: Frame, centre: Vector2, count: number, side: number)
	local rows = if count == 9 then { 1, 2, 3, 3 } elseif count == 5 then { 2, 3 } elseif count == 3 then { 1, 2 } else { 1 }
	local placed = 0
	for r, n in rows do
		local y = centre.Y + (r - #rows / 2 - 0.5) * side * 0.38
		local s = side * (0.75 + 0.25 * r / #rows)
		for i = 1, n do
			placed += 1
			if placed > count then
				return
			end
			Cards.icon(card, "trophy", Vector2.new(centre.X + (i - (n + 1) / 2) * s * 0.62, y), s, 0, 2 + r)
		end
	end
end

local function pack(grid: Frame, i: number, product: string)
	local x = if i % 2 == 1 then 8 else 462
	local card = Cards.card(grid, {
		name = product,
		size = Vector2.new(440, 258),
		position = Vector2.new(x, if i > 2 then 271 else 0),
		colors = "Wins",
		edge = 8,
	})
	Cards.text(card, { text = Monetization.Products[product].label, size = 54, at = Vector2.new(220, 53), color = CREAM, stroke = 5 })
	pile(card, Vector2.new(117, 161), PILES[i], if PILES[i] > 3 then 82 elseif PILES[i] == 3 then 110 else 150)
	Cards.text(card, { text = wins(product), size = 40, at = Vector2.new(416, 131), anchor = Vector2.new(1, 0.5), align = RIGHT, width = 300, stroke = 4 })
	Cards.buy(card, Vector2.new(229, 158), Vector2.new(185, 73), `{Cards.Robux}{Purchases.price("product", product)}`, function()
		Purchases.product(product)
	end)
end

function WinsSection.build(list: ScrollingFrame, order: number)
	Cards.header(list, "Wins Pack", order)
	local grid = Cards.row(list, 529, order + 1)
	for i, product in PACKS do
		pack(grid, i, product)
	end

	local mega = Cards.card(list, { name = "WinsPackMega", size = Vector2.new(894, 258), order = order + 2, colors = "Wins", edge = 8 })
	Cards.text(mega, { text = "Mega Pack", size = 56, at = Vector2.new(32, 59), anchor = Vector2.new(0, 0.5), align = LEFT, color = CREAM, stroke = 5 })
	Cards.icon(mega, "trophy", Vector2.new(190, 160), 170, 0, 8)
	pile(mega, Vector2.new(190, 175), 5, 90)
	local discount = Cards.text(mega, { text = "FIRST TIME DISCOUNT", size = 36, at = Vector2.new(617, 49), color = Color3.fromRGB(240, 30, 50), stroke = 3 })
	Cards.text(mega, { text = wins("WinsPackMega"), size = 57, at = Vector2.new(622, 120), stroke = 5 })
	local was = Cards.struck(mega, Vector2.new(587, 196), Monetization.Bundles.WinsPackMega.was or 0)
	local first = true
	local button = Cards.buy(mega, Vector2.new(672, 159), Vector2.new(185, 73), "", function()
		Purchases.product(if first then "WinsPackMega" else "WinsPackMega2")
	end)

	-- After the first Mega Pack: full price, no discount line.
	return function(data)
		first = not (data.oneTime and data.oneTime.WinsPackMega)
		discount.Visible = first
		was.Visible = first
		Cards.setPrice(button, `{Cards.Robux}{Purchases.price("product", if first then "WinsPackMega" else "WinsPackMega2")}`, false)
	end
end

return WinsSection
