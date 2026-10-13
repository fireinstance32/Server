-- Procedural poses for the local character's lift and toss, layered on top
-- of whatever the Animator plays. Each channel is a tweened number; every
-- frame (after the animation step) the channels bend the joints' Transform,
-- which works on classic Motor6D rigs and upgraded avatar joints
-- (AnimationConstraint) alike. Local-only: other players see the rock, not
-- the pose.
--
-- Channels (all 0 = untouched):
--   shoulder  right arm, degrees around the shoulder's X: + raises it forward
--             and up (165 = overhead), - swings it back
--   elbow     right forearm, degrees: + bends it up toward the shoulder
--   flex      0..1 left arm curled up into a bicep flex
--   squat     0..1 knees bent, hips back, body lowered
--   arch      degrees the chest and head tilt back (- hunches forward)
-- R6 rigs only get shoulder and a lowered body; R15 gets everything.

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Pose = {}

export type Channel = "shoulder" | "elbow" | "flex" | "squat" | "arch"

local values: { [string]: NumberValue } = {}
for _, name in { "shoulder", "elbow", "flex", "squat", "arch" } do
	values[name] = Instance.new("NumberValue")
end

local rig: { [string]: any }? = nil
local rigOf: Model? = nil

local function find(character: Model, part: string, joint: string): Instance?
	local holder = character:FindFirstChild(part)
	local found = holder and holder:FindFirstChild(joint)
	if found and (found:IsA("Motor6D") or found:IsA("AnimationConstraint")) then
		return found
	end
	return nil
end

local function joints(character: Model): { [string]: any }
	local leg = character:FindFirstChild("RightUpperLeg") :: BasePart?
	return {
		shoulder = find(character, "RightUpperArm", "RightShoulder") or find(character, "Torso", "Right Shoulder"),
		elbow = find(character, "RightLowerArm", "RightElbow"),
		leftShoulder = find(character, "LeftUpperArm", "LeftShoulder"),
		leftElbow = find(character, "LeftLowerArm", "LeftElbow"),
		root = find(character, "LowerTorso", "Root") or find(character, "HumanoidRootPart", "RootJoint"),
		waist = find(character, "UpperTorso", "Waist"),
		neck = find(character, "Head", "Neck"),
		rightHip = find(character, "RightUpperLeg", "RightHip"),
		leftHip = find(character, "LeftUpperLeg", "LeftHip"),
		rightKnee = find(character, "RightLowerLeg", "RightKnee"),
		leftKnee = find(character, "LeftLowerLeg", "LeftKnee"),
		legLength = if leg then leg.Size.Y * 2 else 2,
		r15 = character:FindFirstChild("UpperTorso") ~= nil,
	}
end

local function bend(joint: any, offset: CFrame)
	if joint and joint.Parent then
		joint.Transform = offset * joint.Transform
	end
end

local rad = math.rad

RunService.PreSimulation:Connect(function()
	local j = rig
	if not j then
		return
	end
	local shoulder, elbow = values.shoulder.Value, values.elbow.Value
	local flex, squat, arch = values.flex.Value, values.squat.Value, values.arch.Value
	if shoulder ~= 0 then
		-- Swing it out a little as it rises so the rock clears the head.
		local out = if j.r15 then math.clamp(shoulder, 0, 180) / 180 * 12 else 0
		bend(j.shoulder, CFrame.Angles(rad(shoulder), 0, rad(out)))
	end
	if elbow ~= 0 then
		bend(j.elbow, CFrame.Angles(rad(elbow), 0, 0))
	end
	if flex ~= 0 then
		bend(j.leftShoulder, CFrame.Angles(rad(15 * flex), 0, rad(-85 * flex)))
		bend(j.leftElbow, CFrame.Angles(rad(-20 * flex), 0, rad(-115 * flex)))
	end
	if squat ~= 0 then
		local drop = j.legLength * 0.24 * squat
		bend(j.root, CFrame.new(0, -drop, 0))
		if j.r15 then
			bend(j.rightHip, CFrame.Angles(rad(55 * squat), 0, rad(-6 * squat)))
			bend(j.leftHip, CFrame.Angles(rad(55 * squat), 0, rad(6 * squat)))
			bend(j.rightKnee, CFrame.Angles(rad(-100 * squat), 0, 0))
			bend(j.leftKnee, CFrame.Angles(rad(-100 * squat), 0, 0))
		end
	end
	local lean = arch - 22 * squat
	if lean ~= 0 then
		bend(j.waist, CFrame.Angles(rad(lean), 0, 0))
		bend(j.neck, CFrame.Angles(rad(lean * 0.8 + 10 * squat), 0, 0))
	end
end)

-- Tweens the given channels to their targets over `seconds`. Returns false
-- when the character has no shoulder to move (nothing will play).
function Pose.to(character: Model, targets: { [Channel]: number }, seconds: number, style: Enum.EasingStyle?, direction: Enum.EasingDirection?): boolean
	if rigOf ~= character or not rig or not (rig.shoulder and rig.shoulder.Parent) then
		rig, rigOf = joints(character), character
	end
	if not (rig :: any).shoulder then
		return false
	end
	local info = TweenInfo.new(seconds, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
	for channel, target in targets do
		TweenService:Create(values[channel], info, { Value = target }):Play()
	end
	return true
end

-- Everything back to rest.
function Pose.relax(character: Model, seconds: number)
	Pose.to(character, { shoulder = 0, elbow = 0, flex = 0, squat = 0, arch = 0 }, seconds, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
end

return Pose
