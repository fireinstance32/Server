-- Gold beam from the player to the current quest's target (reference:
-- arrows on the ground pointing to the objective). Hidden when close.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Quests = require(ReplicatedStorage:WaitForChild("Shared").Config.Quests)

local State = require(script.Parent.Parent.State)

local QuestGuide = {}

local HIDE_WITHIN = 12

function QuestGuide.init()
	local player = Players.LocalPlayer
	local target = Instance.new("Part")
	target.Name = "QuestTarget"
	target.Anchored = true
	target.CanCollide = false
	target.CanQuery = false
	target.Transparency = 1
	target.Size = Vector3.one
	target.Parent = Workspace
	local targetAttachment = Instance.new("Attachment")
	targetAttachment.Parent = target

	local beam = Instance.new("Beam")
	beam.Attachment1 = targetAttachment
	beam.Color = ColorSequence.new(Color3.fromRGB(255, 220, 60))
	beam.Width0 = 1.2
	beam.Width1 = 1.2
	beam.FaceCamera = true
	beam.LightEmission = 0.6
	beam.Transparency = NumberSequence.new(0.2)
	beam.Segments = 20
	beam.CurveSize0 = 6
	beam.Enabled = false
	beam.Parent = target

	local goal: Vector3? = nil
	State.observe(function(data)
		local quest = data.quest and Quests.List[data.quest.step]
		goal = if quest and quest.where then quest.where() else nil
		if goal then
			target.Position = goal + Vector3.new(0, 3, 0)
		end
	end)

	local rootAttachment: Attachment? = nil
	RunService.Heartbeat:Connect(function()
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if root and (not rootAttachment or rootAttachment.Parent ~= root) then
			rootAttachment = Instance.new("Attachment")
			rootAttachment.Name = "QuestGuide"
			rootAttachment.Parent = root
			beam.Attachment0 = rootAttachment
		end
		beam.Enabled = goal ~= nil and root ~= nil and (root.Position - (goal :: Vector3)).Magnitude > HIDE_WITHIN
	end)
end

return QuestGuide
