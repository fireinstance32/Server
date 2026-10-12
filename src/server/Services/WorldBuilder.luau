-- Builds the World 1 greybox at server start: plaza, river with lily pads,
-- zone arches, launch dock, training pond, shop and egg stands.
-- Everything is generated from Shared.Config so balancing changes move the map.
-- Replace pieces with hand-built models later by putting a Model named
-- "World" in Workspace; the builder skips generation if it already exists.

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)
local Zones = require(Shared.Config.Zones)
local Pets = require(Shared.Config.Pets)
local Format = require(Shared.Util.Format)

local WorldBuilder = {}

local GRASS = Color3.fromRGB(110, 200, 90)
local WOOD = Color3.fromRGB(160, 110, 65)
local PAD = Color3.fromRGB(70, 175, 70)
local GROUND_TOP = 0.5

local world: Model

local function block(name: string, size: Vector3, cframe: CFrame, color: Color3, parent: Instance?, material: Enum.Material?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.CFrame = cframe
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent or world
	return p
end

local function sign(parent: BasePart, title: string, subtitle: string?, color: Color3?)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Sign"
	gui.Size = UDim2.fromOffset(320, if subtitle then 110 else 70)
	gui.StudsOffsetWorldSpace = Vector3.new(0, parent.Size.Y / 2 + 4, 0)
	gui.MaxDistance = 250
	gui.LightInfluence = 0

	local layout = Instance.new("UIListLayout")
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = gui

	local function label(text: string, height: number, textColor: Color3)
		local l = Instance.new("TextLabel")
		l.Size = UDim2.new(1, 0, 0, height)
		l.BackgroundTransparency = 1
		l.Font = Enum.Font.FredokaOne
		l.Text = text
		l.TextScaled = true
		l.TextColor3 = textColor
		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 3
		stroke.Color = Color3.fromRGB(30, 40, 30)
		stroke.Parent = l
		l.Parent = gui
	end

	label(title, 64, color or Color3.new(1, 1, 1))
	if subtitle then
		label(subtitle, 40, Color3.fromRGB(255, 240, 150))
	end
	gui.Parent = parent
end

local function buildLighting()
	Lighting.ClockTime = 14
	Lighting.Brightness = 2.5
	Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
	Lighting.GlobalShadows = true
	if not Lighting:FindFirstChildOfClass("Atmosphere") then
		local atmosphere = Instance.new("Atmosphere")
		atmosphere.Density = 0.25
		atmosphere.Haze = 1
		atmosphere.Color = Color3.fromRGB(200, 230, 255)
		atmosphere.Parent = Lighting
	end
end

local function buildGround()
	-- Parts are capped at 2048 studs per axis, so lay the banks in segments.
	local length = Zones.RiverLength + 200
	local segment = 1000
	local halfRiver = Game.RiverWidth / 2
	local bankWidth = 160
	local x = 0
	while x < length do
		local len = math.min(segment, length - x)
		for _, side in { -1, 1 } do
			local z = side * (halfRiver + bankWidth / 2)
			block(
				"Bank",
				Vector3.new(len, 6, bankWidth),
				CFrame.new(x + len / 2, GROUND_TOP - 3, z),
				GRASS,
				nil,
				Enum.Material.Grass
			)
		end
		x += len
	end

	-- Start plaza west of the river.
	block("Plaza", Vector3.new(260, 6, 380), CFrame.new(-130, GROUND_TOP - 3, 0), GRASS, nil, Enum.Material.Grass)

	-- River water (terrain) and a riverbed so swimmers have a floor.
	local riverCenter = Game.RiverOrigin + Vector3.new(Zones.RiverLength / 2 + 50, -4, 0)
	workspace.Terrain:FillBlock(
		CFrame.new(riverCenter),
		Vector3.new(Zones.RiverLength + 100, 8, Game.RiverWidth),
		Enum.Material.Water
	)
	block(
		"Riverbed",
		Vector3.new(Zones.RiverLength + 100, 2, Game.RiverWidth),
		CFrame.new(riverCenter - Vector3.new(0, 5, 0)),
		Color3.fromRGB(90, 80, 60),
		nil,
		Enum.Material.Sand
	)
end

local function buildPads()
	local folder = Instance.new("Folder")
	folder.Name = "LilyPads"
	folder.Parent = world
	local count = math.floor(Zones.RiverLength / Game.PadSpacing)
	for i = 1, count do
		local pos = Game.padPosition(i)
		local pad = block(
			"Pad",
			Vector3.new(0.4, 7, 7),
			CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90)),
			PAD,
			folder
		)
		pad.Shape = Enum.PartType.Cylinder
		pad.CanCollide = false
	end
end

local function buildZoneArches()
	local folder = Instance.new("Folder")
	folder.Name = "Zones"
	folder.Parent = world
	local half = Game.RiverWidth / 2 + 2
	for _, zone in Zones.List do
		local x = Game.RiverOrigin.X + math.max(zone.distance, 6)
		local arch = Instance.new("Model")
		arch.Name = "Zone" .. zone.index
		for _, side in { -1, 1 } do
			block("Pillar", Vector3.new(3, 22, 3), CFrame.new(x, 11, side * half), zone.color, arch)
		end
		local beam = block("Beam", Vector3.new(3, 4, half * 2 + 3), CFrame.new(x, 23, 0), zone.color, arch)
		sign(beam, `Zone {zone.index}: {zone.name}`, `{Format.abbreviate(zone.wins)} Wins`, zone.color)
		arch.Parent = folder
	end

	local portalX = Game.RiverOrigin.X + Zones.RiverLength
	local portal = block(
		"Portal",
		Vector3.new(2, 30, Game.RiverWidth),
		CFrame.new(portalX, 15, 0),
		Color3.fromRGB(150, 90, 255),
		world,
		Enum.Material.Neon
	)
	portal.Transparency = 0.3
	portal.CanCollide = false
	sign(portal, "World 2", "Coming soon!", Color3.fromRGB(220, 180, 255))
end

local function buildDock()
	local dock = Game.LaunchDock
	local platform = block(
		"LaunchDock",
		Vector3.new(20, 1, 20),
		CFrame.new(dock.X, GROUND_TOP + 0.5, dock.Z),
		WOOD,
		world,
		Enum.Material.WoodPlanks
	)
	sign(platform, "RIVER DOCK", "Press LAUNCH to hop for Wins!")
	local ring = block(
		"UseRing",
		Vector3.new(0.2, Game.UseRadius * 2, Game.UseRadius * 2),
		CFrame.new(dock.X, GROUND_TOP + 0.1, dock.Z) * CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromRGB(255, 220, 80),
		world,
		Enum.Material.Neon
	)
	ring.Shape = Enum.PartType.Cylinder
	ring.Transparency = 0.75
	ring.CanCollide = false
end

local function buildTrainingPond()
	-- The pond sits on top of the plaza, so it's a flat "water" disc rather
	-- than terrain (terrain water would be hidden under the plaza part).
	local center = Game.TrainingPond
	local water = block(
		"PondWater",
		Vector3.new(0.2, Game.TrainingPondRadius * 2, Game.TrainingPondRadius * 2),
		CFrame.new(center.X, GROUND_TOP + 0.1, center.Z) * CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromRGB(60, 150, 230),
		world,
		Enum.Material.Glass
	)
	water.Shape = Enum.PartType.Cylinder
	water.Transparency = 0.15
	water.CanCollide = false

	for i = 1, Game.TrainingPadCount do
		local pad = block(
			"TrainingPad",
			Vector3.new(0.4, 6, 6),
			CFrame.new(Game.trainingPadPosition(i)) * CFrame.Angles(0, 0, math.rad(90)),
			PAD,
			world
		)
		pad.Shape = Enum.PartType.Cylinder
		pad.CanCollide = false
	end

	local post = block(
		"TrainingSign",
		Vector3.new(1, 8, 1),
		CFrame.new(center.X, GROUND_TOP + 4, center.Z - Game.TrainingPondRadius - 4),
		WOOD,
		world
	)
	sign(post, "TRAINING POND", "Press TRAIN to earn Hops!")
end

local function standWithPrompt(name: string, position: Vector3, color: Color3, actionText: string, objectText: string): Part
	local base = block(
		name,
		Vector3.new(10, 3, 10),
		CFrame.new(position + Vector3.new(0, GROUND_TOP + 1.5, 0)),
		color,
		world
	)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 14
	prompt.RequiresLineOfSight = false
	prompt.Parent = base
	return base
end

local function buildStands()
	for _, egg in Pets.Eggs do
		local stand = standWithPrompt(
			"EggStand_" .. egg.id,
			egg.position,
			Color3.fromRGB(240, 230, 210),
			"Hatch",
			`{egg.name} ({Format.abbreviate(egg.price)} Wins)`
		)
		local prompt = stand:FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt
		prompt:SetAttribute("EggId", egg.id)

		local eggPart = block(
			"Egg",
			Vector3.new(5, 6.5, 5),
			stand.CFrame * CFrame.new(0, 4.75, 0),
			Pets.RarityColors[Pets.ById[egg.pets[#egg.pets].pet].rarity],
			stand
		)
		eggPart.Shape = Enum.PartType.Ball
		sign(eggPart, egg.name, `{Format.abbreviate(egg.price)} Wins`)
	end

	local shop = standWithPrompt(
		"FrogShop",
		Vector3.new(-70, 0, -50),
		Color3.fromRGB(120, 210, 120),
		"Open",
		"Frog Shop"
	)
	local prompt = shop:FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt
	prompt:SetAttribute("OpenMenu", "Frogs")
	sign(shop, "FROG SHOP", "Better frogs = more Hops!")
end

local function buildSpawn()
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Spawn"
	spawn.Anchored = true
	spawn.Size = Vector3.new(12, 1, 12)
	spawn.CFrame = CFrame.new(-100, GROUND_TOP + 0.5, 0)
	spawn.Color = Color3.fromRGB(255, 220, 90)
	spawn.Material = Enum.Material.SmoothPlastic
	spawn.Duration = 0
	spawn.Parent = world
end

function WorldBuilder.init()
	if workspace:FindFirstChild("World") then
		return
	end
	-- Drop the default baseplate if the place still has it.
	local baseplate = workspace:FindFirstChild("Baseplate")
	if baseplate then
		baseplate:Destroy()
	end

	world = Instance.new("Model")
	world.Name = "World"
	world.Parent = workspace

	buildLighting()
	buildGround()
	buildPads()
	buildZoneArches()
	buildDock()
	buildTrainingPond()
	buildStands()
	buildSpawn()
end

return WorldBuilder
