-- Rainbow tip line at the very top (reference: "You'll still train offline
-- even if you log out"). Cycles through tips every few seconds.

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
	local label = Theme.label({
		Name = "TipTicker",
		Size = UDim2.fromOffset(620, 26),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 208), -- under the tutorial bar
		Text = TIPS[1],
		TextColor3 = Color3.new(1, 1, 1),
		Parent = gui,
	})
	local gradient = Gradient.apply(label, "Rainbow")
	label.BackgroundTransparency = 1
	task.spawn(function()
		local i = 1
		while label.Parent do
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
