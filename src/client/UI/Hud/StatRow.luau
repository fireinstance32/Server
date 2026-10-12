-- The line above the Level bar: "⚡ 125 HOPS" (left) and "x5 Multiplier"
-- (right, click for the breakdown).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Format = require(ReplicatedStorage:WaitForChild("Shared").Util.Format)
local Theme = require(script.Parent.Parent.Theme)
local State = require(script.Parent.Parent.Parent.State)
local MultiplierInfo = require(script.Parent.MultiplierInfo)
local Icon = require(script.Parent.Parent.Components.Icon)

local C = Theme.Colors

local StatRow = {}

function StatRow.init(parent: Frame)
	Icon.new("bolt", {
		Size = UDim2.fromOffset(48, 48),
		Position = UDim2.fromOffset(-6, -6),
		Parent = parent,
	})
	local hops = Theme.label({
		Name = "Hops",
		Size = UDim2.new(0.5, -44, 0, 40),
		Position = UDim2.fromOffset(44, 0),
		Text = "0 HOPS",
		TextColor3 = C.Gold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = parent,
	})
	Theme.textStroke().Parent = hops

	local multiplier = Theme.new("TextButton", {
		Name = "Multiplier",
		Size = UDim2.new(0.5, 0, 0, 40),
		Position = UDim2.fromScale(0.5, 0),
		BackgroundTransparency = 1,
		Font = Theme.Font,
		Text = "x1 Multiplier",
		TextColor3 = C.Gold,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = parent,
	}, { Theme.textStroke() })
	MultiplierInfo.init(parent, multiplier)

	State.observe(function(data)
		hops.Text = `{Format.abbreviate(data.hops)} HOPS`
		multiplier.Text = `{Format.multiplier(data.hopsMultiplier)} Multiplier`
	end)
end

return StatRow
