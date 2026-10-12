-- Rainbow tip line in a dark box at the very top (reference: "You'll still
-- train offline even if you log out"). Cycles through tips every few seconds.

local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Components.Gradient)

local TipTicker = {}

local TIPS = {
	"You'll still train offline even if you log out!",
	"Each pad your frog hops = +Hops!",
	"Pets ADD to your multiplier – hatch the best ones!",
	"Reach MAX LEVEL, then Rebirth for a permanent boost!",
	"Better frogs give more Hops per pad!",
	"Claim your Daily Reward every day for a limited frog!",
	"Play with friends for +10% Hops each!",
}
local INTERVAL = 8

function TipTicker.init(gui: ScreenGui)
	local box = Theme.new("Frame", {
		Name = "TipTicker",
		Size = UDim2.fromOffset(800, 54),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 14),
		BackgroundColor3 = Color3.fromRGB(18, 18, 24),
		BackgroundTransparency = 0.3,
		Parent = gui,
	}, { Theme.corner(8), Theme.stroke(2, Color3.fromRGB(70, 70, 80)) })
	local label = Theme.label({
		Size = UDim2.new(1, -30, 0.74, 0),
		Position = UDim2.fromScale(0, 0.13),
		AnchorPoint = Vector2.new(0, 0),
		Text = TIPS[1],
		TextColor3 = Color3.new(1, 1, 1),
		Parent = box,
	})
	label.Position = UDim2.new(0, 15, 0.13, 0)
	local gradient = Gradient.apply(label, "Rainbow")
	label.BackgroundTransparency = 1
	task.spawn(function()
		local i = 1
		while box.Parent do
			-- Slide the rainbow across the text.
			for step = 0, INTERVAL * 10 do
				gradient.Offset = Vector2.new(math.sin(step / 10) * 0.3, 0)
				task.wait(0.1)
			end
			i = i % #TIPS + 1
			label.Text = TIPS[i]
		end
	end)
end

return TipTicker
