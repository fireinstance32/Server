-- The hold-and-toss: turns the character to face the river, winds the right
-- arm back, then swings it forward. Procedural (see Pose) so it needs no
-- animation asset. Local-only: other players see the rock leave the hand.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Game = require(ReplicatedStorage:WaitForChild("Shared").Config.Game)
local Pose = require(script.Parent.Pose)

local TossAnimation = {}

-- Plays the wind-up and swing; yields for Game.TossWindup seconds (until
-- the moment the rock should leave the hand).
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

	local windup = Game.TossWindup * 0.7
	local swing = Game.TossWindup - windup
	-- Coil: crouch, lean back, arm far behind. Then whip: rise, lunge
	-- forward and swing through.
	if not Pose.to(character, { shoulder = -150, elbow = 20, squat = 0.55, arch = 14, flex = 0 }, windup) then
		task.wait(Game.TossWindup)
		return
	end
	task.wait(windup)
	Pose.to(character, { shoulder = 80, elbow = 0, squat = 0.15, arch = -18 }, swing, Enum.EasingStyle.Back)
	task.wait(swing)
	task.delay(0.25, function()
		Pose.relax(character :: Model, 0.25)
	end)
end

-- Where the rock should start its first hop: the held rock in the hand if
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
