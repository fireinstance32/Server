-- Right-side column: Starter Pack tile and pass cards (+2x Hops, 2x Wins).

local Theme = require(script.Parent.Parent.Theme)
local IconTile = require(script.Parent.Parent.Components.IconTile)
local PassCard = require(script.Parent.Parent.Components.PassCard)
local Purchases = require(script.Parent.Parent.Parent.Purchases)
local State = require(script.Parent.Parent.Parent.State)

local new = Theme.new

local PassColumn = {}

local CARDS = {
	{ pass = "DoubleHops", title = "+2x HOPS", color = "Green" },
	{ pass = "DoubleWins", title = "2x WINS", color = "Yellow" },
}

function PassColumn.init(gui: ScreenGui, openMenu: (string) -> ())
	local column = new("Frame", {
		Name = "PassColumn",
		Size = UDim2.fromOffset(210, 300),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -20, 0.45, 0),
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		new("UIListLayout", {
			Padding = UDim.new(0, 10),
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	local starter = IconTile.create({
		icon = "🎉",
		caption = "Starter Pack",
		color = "Rainbow",
		order = 0,
		onClick = function()
			openMenu("Shop")
		end,
	})
	starter.Size = UDim2.fromOffset(100, 100)
	starter.Parent = column

	local cards = {}
	for i, spec in CARDS do
		local card = PassCard.create({
			title = spec.title,
			price = Purchases.price("pass", spec.pass),
			color = spec.color,
			order = i,
			onClick = function()
				if not Purchases.owns(spec.pass) then
					Purchases.pass(spec.pass)
				end
			end,
		})
		card.button.Parent = column
		cards[spec.pass] = card
	end

	State.observe(function()
		for pass, card in cards do
			card.setOwned(Purchases.owns(pass))
		end
	end)
end

return PassColumn
