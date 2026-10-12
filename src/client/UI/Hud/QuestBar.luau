-- Top-centre tutorial bar (reference): "TUTORIAL" tag over the current
-- quest with its progress, e.g. "Hop down the river: get Wins (1/2)".

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Format = require(ReplicatedStorage:WaitForChild("Shared").Util.Format)
local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Components.Gradient)
local State = require(script.Parent.Parent.Parent.State)

local new = Theme.new

local QuestBar = {}

function QuestBar.init(gui: ScreenGui)
	local bar = new("Frame", {
		Name = "QuestBar",
		Size = UDim2.fromOffset(640, 64),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 118),
		Visible = false,
		Parent = gui,
	}, { Theme.corner(12), Theme.stroke(4) })
	Gradient.apply(bar, "Yellow")
	local tag = Theme.label({
		Size = UDim2.fromOffset(160, 26),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0),
		Text = "TUTORIAL",
		TextColor3 = Color3.fromRGB(255, 240, 150),
		Parent = bar,
	})
	Theme.textStroke().Parent = tag
	local text = Theme.label({
		Size = UDim2.new(1, -24, 0.7, 0),
		Position = UDim2.new(0, 12, 0.2, 0),
		Text = "",
		Parent = bar,
	})

	State.observe(function(data)
		local quest = data.quest
		bar.Visible = quest ~= nil
		if quest then
			text.Text = `{quest.text} ({Format.abbreviate(quest.progress)}/{Format.abbreviate(quest.target)})`
		end
	end)
end

return QuestBar
