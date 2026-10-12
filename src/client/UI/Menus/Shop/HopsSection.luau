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
local Studs = require(script.Parent.Parent.Parent.Components.Studs)
local Icon = require(script.Parent.Parent.Parent.Components.Icon)

local new = Theme.new

local HopsSection = {}

local PACKS = { { "HopsPack1", "Yellow" }, { "HopsPack2", "Red" }, { "HopsPack3", "Rainbow" }, { "PotionPack", "Blue" } }

function HopsSection.build(list: ScrollingFrame, order: number)
	Window.header(list, "Hops", order)
	local row = new("Frame", {
		Size = UDim2.new(1, -10, 0, 130),
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
		Studs.apply(button, 22, 0.45)
		if Monetization.HopsPacks[name] then
			Icon.new("bolt", { Size = UDim2.fromScale(0.5, 0.8), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, -0.04), Rotation = 12, ZIndex = 2, Parent = button })
		else
			-- Potion Pack: the three potions fanned out.
			for i, potion in { "potion_hops", "potion_wins", "potion_luck" } do
				Icon.new(potion, { Size = UDim2.fromScale(0.36, 0.56), Position = UDim2.fromScale(0.04 + (i - 1) * 0.3, 0.02), Rotation = (i - 2) * 12, ZIndex = 2, Parent = button })
			end
		end
		Theme.label({
			Size = UDim2.fromScale(0.86, 0.34),
			Position = UDim2.fromScale(0.07, 0.42),
			Text = if Monetization.HopsPacks[name]
				then `+{Format.abbreviate(Monetization.HopsPacks[name])}`
				else `x{Monetization.PotionPackEach} each`,
			ZIndex = 3,
			Parent = button,
		})
		RobuxChip.attach(button, Purchases.price("product", name))
		button.Activated:Connect(function()
			Purchases.product(name)
		end)
	end
end

return HopsSection
