-- Smooth chase camera for the hopping frog: trails behind and above,
-- eases toward the frog every frame, then hands control back.

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local FollowCamera = {}

local OFFSET = Vector3.new(-22, 12, 6) -- behind (−X), above, slightly to the side
local LOOK_AHEAD = Vector3.new(10, 0, 0)
local SMOOTHING = 6

local connection: RBXScriptConnection? = nil

function FollowCamera.start(target: BasePart)
	FollowCamera.stop()
	local camera = Workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Scriptable
	connection = RunService.RenderStepped:Connect(function(dt)
		if not target.Parent then
			return
		end
		local focus = target.Position
		local goal = CFrame.lookAt(focus + OFFSET, focus + LOOK_AHEAD)
		camera.CFrame = camera.CFrame:Lerp(goal, math.min(dt * SMOOTHING, 1))
	end)
end

function FollowCamera.stop(humanoid: Humanoid?)
	if connection then
		connection:Disconnect()
		connection = nil
	end
	local camera = Workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Custom
	if humanoid then
		camera.CameraSubject = humanoid
	end
end

return FollowCamera
