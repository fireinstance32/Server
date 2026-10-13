-- One lift rep: presses the held rock (right hand) up over the head and
-- back down. Procedural (moves the shoulder joint) like TossAnimation, so it
-- needs no animation asset; a real animation replaces it in stage 4 of the
-- Rock Pivot. Local-only: other players see the rock, not the arm.

local TweenService = game:GetService("TweenService")

local LiftAnimation = {}

local playing: { [Motor6D]: CFrame } = {} -- joint -> rest C0 while a rep plays

local function shoulder(character: Model): Motor6D?
	local r15 = character:FindFirstChild("RightUpperArm")
	local joint = r15 and r15:FindFirstChild("RightShoulder")
	if not joint then
		local torso = character:FindFirstChild("Torso")
		joint = torso and torso:FindFirstChild("Right Shoulder")
	end
	return if joint and joint:IsA("Motor6D") then joint else nil
end

-- Plays one rep over `duration` seconds and yields until the rock is at the
-- top (the moment to show the +Strength pop). The way down finishes on its own.
function LiftAnimation.play(character: Model?, duration: number)
	local joint = character and shoulder(character)
	if not joint then
		task.wait(duration / 2)
		return
	end
	local rest = playing[joint] or joint.C0
	playing[joint] = rest
	local up = duration * 0.45
	TweenService:Create(joint, TweenInfo.new(up, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		C0 = rest * CFrame.Angles(math.rad(165), 0, 0),
	}):Play()
	task.wait(up)
	local down = TweenService:Create(joint, TweenInfo.new(duration - up, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		C0 = rest,
	})
	down.Completed:Connect(function()
		if joint.C0 == rest then
			playing[joint] = nil
		end
	end)
	down:Play()
end

return LiftAnimation
