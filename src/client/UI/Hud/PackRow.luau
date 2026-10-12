-- Three Robux Hops packs under the Level bar: +10K / +100K / +1M.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Monetization = require(Shared.Config.Monetization)
local Format = require(Shared.Util.Format)

local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Components.Gradient)
local RobuxChip = require(script.Parent.Parent.Components.RobuxChip)
local Studs = require(script.Parent.Parent.Components.Studs)
local Icon = require(script.Parent.Parent.Components.Icon)
local Purchases = require(script.Parent.Parent.Parent.Purchases)

local new = Theme.new

local PackRow = {}

local PACKS = {
	{ name = "HopsPack1", color = "Yellow" },
	{ name = "HopsPack2", color = "Red" },
	{ name = "HopsPack3", color = "Rainbow" },
}

function PackRow.init(parent: Frame, y: number, height: number)
	local row = new("Frame", {
		Name = "PackRow",
		Size = UDim2.new(1, 0, 0, height),
		Position = UDim2.fromOffset(0, y),
		BackgroundTransparency = 1,
		Parent = parent,
	}, {
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	for i, pack in PACKS do
		local button = new("TextButton", {
			Name = pack.name,
			Size = UDim2.new(1 / 3, -7, 1, 0),
			Text = "",
			AutoButtonColor = true,
			LayoutOrder = i,
			Parent = row,
		}, { Theme.corner(12), Theme.stroke(4) })
		Gradient.apply(button, pack.color)
		Studs.apply(button, 22, 0.5)
		-- Big lightning bolt behind the amount (reference packs).
		Icon.new("bolt", {
			Size = UDim2.fromScale(0.42, 1.25),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.45),
			Rotation = 12,
			ZIndex = 2,
			Parent = button,
		})
		Theme.label({
			Size = UDim2.fromScale(0.8, 0.62),
			Position = UDim2.fromScale(0.1, 0.1),
			Text = `+{Format.abbreviate(Monetization.HopsPacks[pack.name])}`,
			ZIndex = 3,
			Parent = button,
		})
		RobuxChip.attach(button, Purchases.price("product", pack.name))
		button.Activated:Connect(function()
			Purchases.product(pack.name)
		end)
	end
end

return PackRow
