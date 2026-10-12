-- Playtime gifts: 10 cards with a countdown, CLAIM when ready, ✅ when taken.

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

local GiftsMenu = {}

local function clock(seconds: number): string
	return string.format("%02d:%02d", seconds // 60, seconds % 60)
end

-- Seconds this session has run, using the server clock.
function GiftsMenu.elapsed(): number
	local start = Players.LocalPlayer:GetAttribute("SessionStart")
	return if typeof(start) == "number" then math.max(math.floor(Workspace:GetServerTimeNow() - start), 0) else 0
end

function GiftsMenu.build(body: Frame)
	local header = Theme.label({
		Size = UDim2.new(1, -120, 0, 32),
		Position = UDim2.fromOffset(120, 0),
		Text = "Keep playing to open more gifts!",
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = body,
	})
	header:FindFirstChildOfClass("UIStroke").Thickness = 3
	local panel = Window.inset(body, { Size = UDim2.new(1, 0, 1, -40), Position = UDim2.fromOffset(0, 40) })
	local grid = Window.grid(panel, 150, 184)
	local buttons = {}
	for i, gift in Gifts.List do
		local card = Theme.new("Frame", { Name = `Gift{i}`, LayoutOrder = i, Parent = grid }, {
			Theme.corner(14),
			Theme.stroke(3, Color3.fromRGB(150, 152, 162)),
		})
		Gradient.apply(card, { Color3.fromRGB(116, 117, 126), Color3.fromRGB(70, 71, 80) })
		RewardIcon.new(gift.reward, {
			Size = UDim2.fromOffset(78, 70),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 4),
			Parent = card,
		})
		Theme.label({ Size = UDim2.new(1, -10, 0, 28), Position = UDim2.fromOffset(5, 76), Text = gift.label, Parent = card })
		local button = Window.button({
			Size = UDim2.new(1, -20, 0, 44),
			Position = UDim2.new(0, 10, 1, -54),
			Text = "",
		}, "Grey", function()
			local ok, message = Net.func("ClaimGift"):InvokeServer(i)
			if ok then
				Hud.reward(gift.reward, gift.label)
			else
				Window.report(ok, message)
			end
		end)
		button.Parent = card
		buttons[i] = button
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
			if claimed[i] then
				Theme.setText(button, "CLAIMED")
				Window.recolor(button, "Grey")
			elseif Gifts.isReady(i, elapsed) then
				Theme.setText(button, "CLAIM")
				Window.recolor(button, "Green")
			else
				Theme.setText(button, clock(gift.minutes * 60 - elapsed))
				Window.recolor(button, "Grey")
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
