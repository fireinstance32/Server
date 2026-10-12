-- Wide Level bar: "Level 13" left, "5 / 10" right; gold at MAX LEVEL.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Format = require(ReplicatedStorage:WaitForChild("Shared").Util.Format)
local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Components.Gradient)
local Studs = require(script.Parent.Parent.Components.Studs)
local State = require(script.Parent.Parent.Parent.State)

local new = Theme.new

local LevelBar = {}

function LevelBar.init(parent: Frame, y: number, height: number)
	local bar = new("Frame", {
		Name = "LevelBar",
		Size = UDim2.new(1, 0, 0, height),
		Position = UDim2.fromOffset(0, y),
		ClipsDescendants = true,
		Parent = parent,
	}, { Theme.corner(12), Theme.stroke(4) })
	Gradient.apply(bar, "Silver")
	Studs.apply(bar, 24)

	local fill = new("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(0, 1),
		Parent = bar,
	}, { Theme.corner(12) })
	Gradient.apply(fill, "Blue")
	Studs.apply(fill, 24)

	local level = Theme.label({
		Size = UDim2.new(0.6, -20, 0.7, 0),
		Position = UDim2.new(0, 20, 0.15, 0),
		Text = "Level 1",
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2,
		Parent = bar,
	})
	local progress = Theme.label({
		Size = UDim2.new(0.4, -20, 0.6, 0),
		Position = UDim2.new(0.6, 0, 0.2, 0),
		Text = "0 / 10",
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 2,
		Parent = bar,
	})

	State.observe(function(data)
		local maxed = data.level >= data.levelCap
		local ratio = if maxed then 1 else math.clamp(data.xp / data.xpToNext, 0, 1)
		TweenService:Create(fill, TweenInfo.new(0.25), { Size = UDim2.fromScale(ratio, 1) }):Play()
		Gradient.apply(fill, if maxed then "Yellow" else "Blue")
		level.Text = `Level {data.level}`
		progress.Text = if maxed
			then "MAX LEVEL"
			else `{Format.abbreviate(data.xp)} / {Format.abbreviate(data.xpToNext)}`
	end)
end

return LevelBar
