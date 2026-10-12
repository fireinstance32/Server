-- Playtime Rewards (reference, same name): 12 cards in 3 rows — blue,
-- purple, orange, and a rainbow last one. Each counts down, then says Claim;
-- claimed ones go dark with a tick. Positions are reference pixels.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Gifts = require(Shared.Config.Gifts)
local Net = require(Shared.Net)

local Window = require(script.Parent.Window)
local Hud = require(script.Parent.Parent.Hud)
local Card = require(script.Card)

local GiftsMenu = {}

local COLUMNS = 4
local PITCH = Vector2.new(218, 206)
-- First card's top-left inside the window (27, 50), as an offset from the
-- window body (which starts at 14, 56).
local ORIGIN = Vector2.new(27 - 14, 50 - 56)

local function tier(i: number): string
	if i == #Gifts.List then
		return "Rainbow"
	end
	return ({ "Blue", "Purple", "Orange" })[math.min((i - 1) // COLUMNS + 1, 3)]
end

-- Seconds this session has run, using the server clock.
function GiftsMenu.elapsed(): number
	local start = Players.LocalPlayer:GetAttribute("SessionStart")
	return if typeof(start) == "number" then math.max(math.floor(Workspace:GetServerTimeNow() - start), 0) else 0
end

function GiftsMenu.build(body: Frame)
	local cards = {}
	for i, gift in Gifts.List do
		local col, row = (i - 1) % COLUMNS, (i - 1) // COLUMNS
		local position = UDim2.fromOffset(ORIGIN.X + col * PITCH.X, ORIGIN.Y + row * PITCH.Y)
		cards[i] = Card.new(body, position, tier(i), gift, function()
			local ok, message = Net.func("ClaimGift"):InvokeServer(i)
			if ok then
				Hud.reward(gift.reward, gift.label)
			elseif message then
				Window.report(ok, message)
			end
		end)
	end

	local alive = true
	body.Destroying:Connect(function()
		alive = false
	end)
	local function refresh()
		local elapsed = GiftsMenu.elapsed()
		local claimed = Gifts.parseClaimed(Players.LocalPlayer:GetAttribute("GiftsClaimed"))
		for i, gift in Gifts.List do
			local state = if claimed[i] then "claimed" elseif Gifts.isReady(i, elapsed) then "ready" else "waiting"
			cards[i].set(state, gift.minutes * 60 - elapsed)
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
