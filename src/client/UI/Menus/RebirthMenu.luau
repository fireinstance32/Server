-- Rebirth: level progress toward the cap and the rebirth button.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)
local Format = require(Shared.Util.Format)
local Net = require(Shared.Net)

local Theme = require(script.Parent.Parent.Theme)
local Window = require(script.Parent.Window)

local new = Theme.new
local C = Theme.Colors

local RebirthMenu = {}

function RebirthMenu.build(body: Frame)
	Theme.label({
		Size = UDim2.new(1, 0, 0, 60),
		Text = "Reach MAX LEVEL to rebirth. Resets Hops, Wins and Level.\nYou keep your frogs and pets!",
		TextColor3 = C.Ink,
		Parent = body,
	})
	local reward = Theme.label({
		Size = UDim2.new(1, 0, 0, 40),
		Position = UDim2.fromOffset(0, 70),
		Text = "",
		TextColor3 = C.Purple,
		Parent = body,
	})
	local barBack = new("Frame", {
		Size = UDim2.new(0.9, 0, 0, 36),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 124),
		BackgroundColor3 = C.Grey,
		Parent = body,
	}, { Theme.corner(18), Theme.stroke(3) })
	local barFill = new("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = C.Purple,
		Parent = barBack,
	}, { Theme.corner(18) })
	local barText = Theme.label({
		Size = UDim2.new(1, 0, 1, -8),
		Position = UDim2.fromOffset(0, 4),
		Text = "",
		ZIndex = 2,
		Parent = barBack,
	})
	local button = Theme.button({
		Size = UDim2.fromOffset(240, 70),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 180),
		Text = "REBIRTH",
		Color = C.Purple,
	}, function()
		Window.report(Net.func("Rebirth"):InvokeServer())
	end)
	button.Parent = body

	return function(data)
		local nextBonus = 1 + (data.rebirths + 1) * Game.RebirthHopsBonus
		reward.Text = `Next rebirth: Hops {Format.multiplier(nextBonus)} forever`
		local progress = math.clamp(data.level / data.levelCap, 0, 1)
		barFill.Size = UDim2.fromScale(progress, 1)
		barText.Text = `Level {data.level} / {data.levelCap}`
		button.BackgroundColor3 = if progress >= 1 then C.Purple else C.Grey
	end
end

return RebirthMenu
