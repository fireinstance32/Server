-- "~ Passes ~": every game pass as a row with Buy / OWNED.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Monetization = require(ReplicatedStorage:WaitForChild("Shared").Config.Monetization)

local Theme = require(script.Parent.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Parent.Components.Gradient)
local Purchases = require(script.Parent.Parent.Parent.Parent.Purchases)
local Window = require(script.Parent.Parent.Window)
local Icon = require(script.Parent.Parent.Parent.Components.Icon)

local PassSection = {}

local ICONS = {
	AutoHop = "crown",
	DoubleHops = "bolt",
	DoubleWins = "trophy",
	AutoRebirth = "rebirth",
	ExtraPetSlots = "pets",
	PetStorage = "inventory",
	HatchTriple = "egg",
	HatchOcto = "egg",
	OfflineDouble = "daily",
	PondGolden = "star",
	PondRainbow = "portal",
	PondCosmic = "globe",
}

-- Every pass in Config/Monetization, cheapest first.
local function passOrder(): { string }
	local names = {}
	for name in Monetization.Passes do
		table.insert(names, name)
	end
	table.sort(names, function(a, b)
		return Monetization.Passes[a].price < Monetization.Passes[b].price
	end)
	return names
end

function PassSection.build(list: ScrollingFrame, order: number)
	Window.header(list, "Passes", order)

	local buttons = {}
	for i, name in passOrder() do
		local item = Monetization.Passes[name]
		local row = Window.card(list, order + i)
		row.Size = UDim2.new(1, -10, 0, 70)
		Icon.new(ICONS[name] or "star", { Size = UDim2.fromOffset(62, 62), Position = UDim2.fromOffset(8, 4), Parent = row })
		Theme.label({
			Size = UDim2.new(1, -280, 0, 44),
			Position = UDim2.fromOffset(80, 13),
			Text = item.label,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})
		local buy = Window.button({
			Size = UDim2.fromOffset(160, 52),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Text = `\u{E002} {item.price}`,
			Font = Enum.Font.BuilderSansBold,
		}, "Green", function()
			if not Purchases.owns(name) then
				Purchases.pass(name)
			end
		end)
		buy.Parent = row
		buttons[name] = buy
	end

	return function()
		for name, button in buttons do
			local owned = Purchases.owns(name)
			Theme.setText(button, if owned then "OWNED" else `\u{E002} {Monetization.Passes[name].price}`)
			Gradient.apply(button, if owned then "Grey" else "Green")
		end
	end
end

return PassSection
