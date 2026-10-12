-- Start area: the Hop Zone strip and spawn. (Training ponds: PondRow.)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)
local Worlds = require(Shared.Config.Worlds)

local Parts = require(script.Parent.Parts)

local Plaza = {}

-- The painted Hop Zone strip at the river start (reference "THROW ZONE").
local function buildHopZone(world: Model)
	local center = Game.hopZoneCenter()
	local strip = Parts.block(
		"HopZone",
		Vector3.new(Game.HopZoneSizeX, 0.2, Game.HopZoneSizeZ),
		CFrame.new(center.X, Parts.GroundTop + 0.1, center.Z),
		Color3.fromRGB(255, 190, 60),
		world,
		Enum.Material.SmoothPlastic
	)
	strip.CanCollide = false

	-- "HOP ZONE" painted across the strip, readable from the plaza side.
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Top
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 20
	gui.LightInfluence = 0
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.FredokaOne
	text.Text = "HOP ZONE"
	text.TextScaled = true
	text.TextColor3 = Color3.new(1, 1, 1)
	text.TextStrokeTransparency = 0
	text.Rotation = 90
	text.Parent = gui
	gui.Parent = strip

	-- Edge stripes so the zone's border is obvious.
	for _, side in { -1, 1 } do
		local edge = Parts.block(
			"HopZoneEdge",
			Vector3.new(Game.HopZoneSizeX, 0.25, 1.2),
			CFrame.new(center.X, Parts.GroundTop + 0.12, center.Z + side * Game.HopZoneSizeZ / 2),
			Color3.fromRGB(70, 160, 255),
			world
		)
		edge.CanCollide = false
	end
end

local function buildSpawn(world: Model, config: Worlds.World)
	-- Only the first world has the real SpawnLocation; others get a plain
	-- landing pad that world travel teleports to.
	local spawn = if config.index == 1 then Instance.new("SpawnLocation") else Instance.new("Part")
	spawn.Name = if config.index == 1 then "Spawn" else "Landing"
	spawn.Anchored = true
	spawn.Size = Vector3.new(12, 1, 12)
	spawn.CFrame = CFrame.new(-100, Parts.GroundTop + 0.5, 0)
	spawn.Color = Color3.fromRGB(255, 220, 90)
	spawn.Material = Enum.Material.SmoothPlastic
	if spawn:IsA("SpawnLocation") then
		spawn.Duration = 0
	end
	spawn.Parent = world
end

function Plaza.build(world: Model, config: Worlds.World)
	buildHopZone(world)
	buildSpawn(world, config)
end

return Plaza
