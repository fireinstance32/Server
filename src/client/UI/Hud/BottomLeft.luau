-- Bottom-left counters: Rebirths, Wins and Friend Boost (+ invite button).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")

local Format = require(ReplicatedStorage:WaitForChild("Shared").Util.Format)
local Theme = require(script.Parent.Parent.Theme)
local State = require(script.Parent.Parent.Parent.State)
local Icon = require(script.Parent.Parent.Components.Icon)
local CountUp = require(script.Parent.Parent.Components.CountUp)

local new = Theme.new

local BottomLeft = {}

local function counter(parent: Frame, order: number, icon: string): TextLabel
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, 74),
		BackgroundTransparency = 1,
		LayoutOrder = order,
		Parent = parent,
	})
	Icon.new(icon, { Size = UDim2.fromOffset(72, 72), Position = UDim2.fromOffset(0, 0), Parent = row })
	return Theme.label({
		Size = UDim2.new(1, -90, 0, 54),
		Position = UDim2.fromOffset(88, 10),
		Text = "0",
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})
end

function BottomLeft.init(gui: ScreenGui)
	local frame = new("Frame", {
		Name = "BottomLeft",
		Size = UDim2.fromOffset(300, 196),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 110, 1, -40),
		BackgroundTransparency = 1,
		Parent = gui,
	}, { new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }) })

	local rebirths = counter(frame, 1, "rebirth")
	local wins = counter(frame, 2, "trophy")

	local friendRow = new("Frame", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundTransparency = 1,
		LayoutOrder = 3,
		Parent = frame,
	})
	local friend = Theme.label({
		Size = UDim2.new(1, -54, 1, 0),
		Text = "Friend Boost +0%",
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = friendRow,
	})
	local invite = new("TextButton", {
		Name = "Invite",
		Size = UDim2.fromOffset(44, 44),
		Position = UDim2.new(1, -46, 0, -2),
		BackgroundTransparency = 1,
		Text = "",
		Parent = friendRow,
	})
	Icon.new("plus", { Size = UDim2.fromScale(1, 1), Parent = invite })
	invite.Activated:Connect(function()
		pcall(SocialService.PromptGameInvite, SocialService, Players.LocalPlayer)
	end)

	local setWins = CountUp.bind(wins, Format.abbreviate)
	State.observe(function(data)
		rebirths.Text = Format.abbreviate(data.rebirths)
		setWins(data.wins)
		friend.Text = `Friend Boost +{math.floor((data.friendBoost or 0) * 100)}%`
	end)
end

return BottomLeft
