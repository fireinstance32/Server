-- Raises the local character's right arm by an angle on top of whatever the
-- Animator plays, for the procedural lift and toss. Every frame after the
-- animation step it rotates the shoulder's Transform, which works on classic
-- Motor6D rigs and on upgraded avatar joints (AnimationConstraint) alike.
-- Angle in degrees around the shoulder's X axis: + raises the arm forward
-- and up (165 = overhead), - swings it back.

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Shoulder = {}

local angle = Instance.new("NumberValue") -- tweened; read every frame
local current: Instance? = nil

local function joint(character: Model): Instance?
	local arm = character:FindFirstChild("RightUpperArm")
	local found = arm and arm:FindFirstChild("RightShoulder")
	if not found then
		local torso = character:FindFirstChild("Torso")
		found = torso and torso:FindFirstChild("Right Shoulder")
	end
	if found and (found:IsA("Motor6D") or found:IsA("AnimationConstraint")) then
		return found
	end
	return nil
end

RunService.PreSimulation:Connect(function()
	local target = current
	if target and target.Parent and angle.Value ~= 0 then
		local j = target :: any
		j.Transform = CFrame.Angles(math.rad(angle.Value), 0, 0) * j.Transform
	end
end)

-- Tweens the arm to `degrees` over `seconds`; returns false when the
-- character has no shoulder joint to move.
function Shoulder.tween(character: Model, degrees: number, seconds: number, style: Enum.EasingStyle?, direction: Enum.EasingDirection?): boolean
	current = joint(character)
	if not current then
		return false
	end
	TweenService:Create(angle, TweenInfo.new(seconds, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), {
		Value = degrees,
	}):Play()
	return true
end

return Shoulder
