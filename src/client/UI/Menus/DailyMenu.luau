-- Daily Rewards calendar (reference): Days 1–6 in a grid, Day 7 big on the
-- right. Each card: orange "DAY N" tab, reward name, reward picture; claimed
-- days dimmed, today's card outlined green; Claim button underneath.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local DailyRewards = require(Shared.Config.DailyRewards)
local Net = require(Shared.Net)

local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Components.Gradient)
local Studs = require(script.Parent.Parent.Components.Studs)
local RewardIcon = require(script.Parent.Parent.Components.RewardIcon)
local Window = require(script.Parent.Window)

local new = Theme.new

local DailyMenu = {}

local function dayTab(card: Frame, day: number, rainbow: boolean)
	local tab = new("Frame", {
		Name = "DayTab",
		Size = UDim2.new(0.78, 0, 0, 44),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, 4),
		ZIndex = 3,
		Parent = card,
	}, { Theme.corner(10), Theme.stroke(3) })
	Gradient.apply(tab, if rainbow then "Rainbow" else { Color3.fromRGB(255, 180, 60), Color3.fromRGB(240, 130, 20) })
	Theme.label({ Size = UDim2.fromScale(0.9, 0.86), Position = UDim2.fromScale(0.05, 0.07), Text = `DAY {day}`, ZIndex = 4, Parent = tab })
end

function DailyMenu.build(body: Frame)
	local days = {}
	local count = #DailyRewards.Days
	for i, reward in DailyRewards.Days do
		local isBig = i == count
		local card = new("Frame", {
			Size = if isBig then UDim2.new(0.24, 0, 1, -94) else UDim2.new(0.235, 0, 0.5, -58),
			Position = if isBig
				then UDim2.new(0.76, 0, 0, 14)
				else UDim2.new(((i - 1) % 3) * 0.25, 0, if i <= 3 then 0 else 0.5, if i <= 3 then 14 else -22),
			Parent = body,
		}, { Theme.corner(12), Theme.stroke(3) })
		Gradient.apply(card, if isBig then "Rainbow" else "Yellow")
		Studs.apply(card, 22, 0.45)
		dayTab(card, i, isBig)
		if isBig then
			local limited = Theme.label({
				Size = UDim2.new(0.9, 0, 0, 40),
				Position = UDim2.new(0.05, 0, 0, 34),
				Text = "Limited!",
				ZIndex = 2,
				Parent = card,
			})
			Gradient.apply(limited, "Rainbow")
		end
		RewardIcon.new(reward, {
			Size = if isBig then UDim2.fromScale(0.9, 0.42) else UDim2.fromScale(0.62, 0.52),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = if isBig then UDim2.fromScale(0.5, 0.46) else UDim2.fromScale(0.5, 0.6),
			ZIndex = 2,
			Parent = card,
		})
		Theme.label({
			Size = if isBig then UDim2.new(0.94, 0, 0, 70) else UDim2.new(0.94, 0, 0, 26),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = if isBig then UDim2.new(0.5, 0, 0.72, 0) else UDim2.new(0.5, 0, 0, 28),
			Text = string.upper(reward.label),
			TextWrapped = isBig,
			ZIndex = 2,
			Parent = card,
		})
		local claimed = new("Frame", {
			Name = "Claimed",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.45,
			Visible = false,
			ZIndex = 5,
			Parent = card,
		}, { Theme.corner(12) })
		Theme.label({ Size = UDim2.fromScale(0.86, 0.22), Position = UDim2.fromScale(0.07, 0.4), Text = "CLAIMED", ZIndex = 6, Parent = claimed })
		days[i] = { card = card, claimed = claimed }
	end

	local claim = Window.button({
		Size = UDim2.fromOffset(380, 66),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 0),
		Text = "CLAIM YOUR REWARD",
	}, "Green", function()
		Window.report(Net.func("ClaimDaily"):InvokeServer())
	end)
	claim.Parent = body

	return function(data)
		local status = data.daily or { canClaim = false, day = 1, streak = 0 }
		for i, entry in days do
			entry.claimed.Visible = if status.canClaim then i < status.day else i <= status.day
			local stroke = entry.card:FindFirstChildOfClass("UIStroke")
			if stroke then
				local today = i == status.day and status.canClaim
				stroke.Color = if today then Color3.fromRGB(90, 255, 90) else Theme.Colors.Outline
				stroke.Thickness = if today then 6 else 3
			end
		end
		Theme.setText(claim, if status.canClaim then "CLAIM YOUR REWARD" else "Come back tomorrow!")
		Gradient.apply(claim, if status.canClaim then "Green" else "Grey")
	end
end

return DailyMenu
