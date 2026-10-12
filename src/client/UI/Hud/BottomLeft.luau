-- Bottom-left counters: Rebirths, Wins and Friend Boost (+ invite button).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")

local Format = require(ReplicatedStorage:WaitForChild("Shared").Util.Format)
local Theme = require(script.Parent.Parent.Theme)
local State = require(script.Parent.Parent.Parent.State)

local new = Theme.new
local C = Theme.Colors

local BottomLeft = {}

local function counter(parent: Frame, order: number, icon: string): TextLabel
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundTransparency = 1,
		LayoutOrder = order,
		Parent = parent,
	})
	Theme.label({ Size = UDim2.fromOffset(56, 56), Text = icon, Parent = row })
	return Theme.label({
		Size = UDim2.new(1, -66, 0, 48),
		Position = UDim2.fromOffset(66, 4),
		Text = "0",
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})
end

function BottomLeft.init(gui: ScreenGui)
	local frame = new("Frame", {
		Name = "BottomLeft",
		Size = UDim2.fromOffset(280, 170),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 20, 1, -16),
		BackgroundTransparency = 1,
		Parent = gui,
	}, { new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }) })

	local rebirths = counter(frame, 1, "🔁")
	local wins = counter(frame, 2, "🏆")

	local friendRow = new("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		LayoutOrder = 3,
		Parent = frame,
	})
	local friend = Theme.label({
		Size = UDim2.new(1, -44, 1, 0),
		Text = "Friend Boost +0%",
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = friendRow,
	})
	local invite = Theme.button({
		Size = UDim2.fromOffset(36, 36),
		Position = UDim2.new(1, -36, 0, 0),
		Text = "+",
		Color = C.Green,
	}, function()
		pcall(SocialService.PromptGameInvite, SocialService, Players.LocalPlayer)
	end)
	invite.Parent = friendRow

	State.observe(function(data)
		rebirths.Text = Format.abbreviate(data.rebirths)
		wins.Text = Format.abbreviate(data.wins)
		friend.Text = `Friend Boost +{math.floor((data.friendBoost or 0) * 100)}%`
	end)
end

return BottomLeft
