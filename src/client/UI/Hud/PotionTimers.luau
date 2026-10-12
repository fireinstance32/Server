-- Small live timers for active potions ("🧪 x2 9:41"), above the tile grid.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Potions = require(ReplicatedStorage:WaitForChild("Shared").Config.Potions)

local Theme = require(script.Parent.Parent.Theme)
local State = require(script.Parent.Parent.Parent.State)

local new = Theme.new

local PotionTimers = {}

function PotionTimers.init(gui: ScreenGui)
	local frame = new("Frame", {
		Name = "PotionTimers",
		Size = UDim2.fromOffset(220, 120),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 20, 0.5, -186),
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		new("UIListLayout", {
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, 4),
		}),
	})
	local labels = {}
	for i, potion in Potions.List do
		labels[potion.id] = Theme.label({
			Size = UDim2.new(1, 0, 0, 28),
			Text = "",
			Visible = false,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = i,
			Parent = frame,
		})
	end

	-- Count down locally from the last snapshot; the server clears expired ones.
	local ends: { [string]: number } = {}
	State.observe(function(data)
		local now = os.clock()
		table.clear(ends)
		for id, seconds in data.potionTimers or {} do
			ends[id] = now + seconds
		end
	end)
	task.spawn(function()
		while frame.Parent do
			local now = os.clock()
			for _, potion in Potions.List do
				local label = labels[potion.id]
				local left = math.max(math.floor((ends[potion.id] or 0) - now), 0)
				label.Visible = left > 0
				label.Text = `{potion.icon} x{potion.factor} {potion.stat}  {string.format("%d:%02d", left // 60, left % 60)}`
			end
			task.wait(1)
		end
	end)
end

return PotionTimers
