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
local Ponds = require(Shared.Config.Ponds)
local Worlds = require(Shared.Config.Worlds)
local Trails = require(Shared.Config.Trails)
local Format = require(Shared.Util.Format)
local Models = require(Shared.Util.Models)

local Hud = require(script.Parent.Parent.UI.Hud)
local Theme = require(script.Parent.Parent.UI.Theme)
local State = require(script.Parent.Parent.State)
local TossAnimation = require(script.Parent.TossAnimation)
local FollowCamera = require(script.Parent.FollowCamera)

local HopAnimation = {}

local player = Players.LocalPlayer
local FROG_LIFT = Vector3.new(0, 1, 0) -- pad positions are pad surfaces; lift the frog onto them

-- Adds the equipped trail behind the hopping frog.
local function attachTrail(frog: Model)
	local trailId = State.data and State.data.equippedTrail
	local def = trailId and Trails.ById[trailId]
	local body = frog.PrimaryPart
	if not def or not body then
		return
	end
	local a0 = Instance.new("Attachment")
	a0.Position = Vector3.new(0, 0.6, 0)
	a0.Parent = body
	local a1 = Instance.new("Attachment")
	a1.Position = Vector3.new(0, -0.6, 0)
	a1.Parent = body
	local keypoints = {}
	for k, color in def.colors do
		table.insert(keypoints, ColorSequenceKeypoint.new((k - 1) / math.max(#def.colors - 1, 1), color))
	end
	local trail = Instance.new("Trail")
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Color = ColorSequence.new(keypoints)
	trail.Lifetime = 0.6
	trail.LightEmission = 0.4
	trail.Transparency = NumberSequence.new(0.1, 1)
	trail.Parent = body
end

local function spawnFrog(): Model
	local frogId = State.data and State.data.equippedFrog or Frogs.Default
	local def = Frogs.ById[frogId] or Frogs.ById[Frogs.Default]
	local frog = Models.frog(def.color, 2.4)
	frog.Parent = Workspace
	attachTrail(frog)
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

local function worldOffset(worldId: string?): Vector3
	local world = Worlds.ById[worldId or Worlds.Default] or Worlds.List[1]
	return Worlds.offset(world)
end

function HopAnimation.playTraining(result)
	local pond = Ponds.ById[result.pond] or Ponds.List[1]
	local offset = worldOffset(result.world)
	local frog = spawnFrog()
	local perHop = result.hopsGained / result.bounces
	local start = math.random(1, Ponds.PadsPerPond)
	local lift = FROG_LIFT + Vector3.new(0, Ponds.SurfaceY, 0)
	local from = Ponds.padPosition(pond, start) + lift + offset
	frog:PivotTo(CFrame.new(from))
	local hopTime = (Game.TrainingCooldown * 0.9) / result.bounces
	for i = 1, result.bounces do
		local to = Ponds.padPosition(pond, (start + i - 1) % Ponds.PadsPerPond + 1) + lift + offset
		hopArc(frog, from, to, 3, hopTime)
		splash(to)
		Hud.floatText(`+{Format.abbreviate(perHop)}`, Theme.Colors.Green)
		from = to
	end
	frog:Destroy()
end

function HopAnimation.playLaunch(result)
	-- Hold-and-toss first; the frog appears where the held one was.
	local character = player.Character
	TossAnimation.play(character)
	local from = TossAnimation.releasePoint(character)

	local frog = spawnFrog()
	frog:PivotTo(CFrame.new(from))
	FollowCamera.start(frog.PrimaryPart :: BasePart)

	-- Best before this hop (the server updates it on landing); the meter
	-- turns gold once it's beaten.
	local previousBest = Game.metersFor(if State.data then State.data.bestDistance or 0 else 0)
	Hud.distance.show(previousBest)

	local visualHops = math.min(result.bounces, Game.MaxVisualHops)
	local perPad = result.hopsGained / result.bounces
	local offset = worldOffset(result.world)
	local zones = Zones.ByWorld[result.world or Worlds.Default] or Zones.List
	local lastPad = 0
	local lastZone = 1

	for k = 1, visualHops do
		local pad = math.max(lastPad + 1, math.floor(k * result.bounces / visualHops + 0.5))
		local to = Game.padPosition(pad) + FROG_LIFT + offset
		local span = (to - from).Magnitude
		hopArc(frog, from, to, 2 + span * 0.25, Game.SecondsPerVisualHop)
		splash(to)
		Hud.floatText(`+{Format.abbreviate(perPad * (pad - lastPad))}`, Theme.Colors.Green)

		local meters = math.min(Game.metersFor(to.X - Game.RiverOrigin.X), result.meters)
		Hud.distance.set(meters, meters > previousBest)

		local zone = Zones.zoneForDistance(pad * Game.PadSpacing, result.world)
		if zone.index > lastZone then
			lastZone = zone.index
			Hud.toast(`Zone {zone.index}: {zone.name}!`, zone.color)
		end
		from = to
		lastPad = pad
	end

	Hud.distance.set(result.meters, result.newBest)
	local subtitle = `{result.meters} m  •  +{Format.abbreviate(result.winsGained)} Wins`
	if result.newBest then
		subtitle ..= "  •  NEW BEST!"
	end
	Hud.banner(`ZONE {result.zone}: {result.zoneName}`, subtitle, zones[result.zone].color)
	task.wait(Game.LandingPause)
	frog:Destroy()
	Hud.distance.hide()
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	FollowCamera.stop(humanoid)
end

return HopAnimation
