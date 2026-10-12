-- "~ Gamepasses ~" (reference): a two-column grid of coloured, studded cards
-- with a big icon, name, what it does, a gift button (giftable passes) and
-- the price / OWNED.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Monetization = require(ReplicatedStorage:WaitForChild("Shared").Config.Monetization)

local Theme = require(script.Parent.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Parent.Components.Gradient)
local Studs = require(script.Parent.Parent.Parent.Components.Studs)
local Icon = require(script.Parent.Parent.Parent.Components.Icon)
local Purchases = require(script.Parent.Parent.Parent.Parent.Purchases)
local Window = require(script.Parent.Parent.Window)
local GiftPicker = require(script.Parent.GiftPicker)

local new = Theme.new

local PassSection = {}

-- Look and blurb per pass (UI text only; prices live in Config/Monetization).
local LOOK: { [string]: { icon: string, color: string, blurb: string, title: string? } } = {
	DoubleHops = { icon = "bolt", color = "Green", blurb = "Double every Hop you earn" },
	AutoHop = { icon = "frog", color = "Red", blurb = "Hops for you, even while you chill" },
	DoubleWins = { icon = "trophy", color = "Yellow", blurb = "Double every Win you earn" },
	OfflineDouble = { icon = "daily", color = "Blue", blurb = "2x rewards while you're away" },
	PondGolden = { icon = "star", color = "Yellow", blurb = "Train at the 3x Golden Pond", title = "Golden Pond" },
	AutoRebirth = { icon = "rebirth", color = "Blue", blurb = "Rebirths the moment you can" },
	PetStorage = { icon = "inventory", color = "Pink", blurb = "Room for 100 more pets" },
	ExtraPetSlots = { icon = "pets", color = "Purple", blurb = "Equip 2 more pets at once" },
	HatchTriple = { icon = "egg", color = "Blue", blurb = "Hatch 3 eggs at once", title = "Triple Hatch" },
	PondRainbow = { icon = "portal", color = "Rainbow", blurb = "Train at the 15x Rainbow Pond", title = "Rainbow Pond" },
	HatchOcto = { icon = "egg", color = "Purple", blurb = "Hatch 8 eggs at once", title = "Octo Hatch" },
	PondCosmic = { icon = "globe", color = "Purple", blurb = "Train at the 50x Cosmic Pond", title = "Cosmic Pond" },
}

local CARD_HEIGHT = 156

-- Every pass in Config/Monetization, cheapest first.
local function passOrder(): { string }
	local names = {}
	for name in Monetization.Passes do
		table.insert(names, name)
	end
	table.sort(names, function(a, b)
		local pa, pb = Monetization.Passes[a].price, Monetization.Passes[b].price
		return if pa ~= pb then pa < pb else a < b
	end)
	return names
end

local function card(grid: Instance, order: number, name: string, giftOver: GuiObject): TextButton
	local item = Monetization.Passes[name]
	local look = LOOK[name] or { icon = "star", color = "Blue", blurb = "" }
	local frame = new("Frame", { Name = name, LayoutOrder = order, Parent = grid }, {
		Theme.corner(14),
		Theme.stroke(4, Color3.fromRGB(12, 12, 16)),
	})
	Gradient.apply(frame, look.color)
	Studs.apply(frame, 26)
	Icon.new(look.icon, {
		Size = UDim2.fromOffset(104, 104),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 6, 0.5, -6),
		Rotation = -8,
		ZIndex = 3,
		Parent = frame,
	})
	local title = Theme.label({
		Size = UDim2.new(1, -124, 0, 36),
		Position = UDim2.fromOffset(116, 10),
		Text = look.title or item.label,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
		Parent = frame,
	})
	title:FindFirstChildOfClass("UIStroke").Thickness = 3
	local blurb = Theme.label({
		Size = UDim2.new(1, -124, 0, 40),
		Position = UDim2.fromOffset(116, 46),
		Text = look.blurb,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
		Parent = frame,
	})
	blurb:FindFirstChildOfClass("UIStroke").Thickness = 2

	local giftable = Monetization.GiftIds[name] ~= nil
	if giftable then
		local gift = Window.button({
			Size = UDim2.fromOffset(52, 52),
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 116, 1, -10),
			Text = "",
			ZIndex = 3,
		}, "Pink", function()
			GiftPicker.open(giftOver, name)
		end)
		gift.Parent = frame
		Icon.new("gifts", { Size = UDim2.fromScale(0.86, 0.86), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ZIndex = 5, Parent = gift })
	end
	local left = if giftable then 176 else 116
	local buy = Window.button({
		Size = UDim2.new(1, -left - 10, 0, 52),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, left, 1, -10),
		Text = `\u{E002} {item.price}`,
		Font = Enum.Font.BuilderSansBold,
		ZIndex = 3,
	}, "Green", function()
		if not Purchases.owns(name) then
			Purchases.pass(name)
		end
	end)
	buy.Parent = frame
	return buy
end

function PassSection.build(list: ScrollingFrame, order: number, giftOver: GuiObject)
	Window.header(list, "Gamepasses", order)
	local names = passOrder()
	local grid = new("Frame", {
		Size = UDim2.new(1, -10, 0, math.ceil(#names / 2) * (CARD_HEIGHT + 12)),
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
	local buttons = {}
	for i, name in names do
		buttons[name] = card(grid, i, name, giftOver)
	end

	return function()
		for name, button in buttons do
			local owned = Purchases.owns(name)
			Theme.setText(button, if owned then "OWNED" else `\u{E002} {Monetization.Passes[name].price}`)
			Window.recolor(button, if owned then "Grey" else "Green")
		end
	end
end

return PassSection
