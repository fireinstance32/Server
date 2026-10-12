-- Drives the HOP button: picks Train/Launch from where the player stands,
-- asks the server for a result, then plays the frog hopping animation.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)
local Frogs = require(Shared.Config.Frogs)
local Zones = require(Shared.Config.Zones)
local Format = require(Shared.Util.Format)
local Models = require(Shared.Util.Models)
local Net = require(Shared.Net)

local Hud = require(script.Parent.Parent.UI.Hud)
local Theme = require(script.Parent.Parent.UI.Theme)
local State = require(script.Parent.Parent.State)

local HopController = {}

local player = Players.LocalPlayer
local busy = false
local FROG_LIFT = Vector3.new(0, 1, 0) -- pad positions are pad surfaces; lift the frog onto them

local function rootPart(): BasePart?
	local character = player.Character
	return character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
end

local function flatDistance(a: Vector3, b: Vector3): number
	return Vector3.new(a.X - b.X, 0, a.Z - b.Z).Magnitude
end

local function currentMode(): string?
	local root = rootPart()
	if not root then
		return nil
	end
	if flatDistance(root.Position, Game.LaunchDock) <= Game.UseRadius then
		return "Launch"
	elseif flatDistance(root.Position, Game.TrainingPond) <= Game.UseRadius then
		return "Train"
	end
	return nil
end

local function spawnFrog(): Model
	local frogId = State.data and State.data.equippedFrog or Frogs.Default
	local def = Frogs.ById[frogId] or Frogs.ById[Frogs.Default]
	local frog = Models.frog(def.color, 2.4)
	frog.Parent = Workspace
	return frog
end

-- Move the frog from a to b along a parabola over `duration` seconds.
local function hopArc(frog: Model, a: Vector3, b: Vector3, height: number, duration: number)
	local facing = Vector3.new(b.X - a.X, 0, b.Z - a.Z)
	local rotation = if facing.Magnitude > 0.01
		then CFrame.lookAt(Vector3.zero, facing) * CFrame.Angles(0, math.rad(90), 0)
		else CFrame.identity
	local elapsed = 0
	while elapsed < duration do
		elapsed += RunService.RenderStepped:Wait()
		local t = math.min(elapsed / duration, 1)
		local pos = a:Lerp(b, t) + Vector3.new(0, height * 4 * t * (1 - t), 0)
		frog:PivotTo(CFrame.new(pos) * rotation)
	end
end

local function splash(position: Vector3)
	local ring = Instance.new("Part")
	ring.Anchored = true
	ring.CanCollide = false
	ring.CanQuery = false
	ring.Shape = Enum.PartType.Cylinder
	ring.Material = Enum.Material.Neon
	ring.Color = Color3.fromRGB(200, 240, 255)
	ring.Transparency = 0.3
	ring.Size = Vector3.new(0.2, 2, 2)
	ring.CFrame = CFrame.new(position + Vector3.new(0, 0.3, 0)) * CFrame.Angles(0, 0, math.rad(90))
	ring.Parent = Workspace
	game:GetService("TweenService")
		:Create(ring, TweenInfo.new(0.4), { Size = Vector3.new(0.2, 9, 9), Transparency = 1 })
		:Play()
	game:GetService("Debris"):AddItem(ring, 0.5)
end

local function playTraining(result)
	local frog = spawnFrog()
	local perHop = result.hopsGained / result.bounces
	local start = math.random(1, Game.TrainingPadCount)
	local from = Game.trainingPadPosition(start) + FROG_LIFT
	frog:PivotTo(CFrame.new(from))
	local hopTime = (Game.TrainingCooldown * 0.9) / result.bounces
	for i = 1, result.bounces do
		local to = Game.trainingPadPosition((start + i - 1) % Game.TrainingPadCount + 1) + FROG_LIFT
		hopArc(frog, from, to, 3, hopTime)
		splash(to)
		Hud.floatText(`+{Format.abbreviate(perHop)}`, Theme.Colors.Green)
		from = to
	end
	frog:Destroy()
end

local function playLaunch(result)
	local frog = spawnFrog()
	local camera = Workspace.CurrentCamera
	local previousSubject = camera.CameraSubject
	camera.CameraSubject = frog.PrimaryPart

	local visualHops = math.min(result.bounces, Game.MaxVisualHops)
	local perPad = result.hopsGained / result.bounces
	local from = Game.LaunchDock + Vector3.new(8, 1.5, 0)
	local lastPad = 0
	local lastZone = 1
	frog:PivotTo(CFrame.new(from))

	for k = 1, visualHops do
		local pad = math.max(lastPad + 1, math.floor(k * result.bounces / visualHops + 0.5))
		local to = Game.padPosition(pad) + FROG_LIFT
		local span = (to - from).Magnitude
		hopArc(frog, from, to, 2 + span * 0.25, Game.SecondsPerVisualHop)
		splash(to)
		Hud.floatText(`+{Format.abbreviate(perPad * (pad - lastPad))}`, Theme.Colors.Green)

		local zone = Zones.zoneForDistance(pad * Game.PadSpacing)
		if zone.index > lastZone then
			lastZone = zone.index
			Hud.toast(`Zone {zone.index}: {zone.name}!`, zone.color)
		end
		from = to
		lastPad = pad
	end

	Hud.banner(
		`ZONE {result.zone}!`,
		`{result.zoneName}  •  +{Format.abbreviate(result.winsGained)} Wins`,
		Zones.List[result.zone].color
	)
	task.wait(Game.LandingPause)
	frog:Destroy()
	camera.CameraSubject = previousSubject
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		camera.CameraSubject = humanoid
	end
end

function HopController.hop()
	if busy then
		return
	end
	local mode = currentMode()
	if not mode then
		Hud.toast("Walk to the Training Pond or the River Dock!", Theme.Colors.Red)
		return
	end
	busy = true
	-- pcall so a server error or animation error can never leave the button stuck.
	local ok, err = pcall(function()
		local result = Net.func("Hop"):InvokeServer(mode)
		if result and result.ok then
			if result.mode == "Train" then
				playTraining(result)
			else
				playLaunch(result)
			end
		elseif result and result.message ~= "busy" then
			Hud.toast(result.message, Theme.Colors.Red)
		end
	end)
	if not ok then
		warn("[HopController]", err)
	end
	busy = false
end

function HopController.teleport(destination: string)
	local root = rootPart()
	if not root or busy then
		return
	end
	local target = if destination == "Train"
		then Game.TrainingPond + Vector3.new(0, 4, -Game.TrainingPondRadius + 6)
		else Game.LaunchDock + Vector3.new(0, 4, 0)
	local lookAt = if destination == "Train" then Game.TrainingPond else Game.padPosition(3)
	root.CFrame = CFrame.lookAt(target, Vector3.new(lookAt.X, target.Y, lookAt.Z))
end

function HopController.init()
	-- Keep the HOP button label in sync with where the player is standing.
	local lastMode: string? = "unset"
	RunService.Heartbeat:Connect(function()
		local mode = currentMode()
		if mode == lastMode then
			return
		end
		lastMode = mode
		if mode == "Launch" then
			Hud.setHopButton("LAUNCH! 🐸", Theme.Colors.Blue)
		elseif mode == "Train" then
			Hud.setHopButton("TRAIN 💪", Theme.Colors.Green)
		else
			Hud.setHopButton("HOP!", Theme.Colors.Grey)
		end
	end)
end

return HopController
