-- Right-side column: Starter Pack picture (until bought) and pass cards
-- (Strength multiplier: the next tier to buy, 2x → 4x → 8x → 16x; 2x Wins).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Monetization = require(ReplicatedStorage:WaitForChild("Shared").Config.Monetization)

local Theme = require(script.Parent.Parent.Theme)
local StarterPackIcon = require(script.Parent.StarterPackIcon)
local PassCard = require(script.Parent.Parent.Components.PassCard)
local Purchases = require(script.Parent.Parent.Parent.Purchases)
local State = require(script.Parent.Parent.Parent.State)

local new = Theme.new

local PassColumn = {}

local CARDS = {
	{ pass = "DoubleHops", title = "+2x STRENGTH", icon = "bolt", color = "Lime" },
	{ pass = "DoubleWins", title = "2x WINS", icon = "trophy", color = "Gold" },
}

function PassColumn.init(gui: ScreenGui, openMenu: (string) -> ())
	local column = new("Frame", {
		Name = "PassColumn",
		Size = UDim2.fromOffset(200, 360),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -100, 0.43, 0),
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		new("UIListLayout", {
			Padding = UDim.new(0, 13),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	-- Starter Pack: its picture with a small caption (reference), no tile.
	local starter = new("TextButton", {
		Name = "StarterPack",
		Size = UDim2.fromOffset(170, 175),
		BackgroundTransparency = 1,
		Text = "",
		LayoutOrder = 0,
		Parent = column,
	})
	StarterPackIcon.new(starter)
	Theme.label({
		Size = UDim2.new(1.1, 0, 0, 24),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -4),
		Text = "STARTER PACK",
		ZIndex = 8,
		Parent = starter,
	})
	local scale = new("UIScale", { Parent = starter })
	Theme.hover(starter, scale)
	starter.Activated:Connect(function()
		openMenu("Shop")
	end)

	local cards = {}
	for i, spec in CARDS do
		local card = PassCard.create({
			title = spec.title,
			icon = spec.icon,
			price = Purchases.price("pass", spec.pass),
			color = spec.color,
			order = i,
			onClick = function()
				-- The Strength card always offers the next tier.
				local pass = spec.pass
				if pass == "DoubleHops" then
					local _, nextTier = Monetization.strengthTier(Purchases.owns)
					pass = if nextTier then nextTier.pass else pass
				end
				if not Purchases.owns(pass) then
					Purchases.pass(pass)
				end
			end,
		})
		card.button.Parent = column
		cards[spec.pass] = card
	end

	State.observe(function()
		local data = State.data
		starter.Visible = not (data and data.oneTime and data.oneTime.StarterPack)
		for pass, card in cards do
			if pass == "DoubleHops" then
				local best, nextTier = Monetization.strengthTier(Purchases.owns)
				local shown = nextTier or { pass = "", factor = best or 16 }
				local price = if nextTier then Monetization.Passes[nextTier.pass].price else 0
				card.set(`+{shown.factor}x STRENGTH`, price, nextTier == nil)
			else
				card.setOwned(Purchases.owns(pass))
			end
		end
	end)
end

return PassColumn
