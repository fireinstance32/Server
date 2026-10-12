-- Playtime gifts: 10 cards with a countdown, CLAIM when ready, ✅ when taken.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Gifts = require(Shared.Config.Gifts)
local Net = require(Shared.Net)

local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Components.Gradient)
local Window = require(script.Parent.Window)

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
	local grid = Window.grid(body, 150, 170)
	local buttons = {}
	for i, gift in Gifts.List do
		local card = Window.card(grid, i)
		Theme.label({ Size = UDim2.new(1, 0, 0, 56), Position = UDim2.fromOffset(0, 6), Text = gift.icon, Parent = card })
		Theme.label({ Size = UDim2.new(1, -10, 0, 28), Position = UDim2.fromOffset(5, 64), Text = gift.label, Parent = card })
		local button = Window.button({
			Size = UDim2.new(1, -20, 0, 44),
			Position = UDim2.new(0, 10, 1, -54),
			Text = "",
		}, "Grey", function()
			Window.report(Net.func("ClaimGift"):InvokeServer(i))
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
				button.Text = "✅"
				Gradient.apply(button, "Grey")
			elseif Gifts.isReady(i, elapsed) then
				button.Text = "CLAIM"
				Gradient.apply(button, "Green")
			else
				button.Text = clock(gift.minutes * 60 - elapsed)
				Gradient.apply(button, "Grey")
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
