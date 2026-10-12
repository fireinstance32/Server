-- Start area: launch dock, training pond and spawn.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)

local Parts = require(script.Parent.Parts)

local Plaza = {}

local function buildDock(world: Model)
	local dock = Game.LaunchDock
	local platform = Parts.block(
		"LaunchDock",
		Vector3.new(20, 1, 20),
		CFrame.new(dock.X, Parts.GroundTop + 0.5, dock.Z),
		Parts.Colors.Wood,
		world,
		Enum.Material.WoodPlanks
	)
	Parts.sign(platform, "RIVER DOCK", "Press LAUNCH to hop for Wins!")
	local ring = Parts.block(
		"UseRing",
		Vector3.new(0.2, Game.UseRadius * 2, Game.UseRadius * 2),
		CFrame.new(dock.X, Parts.GroundTop + 0.1, dock.Z) * CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromRGB(255, 220, 80),
		world,
		Enum.Material.Neon
	)
	ring.Shape = Enum.PartType.Cylinder
	ring.Transparency = 0.75
	ring.CanCollide = false
end

local function buildTrainingPond(world: Model)
	-- The pond sits on top of the plaza, so it's a flat "water" disc rather
	-- than terrain (terrain water would be hidden under the plaza part).
	local center = Game.TrainingPond
	local water = Parts.block(
		"PondWater",
		Vector3.new(0.2, Game.TrainingPondRadius * 2, Game.TrainingPondRadius * 2),
		CFrame.new(center.X, Parts.GroundTop + 0.1, center.Z) * CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromRGB(60, 150, 230),
		world,
		Enum.Material.Glass
	)
	water.Shape = Enum.PartType.Cylinder
	water.Transparency = 0.15
	water.CanCollide = false

	for i = 1, Game.TrainingPadCount do
		local pad = Parts.block(
			"TrainingPad",
			Vector3.new(0.4, 6, 6),
			CFrame.new(Game.trainingPadPosition(i)) * CFrame.Angles(0, 0, math.rad(90)),
			Parts.Colors.Pad,
			world
		)
		pad.Shape = Enum.PartType.Cylinder
		pad.CanCollide = false
	end

	local post = Parts.block(
		"TrainingSign",
		Vector3.new(1, 8, 1),
		CFrame.new(center.X, Parts.GroundTop + 4, center.Z - Game.TrainingPondRadius - 4),
		Parts.Colors.Wood,
		world
	)
	Parts.sign(post, "TRAINING POND", "Press TRAIN to earn Hops!")
end

local function buildSpawn(world: Model)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Spawn"
	spawn.Anchored = true
	spawn.Size = Vector3.new(12, 1, 12)
	spawn.CFrame = CFrame.new(-100, Parts.GroundTop + 0.5, 0)
	spawn.Color = Color3.fromRGB(255, 220, 90)
	spawn.Material = Enum.Material.SmoothPlastic
	spawn.Duration = 0
	spawn.Parent = world
end

function Plaza.build(world: Model)
	buildDock(world)
	buildTrainingPond(world)
	buildSpawn(world)
end

return Plaza
