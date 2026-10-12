-- "~ Passes ~": every game pass as a row with Buy / OWNED.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Monetization = require(ReplicatedStorage:WaitForChild("Shared").Config.Monetization)

local Theme = require(script.Parent.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Parent.Components.Gradient)
local Purchases = require(script.Parent.Parent.Parent.Parent.Purchases)
local Window = require(script.Parent.Parent.Window)

local PassSection = {}

local ORDER = { "AutoHop", "DoubleHops", "DoubleWins", "AutoRebirth", "ExtraPetSlots" }
local ICONS = { AutoHop = "🤖", DoubleHops = "🐸", DoubleWins = "🏆", AutoRebirth = "🔁", ExtraPetSlots = "🐾" }

function PassSection.build(list: ScrollingFrame, order: number)
	Window.header(list, "Passes", order)

	local buttons = {}
	for i, name in ORDER do
		local item = Monetization.Passes[name]
		local row = Window.card(list, order + i)
		row.Size = UDim2.new(1, -10, 0, 70)
		Theme.label({ Size = UDim2.fromOffset(60, 60), Position = UDim2.fromOffset(10, 5), Text = ICONS[name] or "⭐", Parent = row })
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
		}, "Green", function()
			if not Purchases.owns(name) then
				Purchases.pass(name)
			end
		end)
		buy.Font = Enum.Font.BuilderSansBold
		buy.Parent = row
		buttons[name] = buy
	end

	return function()
		for name, button in buttons do
			local owned = Purchases.owns(name)
			button.Text = if owned then "OWNED" else `\u{E002} {Monetization.Passes[name].price}`
			Gradient.apply(button, if owned then "Grey" else "Green")
		end
	end
end

return PassSection
