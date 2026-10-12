-- Playtime gifts: a card per gift with a countdown, CLAIM when ready, ✅ when taken.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Gifts = require(Shared.Config.Gifts)
local Net = require(Shared.Net)

local Theme = require(script.Parent.Parent.Theme)
local Window = require(script.Parent.Window)
local Hud = require(script.Parent.Parent.Hud)
local Gradient = require(script.Parent.Parent.Components.Gradient)
local RewardIcon = require(script.Parent.Parent.Components.RewardIcon)
local Studs = require(script.Parent.Parent.Components.Studs)
local Icon = require(script.Parent.Parent.Components.Icon)

local GiftsMenu = {}

local function clock(seconds: number): string
	return string.format("%02d:%02d", seconds // 60, seconds % 60)
end

-- Seconds this session has run, using the server clock.
function GiftsMenu.elapsed(): number
	local start = Players.LocalPlayer:GetAttribute("SessionStart")
	return if typeof(start) == "number" then math.max(math.floor(Workspace:GetServerTimeNow() - start), 0) else 0
end

-- Card colours from the reference: orange = still counting down, purple =
-- ready, blue = claimed; the last (best) gift is rainbow until claimed.
local function cardColor(i: number, claimed: boolean, ready: boolean): string
	if claimed then
		return "Blue"
	elseif ready then
		return "Purple"
	end
	return if i == #Gifts.List then "Rainbow" else "Orange"
end

-- Reference layout: 4 × 3 cards of 207×195 filling the window, no header.
function GiftsMenu.build(body: Frame)
	local holder = Theme.new("Frame", {
		Size = UDim2.new(1, 0, 1, -28),
		Position = UDim2.fromOffset(0, 28), -- clear of the corner icon
		BackgroundTransparency = 1,
		Parent = body,
	})
	local grid = Window.grid(holder, 207, 195, 12)
	grid:FindFirstChildOfClass("UIGridLayout").HorizontalAlignment = Enum.HorizontalAlignment.Center
	local cards, buttons, checks = {}, {}, {}
	for i, gift in Gifts.List do
		local card = Theme.new("Frame", { Name = `Gift{i}`, LayoutOrder = i, Parent = grid }, {
			Theme.corner(10),
			Theme.stroke(3),
		})
		Studs.apply(card, 22, 0.5)
		RewardIcon.new(gift.reward, {
			Size = UDim2.fromOffset(100, 90),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 4),
			Parent = card,
		})
		Theme.label({ Size = UDim2.new(1, -12, 0, 34), Position = UDim2.fromOffset(6, 92), Text = gift.label, Parent = card })
		local button = Window.button({
			Size = UDim2.new(1, -20, 0, 52),
			Position = UDim2.new(0, 10, 1, -60),
			Text = "",
		}, "Red", function()
			local ok, message = Net.func("ClaimGift"):InvokeServer(i)
			if ok then
				Hud.reward(gift.reward, gift.label)
			else
				Window.report(ok, message)
			end
		end)
		button.Parent = card
		checks[i] = Icon.new("check", {
			Size = UDim2.fromOffset(56, 56),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -6),
			Visible = false,
			Parent = card,
		})
		cards[i], buttons[i] = card, button
	end

	local alive = true
	body.Destroying:Connect(function()
		alive = false
	end)
	local function refresh()
		local elapsed = GiftsMenu.elapsed()
		local claimed = Gifts.parseClaimed(Players.LocalPlayer:GetAttribute("GiftsClaimed"))
		for i, gift in Gifts.List do
			local button = buttons[i]
			local ready = Gifts.isReady(i, elapsed)
			Gradient.apply(cards[i], cardColor(i, claimed[i] == true, ready))
			button.Visible = not claimed[i]
			checks[i].Visible = claimed[i] == true
			if ready then
				Theme.setText(button, "CLAIM")
				Window.recolor(button, "Green")
			else
				Theme.setText(button, clock(gift.minutes * 60 - elapsed))
				Window.recolor(button, "Red")
			end
		end
	end
	task.spawn(function()
		while alive and body.Parent do
			refresh()
			task.wait(1)
		end
	end)
	return refresh
end

return GiftsMenu
