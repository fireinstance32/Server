-- Plays hop results on the client: the frog model hopping pad to pad, splash
-- rings, floating numbers, camera follow and the landing banner. Purely
-- visual; rewards are already decided by the server.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)
local Frogs = require(Shared.Config.Frogs)
local Zones = require(Shared.Config.Zones)
local Format = require(Shared.Util.Format)
local Models = require(Shared.Util.Models)

local Hud = require(script.Parent.Parent.UI.Hud)
local Theme = require(script.Parent.Parent.UI.Theme)
local State = require(script.Parent.Parent.State)

local HopAnimation = {}

local player = Players.LocalPlayer
local FROG_LIFT = Vector3.new(0, 1, 0) -- pad positions are pad surfaces; lift the frog onto them

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
	TweenService:Create(ring, TweenInfo.new(0.4), { Size = Vector3.new(0.2, 9, 9), Transparency = 1 })
		:Play()
	Debris:AddItem(ring, 0.5)
end

function HopAnimation.playTraining(result)
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

function HopAnimation.playLaunch(result)
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

return HopAnimation
