-- "~ Hops Packs ~" (reference Wins Pack grid): 2×2 studded cards – the
-- three Hops packs with a growing pile of bolts, and the Potion Pack – each
-- with its amount, gift button and price.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Monetization = require(Shared.Config.Monetization)
local Format = require(Shared.Util.Format)

local Theme = require(script.Parent.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Parent.Components.Gradient)
local Purchases = require(script.Parent.Parent.Parent.Parent.Purchases)
local Window = require(script.Parent.Parent.Window)
local Studs = require(script.Parent.Parent.Parent.Components.Studs)
local Icon = require(script.Parent.Parent.Parent.Components.Icon)
local GiftPicker = require(script.Parent.GiftPicker)

local new = Theme.new

local HopsSection = {}

local PACKS = {
	{ id = "HopsPack1", title = "Small Hops", color = "Blue", bolts = 1 },
	{ id = "HopsPack2", title = "Big Hops", color = "Purple", bolts = 3 },
	{ id = "HopsPack3", title = "Huge Hops", color = "Pink", bolts = 5 },
	{ id = "PotionPack", title = "Potion Pack", color = "Green", bolts = 0 },
}

local CARD_HEIGHT = 190

-- A fan of bolts (bigger pack, bigger pile) or the three potions.
local function pile(card: Frame, bolts: number)
	local holder = new("Frame", {
		Size = UDim2.new(0.5, 0, 0, 104),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 38),
		BackgroundTransparency = 1,
		ZIndex = 3,
		Parent = card,
	})
	if bolts == 0 then
		for i, potion in { "potion_hops", "potion_wins", "potion_luck" } do
			Icon.new(potion, {
				Size = UDim2.fromOffset(78, 78),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, (i - 2) * 56, 0.5, if i == 2 then -6 else 6),
				Rotation = (i - 2) * 14,
				ZIndex = if i == 2 then 4 else 3,
				Parent = holder,
			})
		end
		return
	end
	for i = 1, bolts do
		local spread = (i - (bolts + 1) / 2)
		Icon.new("bolt", {
			Size = UDim2.fromOffset(86, 86),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, spread * 30, 0.5, math.abs(spread) * 8),
			Rotation = spread * 12,
			ZIndex = 3 + bolts - math.floor(math.abs(spread)),
			Parent = holder,
		})
	end
end

function HopsSection.build(list: ScrollingFrame, order: number, giftOver: GuiObject)
	Window.header(list, "Hops Packs", order)
	local grid = new("Frame", {
		Size = UDim2.new(1, -10, 0, math.ceil(#PACKS / 2) * (CARD_HEIGHT + 12)),
		BackgroundTransparency = 1,
		LayoutOrder = order + 1,
		Parent = list,
	}, {
		new("UIGridLayout", {
			CellSize = UDim2.new(0.5, -6, 0, CARD_HEIGHT),
			CellPadding = UDim2.fromOffset(12, 12),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	for i, pack in PACKS do
		local card = new("Frame", { Name = pack.id, LayoutOrder = i, Parent = grid }, {
			Theme.corner(14),
			Theme.stroke(4, Color3.fromRGB(12, 12, 16)),
		})
		Gradient.apply(card, pack.color)
		Studs.apply(card, 26, 0.32)
		Theme.label({ Size = UDim2.new(1, -20, 0, 34), Position = UDim2.fromOffset(10, 6), Text = pack.title, ZIndex = 3, Parent = card })
		pile(card, pack.bolts)
		local amount = Theme.label({
			Size = UDim2.new(0.5, -10, 0, 44),
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 12, 1, -10),
			Text = if Monetization.HopsPacks[pack.id]
				then `+{Format.abbreviate(Monetization.HopsPacks[pack.id])}`
				else `x{Monetization.PotionPackEach} each`,
			TextColor3 = Color3.fromRGB(255, 236, 90),
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 3,
			Parent = card,
		})
		Theme.textStroke(4).Parent = amount
		local giftable = Monetization.GiftIds[pack.id] ~= nil
		if giftable then
			local gift = Window.button({
				Size = UDim2.fromOffset(46, 46),
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -10, 0, 10),
				Text = "",
				ZIndex = 4,
			}, "Pink", function()
				GiftPicker.open(giftOver, pack.id)
			end)
			gift.Parent = card
			Icon.new("gifts", { Size = UDim2.fromScale(0.86, 0.86), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ZIndex = 5, Parent = gift })
		end
		local buy = Window.button({
			Size = UDim2.new(0.5, -16, 0, 50),
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -10, 1, -10),
			Text = `\u{E002} {Purchases.price("product", pack.id)}`,
			Font = Enum.Font.BuilderSansBold,
			ZIndex = 3,
		}, "Green", function()
			Purchases.product(pack.id)
		end)
		buy.Parent = card
	end
end

return HopsSection
