-- Start area: launch dock and spawn. (Training ponds: PondRow.)

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
	buildSpawn(world)
end

return Plaza
