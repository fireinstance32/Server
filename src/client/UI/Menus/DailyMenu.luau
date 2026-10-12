-- Daily Rewards calendar (reference): Days 1–6 in a grid, Day 7 big on the
-- right. Each card: orange "DAY N" tab, reward name, reward picture; claimed
-- days dimmed and ticked, today's card outlined green (click it to claim);
-- hover shows a white info card; the countdown sits under the window.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local DailyRewards = require(Shared.Config.DailyRewards)
local Net = require(Shared.Net)
local Format = require(Shared.Util.Format)

local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Components.Gradient)
local Studs = require(script.Parent.Parent.Components.Studs)
local RewardIcon = require(script.Parent.Parent.Components.RewardIcon)
local Icon = require(script.Parent.Parent.Components.Icon)
local RewardTooltip = require(script.Parent.Parent.Components.RewardTooltip)
local Rays = require(script.Parent.Parent.Components.Rays)
local Window = require(script.Parent.Window)
local Hud = require(script.Parent.Parent.Hud)

local new = Theme.new

local DailyMenu = {}

-- Pixel layout measured from the reference (1026×695 window, 998-wide body).
local CARD = Vector2.new(232, 273)
local BIG = Vector2.new(260, 635)

local function dayTab(card: GuiObject, day: number, big: boolean)
	local tab = new("Frame", {
		Name = "DayTab",
		Size = if big then UDim2.fromOffset(207, 100) else UDim2.fromOffset(183, 80),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, if big then 3 else -4),
		ZIndex = 3,
		Parent = card,
	}, { Theme.corner(10), Theme.stroke(3) })
	Gradient.apply(tab, if big then "Rainbow" else "Orange")
	Theme.label({ Size = UDim2.fromScale(0.9, 0.8), Position = UDim2.fromScale(0.05, 0.1), Text = `DAY {day}`, ZIndex = 4, Parent = tab })
end

local function capped(label: TextLabel, max: number): TextLabel
	new("UITextSizeConstraint", { MaxTextSize = max, Parent = label })
	return label
end

-- Seconds until the next UTC day (when the next reward unlocks).
local function untilTomorrow(): number
	return 86400 - math.floor(Workspace:GetServerTimeNow()) % 86400
end

function DailyMenu.build(body: Frame)
	local days = {}
	local lastStatus = nil
	local count = #DailyRewards.Days
	local function claim()
		local day = lastStatus and lastStatus.day
		local ok, message = Net.func("ClaimDaily"):InvokeServer()
		local reward = ok and day and DailyRewards.Days[day]
		if reward then
			Hud.reward(reward, reward.label)
		else
			Window.report(ok, message)
		end
	end
	for i, reward in DailyRewards.Days do
		local isBig = i == count
		local size = if isBig then BIG else CARD
		local card = new("TextButton", {
			Name = `Day{i}`,
			Size = UDim2.fromOffset(size.X, size.Y),
			Position = if isBig
				then UDim2.fromOffset(739, 11)
				else UDim2.fromOffset(9 + ((i - 1) % 3) * 246, if i <= 3 then 29 else 349),
			Text = "",
			AutoButtonColor = false,
			Parent = body,
		}, { Theme.corner(12), Theme.stroke(3) })
		local gradient = Gradient.apply(card, if isBig then "Rainbow" else "Yellow")
		Studs.apply(card, 22)
		if isBig then
			gradient.Rotation = -90 -- reference: violet at the top → red at the bottom
			Rays.new({
				Size = UDim2.fromOffset(250, 250),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0, 328),
				Parent = card,
			})
		end
		dayTab(card, i, isBig)
		if isBig then
			local limited = capped(Theme.label({
				Size = UDim2.new(0.92, 0, 0, 62),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0, 131),
				Text = "Limited!",
				ZIndex = 2,
				Parent = card,
			}), 56)
			Gradient.apply(limited, "Rainbow")
		end
		RewardIcon.new(reward, {
			Size = if isBig then UDim2.fromOffset(230, 230) else UDim2.fromOffset(130, 130),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0, if isBig then 328 else 190),
			ZIndex = 2,
			Parent = card,
		})
		capped(Theme.label({
			Size = if isBig then UDim2.new(0.94, 0, 0, 92) else UDim2.new(0.94, 0, 0, 76),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, if isBig then 488 else 40),
			Text = string.upper(if isBig then string.gsub(reward.label, " %(.*%)", "") else reward.label),
			TextWrapped = true,
			ZIndex = 2,
			Parent = card,
		}), if isBig then 44 else 36)
		local claimed = new("Frame", {
			Name = "Claimed",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.45,
			Visible = false,
			ZIndex = 5,
			Parent = card,
		}, { Theme.corner(12) })
		Icon.new("check", {
			Size = UDim2.fromOffset(190, 170),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0, 105),
			ZIndex = 6,
			Parent = claimed,
		})
		RewardTooltip.attach(card, reward)
		card.Activated:Connect(function()
			if lastStatus and lastStatus.canClaim and lastStatus.day == i then
				claim()
			end
		end)
		days[i] = { card = card, claimed = claimed }
	end

	-- Under the window, like the reference: green countdown / claim prompt.
	local next = Theme.label({
		Size = UDim2.fromOffset(760, 64),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 1, 22),
		Text = "",
		TextColor3 = Color3.fromRGB(120, 255, 40),
		Parent = body.Parent,
	})
	Theme.textStroke().Parent = next

	local function tick()
		if lastStatus and lastStatus.canClaim then
			next.Text = `Claim Day {lastStatus.day}!`
		else
			next.Text = `Next reward in: {Format.clock(untilTomorrow())}`
		end
	end
	local alive = true
	body.Destroying:Connect(function()
		alive = false
	end)
	task.spawn(function()
		while alive and body.Parent do
			tick()
			task.wait(1)
		end
	end)

	return function(data)
		local status = data.daily or { canClaim = false, day = 1, streak = 0 }
		lastStatus = status
		for i, entry in days do
			entry.claimed.Visible = if status.canClaim then i < status.day else i <= status.day
			local stroke = entry.card:FindFirstChildOfClass("UIStroke")
			if stroke then
				local today = i == status.day and status.canClaim
				stroke.Color = if today then Color3.fromRGB(90, 255, 90) else Theme.Colors.Outline
				stroke.Thickness = if today then 6 else 3
			end
		end
		tick()
	end
end

return DailyMenu
