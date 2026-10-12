-- Level progress bar above the HOP button; turns gold at MAX LEVEL.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Format = require(ReplicatedStorage:WaitForChild("Shared").Util.Format)
local Theme = require(script.Parent.Parent.Theme)
local State = require(script.Parent.Parent.Parent.State)

local new = Theme.new
local C = Theme.Colors

local LevelBar = {}

function LevelBar.init(gui: ScreenGui)
	local bar = new("Frame", {
		Size = UDim2.fromOffset(380, 38),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -126),
		BackgroundColor3 = Color3.fromRGB(235, 235, 235),
		Parent = gui,
	}, { Theme.corner(12), Theme.stroke(3) })
	local fill = new("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = C.Blue,
		Parent = bar,
	}, { Theme.corner(12) })
	local text = Theme.label({
		Size = UDim2.new(1, -24, 1, -8),
		Position = UDim2.fromOffset(12, 4),
		Text = "Level 1",
		ZIndex = 2,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = bar,
	})

	State.observe(function(data)
		local maxed = data.level >= data.levelCap
		local progress = if maxed then 1 else math.clamp(data.xp / data.xpToNext, 0, 1)
		TweenService:Create(fill, TweenInfo.new(0.25), { Size = UDim2.fromScale(progress, 1) }):Play()
		fill.BackgroundColor3 = if maxed then C.Gold else C.Blue
		text.Text = if maxed
			then `Level {data.level}   MAX LEVEL – Rebirth!`
			else `Level {data.level}   {Format.abbreviate(data.xp)} / {Format.abbreviate(data.xpToNext)}`
	end)
end

return LevelBar
