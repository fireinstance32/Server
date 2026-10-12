-- "~ Hops ~": the three Hops packs and the Potion Pack as bigger cards.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Monetization = require(Shared.Config.Monetization)
local Format = require(Shared.Util.Format)

local Theme = require(script.Parent.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Parent.Components.Gradient)
local RobuxChip = require(script.Parent.Parent.Parent.Components.RobuxChip)
local Purchases = require(script.Parent.Parent.Parent.Parent.Purchases)
local Window = require(script.Parent.Parent.Window)

local new = Theme.new

local HopsSection = {}

local PACKS = { { "HopsPack1", "Yellow" }, { "HopsPack2", "Red" }, { "HopsPack3", "Rainbow" }, { "PotionPack", "Blue" } }

function HopsSection.build(list: ScrollingFrame, order: number)
	Window.header(list, "Hops", order)
	local row = new("Frame", {
		Size = UDim2.new(1, -10, 0, 110),
		BackgroundTransparency = 1,
		LayoutOrder = order + 1,
		Parent = list,
	}, {
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 10),
		}),
	})
	for _, spec in PACKS do
		local name, color = spec[1], spec[2]
		local button = new("TextButton", {
			Size = UDim2.new(1 / #PACKS, -8, 1, 0),
			Text = "",
			AutoButtonColor = true,
			Parent = row,
		}, { Theme.corner(12), Theme.stroke(4) })
		Gradient.apply(button, color)
		Theme.label({
			Size = UDim2.fromScale(0.8, 0.5),
			Position = UDim2.fromScale(0.1, 0.12),
			Text = if Monetization.HopsPacks[name]
				then `+{Format.abbreviate(Monetization.HopsPacks[name])} Hops`
				else `🧪 x{Monetization.PotionPackEach} each`,
			Parent = button,
		})
		RobuxChip.attach(button, Purchases.price("product", name))
		button.Activated:Connect(function()
			Purchases.product(name)
		end)
	end
end

return HopsSection
