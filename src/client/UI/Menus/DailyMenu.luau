-- Daily Rewards calendar (reference): Days 1–6 in a grid, Day 7 big on the
-- right; claimed days ticked, today's day highlighted with a Claim button.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local DailyRewards = require(Shared.Config.DailyRewards)
local Net = require(Shared.Net)

local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Components.Gradient)
local Window = require(script.Parent.Window)

local new = Theme.new

local DailyMenu = {}

local ICONS = { potion = "🧪", pet = "🐱", frog = "🌠", wins = "🏆", hops = "🐸" }

function DailyMenu.build(body: Frame)
	local days = {}
	for i, reward in DailyRewards.Days do
		local isBig = i == #DailyRewards.Days
		local card = new("Frame", {
			Size = if isBig then UDim2.new(0.24, 0, 1, -80) else UDim2.new(0.235, 0, 0.5, -46),
			Position = if isBig
				then UDim2.new(0.76, 0, 0, 0)
				else UDim2.new(((i - 1) % 3) * 0.25, 0, if i <= 3 then 0 else 0.5, if i <= 3 then 0 else -36),
			Parent = body,
		}, { Theme.corner(12), Theme.stroke(3) })
		Gradient.apply(card, if isBig then "Rainbow" else "Yellow")
		Theme.label({ Size = UDim2.new(1, 0, 0, 34), Position = UDim2.fromOffset(0, 6), Text = `DAY {i}`, Parent = card })
		Theme.label({ Size = UDim2.new(1, 0, 0.4, 0), Position = UDim2.fromScale(0, 0.25), Text = ICONS[reward.kind] or "🎁", Parent = card })
		Theme.label({
			Size = UDim2.new(0.94, 0, 0, 40),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -6),
			Text = reward.label,
			Parent = card,
		})
		local tick = Theme.label({ Size = UDim2.fromOffset(40, 40), Position = UDim2.new(1, -44, 0, 4), Text = "✅", Visible = false, Parent = card })
		days[i] = { card = card, tick = tick }
	end

	local claim = Window.button({
		Size = UDim2.fromOffset(300, 64),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.38, 0, 1, 0),
		Text = "CLAIM YOUR REWARD",
	}, "Green", function()
		Window.report(Net.func("ClaimDaily"):InvokeServer())
	end)
	claim.Parent = body

	return function(data)
		local status = data.daily or { canClaim = false, day = 1, streak = 0 }
		for i, entry in days do
			local claimed = if status.canClaim then i < status.day else i <= status.day
			entry.tick.Visible = claimed
			local stroke = entry.card:FindFirstChildOfClass("UIStroke")
			if stroke then
				stroke.Color = if i == status.day and status.canClaim then Color3.fromRGB(80, 255, 80) else Color3.fromRGB(35, 45, 35)
				stroke.Thickness = if i == status.day and status.canClaim then 6 else 3
			end
		end
		claim.Text = if status.canClaim then "CLAIM YOUR REWARD" else "Come back tomorrow!"
		Gradient.apply(claim, if status.canClaim then "Green" else "Grey")
	end
end

return DailyMenu
