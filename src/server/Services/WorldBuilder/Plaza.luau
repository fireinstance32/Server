-- Start area: the Hop Zone strip and spawn. (Training ponds: PondRow.)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)
local Worlds = require(Shared.Config.Worlds)

local Parts = require(script.Parent.Parts)
local Style = require(script.Parent.Style)

local Plaza = {}

-- The Throw Zone at the lane start (reference "THROW ZONE"): a studded
-- yellow checker pad with the words painted across it and a pale edge along
-- the water.
local function buildHopZone(world: Model)
	local center = Game.hopZoneCenter()
	local sizeX, sizeZ = Game.HopZoneSizeX, Game.HopZoneSizeZ
	local strip = Parts.block(
		"HopZone",
		Vector3.new(sizeX, 0.5, sizeZ),
		CFrame.new(center.X, Parts.GroundTop + 0.25, center.Z),
		Color3.fromRGB(255, 196, 60),
		world
	)
	strip.CanCollide = false
	Style.studs(strip)
	Style.checkerFloor(CFrame.new(center.X, Parts.GroundTop + 0.5, center.Z), Vector2.new(sizeX, sizeZ), 4, Color3.fromRGB(255, 220, 110), strip)

	-- "THROW ZONE" painted across the strip, readable facing the water.
	local paint = Parts.block("Paint", Vector3.new(sizeX - 4, 0.05, sizeZ - 2), CFrame.new(center.X, Parts.GroundTop + 0.58, center.Z), Color3.new(1, 1, 1), strip)
	paint.Transparency = 1
	paint.CanCollide = false
	paint.CanQuery = false
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Top
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 20
	gui.LightInfluence = 0
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.FredokaOne
	text.Text = "THROW ZONE"
	text.TextScaled = true
	text.TextColor3 = Color3.fromRGB(245, 245, 250)
	text.Rotation = 90
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 6
	stroke.Color = Color3.fromRGB(40, 36, 50)
	stroke.Parent = text
	text.Parent = gui
	gui.Parent = paint

	-- Pale edge along the water and lavender trim on the other sides.
	local edge = Parts.block(
		"HopZoneEdge",
		Vector3.new(1.6, 0.7, sizeZ),
		CFrame.new(center.X + sizeX / 2 + 0.8, Parts.GroundTop + 0.35, center.Z),
		Color3.fromRGB(235, 225, 255),
		world
	)
	Style.studs(edge)
	for _, side in { -1, 1 } do
		local trim = Parts.block(
			"HopZoneTrim",
			Vector3.new(sizeX, 0.6, 1.2),
			CFrame.new(center.X, Parts.GroundTop + 0.3, center.Z + side * (sizeZ / 2 + 0.6)),
			Color3.fromRGB(150, 135, 210),
			world
		)
		trim.CanCollide = false
		Style.studs(trim)
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
	Style.studs(spawn)
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
