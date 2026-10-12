-- The hold-and-toss: turns the character to face the river, winds the right
-- arm back, then swings it forward. Procedural (moves the shoulder joint) so
-- it needs no animation asset; Phase 6 can swap in a real animation.
-- Local-only for now: other players see the frog leave the hand, not the swing.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Game = require(ReplicatedStorage:WaitForChild("Shared").Config.Game)

local TossAnimation = {}

local function shoulder(character: Model): Motor6D?
	local r15 = character:FindFirstChild("RightUpperArm")
	local joint = r15 and r15:FindFirstChild("RightShoulder")
	if not joint then
		local torso = character:FindFirstChild("Torso")
		joint = torso and torso:FindFirstChild("Right Shoulder")
	end
	return if joint and joint:IsA("Motor6D") then joint else nil
end

-- Plays the wind-up and swing; yields for Game.TossWindup seconds (until
-- the moment the frog should leave the hand).
function TossAnimation.play(character: Model?)
	if not character then
		task.wait(Game.TossWindup)
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if root then
		-- Face down the river (+X).
		local pos = root.Position
		root.CFrame = CFrame.lookAt(pos, pos + Vector3.new(1, 0, 0))
	end

	local joint = shoulder(character)
	if not joint then
		task.wait(Game.TossWindup)
		return
	end
	local rest = joint.C0
	local windup = Game.TossWindup * 0.7
	local swing = Game.TossWindup - windup
	TweenService:Create(joint, TweenInfo.new(windup, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		C0 = rest * CFrame.Angles(math.rad(-150), 0, 0),
	}):Play()
	task.wait(windup)
	TweenService:Create(joint, TweenInfo.new(swing, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		C0 = rest * CFrame.Angles(math.rad(70), 0, 0),
	}):Play()
	task.wait(swing)
	task.delay(0.25, function()
		TweenService:Create(joint, TweenInfo.new(0.2), { C0 = rest }):Play()
	end)
end

-- Where the frog should start its first hop: the held frog in the hand if
-- it's there, otherwise just in front of the character.
function TossAnimation.releasePoint(character: Model?): Vector3
	local held = character and character:FindFirstChild("HeldFrog")
	if held and held:IsA("Model") then
		return held:GetPivot().Position
	end
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if root then
		return root.Position + Vector3.new(3, 1, 0)
	end
	return Game.hopZoneCenter() + Vector3.new(0, 3, 0)
end

return TossAnimation
