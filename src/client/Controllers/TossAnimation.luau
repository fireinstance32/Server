-- The hold-and-toss: turns the character to face the river, winds the right
-- arm back, then swings it forward. Procedural (moves the shoulder joint) so
-- it needs no animation asset; Phase 6 can swap in a real animation.
-- Local-only for now: other players see the rock leave the hand, not the swing.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Game = require(ReplicatedStorage:WaitForChild("Shared").Config.Game)
local Shoulder = require(script.Parent.Shoulder)

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
	if not Shoulder.tween(character, -150, windup) then
		task.wait(Game.TossWindup)
		return
	end
	task.wait(windup)
	Shoulder.tween(character, 70, swing, Enum.EasingStyle.Back)
	task.wait(swing)
	task.delay(0.25, function()
		Shoulder.tween(character, 0, 0.2)
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
