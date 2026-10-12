-- Top-left stats: Hops, Wins, Rebirths and the current multipliers.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Format = require(ReplicatedStorage:WaitForChild("Shared").Util.Format)
local Theme = require(script.Parent.Parent.Theme)
local State = require(script.Parent.Parent.Parent.State)

local new = Theme.new
local C = Theme.Colors

local StatsPanel = {}

local function statRow(order: number, icon: string, color: Color3): (TextLabel, Frame)
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = color,
		LayoutOrder = order,
	}, { Theme.corner(12), Theme.stroke(3) })
	Theme.label({
		Size = UDim2.fromOffset(40, 36),
		Position = UDim2.fromOffset(6, 4),
		Text = icon,
		Parent = row,
	})
	local value = Theme.label({
		Size = UDim2.new(1, -56, 0, 34),
		Position = UDim2.fromOffset(50, 5),
		Text = "0",
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})
	return value, row
end

function StatsPanel.init(gui: ScreenGui)
	local panel = new("Frame", {
		Size = UDim2.fromOffset(230, 200),
		Position = UDim2.fromOffset(12, 12),
		BackgroundTransparency = 1,
		Parent = gui,
	}, { new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })

	local labels: { [string]: TextLabel } = {}
	local rows = {
		{ "Hops", "🐸", C.Green },
		{ "Wins", "🏆", C.Gold },
		{ "Rebirths", "🔁", C.Purple },
	}
	for i, row in rows do
		local value, frame = statRow(i, row[2], row[3])
		frame.Parent = panel
		labels[row[1]] = value
	end
	local multiplier = Theme.label({
		Size = UDim2.new(1, 0, 0, 26),
		LayoutOrder = 10,
		Text = "",
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = panel,
	})

	State.observe(function(data)
		labels.Hops.Text = Format.abbreviate(data.hops)
		labels.Wins.Text = Format.abbreviate(data.wins)
		labels.Rebirths.Text = Format.abbreviate(data.rebirths)
		local hopsMult = Format.multiplier(data.hopsMultiplier)
		local winsMult = Format.multiplier(data.winsMultiplier)
		multiplier.Text = `Hops {hopsMult}  •  Wins {winsMult}`
	end)
end

return StatsPanel
