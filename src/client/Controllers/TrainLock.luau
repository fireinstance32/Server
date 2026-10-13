-- Locks the player in place while training: stepping onto an unlocked gym's
-- stand pad snaps them to its centre facing the gym, freezes movement and
-- keeps the lift going (HopController auto-trains only while locked). The
-- STOP button or a jump lets them go; they won't be locked again until
-- they've stepped off that pad.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Ponds = require(Shared.Config.Ponds)
local Worlds = require(Shared.Config.Worlds)

local TrainLock = {}

local player = Players.LocalPlayer
local lockedPond: Ponds.Pond? = nil
local releasedPond: Ponds.Pond? = nil -- left by STOP/jump; ignored until stepped off
local saved: { walk: number, jump: number, height: number, autoRotate: boolean }? = nil
local listeners: { (boolean) -> () } = {}

local function humanoid(): (Humanoid?, BasePart?)
	local character = player.Character
	local hum = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	return hum, root
end

local function notify()
	for _, listener in listeners do
		listener(lockedPond ~= nil)
	end
end

function TrainLock.isLocked(): boolean
	return lockedPond ~= nil
end

function TrainLock.onChanged(listener: (boolean) -> ())
	table.insert(listeners, listener)
end

-- Called every frame with the pond the player is standing on (or nil).
-- Returns true if the player is (now) locked on it.
function TrainLock.update(pond: Ponds.Pond?): boolean
	if pond ~= releasedPond then
		releasedPond = nil
	end
	if lockedPond then
		return true
	end
	if not pond or pond == releasedPond then
		return false
	end
	local hum, root = humanoid()
	if not hum or not root or hum.Health <= 0 then
		return false
	end
	local world = Worlds.toLocal(root.Position)
	if not world then
		return false
	end
	-- Snap to the pad centre, facing out into the lobby (−Z; the rack is behind).
	local offset = Worlds.offset(world)
	local stand = Ponds.standPosition(pond) + offset
	local at = Vector3.new(stand.X, root.Position.Y, stand.Z)
	root.AssemblyLinearVelocity = Vector3.zero
	root.CFrame = CFrame.lookAt(at, at - Vector3.zAxis)
	saved = { walk = hum.WalkSpeed, jump = hum.JumpPower, height = hum.JumpHeight, autoRotate = hum.AutoRotate }
	hum.WalkSpeed = 0
	hum.JumpPower = 0
	hum.JumpHeight = 0
	hum.AutoRotate = false
	lockedPond = pond
	notify()
	return true
end

function TrainLock.release()
	if not lockedPond then
		return
	end
	releasedPond = lockedPond
	lockedPond = nil
	local hum = humanoid()
	if hum and saved then
		hum.WalkSpeed = saved.walk
		hum.JumpPower = saved.jump
		hum.JumpHeight = saved.height
		hum.AutoRotate = saved.autoRotate
	end
	saved = nil
	notify()
end

function TrainLock.init()
	UserInputService.JumpRequest:Connect(TrainLock.release)
	player.CharacterAdded:Connect(function()
		-- A fresh character has its own defaults; just forget the lock.
		lockedPond, releasedPond, saved = nil, nil, nil
		notify()
	end)
end

return TrainLock
