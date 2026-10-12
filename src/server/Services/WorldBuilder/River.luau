-- Lily pads, zone arches and the World 2 portal along the river.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)
local Zones = require(Shared.Config.Zones)
local Format = require(Shared.Util.Format)

local Parts = require(script.Parent.Parts)

local River = {}

local function buildPads(world: Model)
	local folder = Instance.new("Folder")
	folder.Name = "LilyPads"
	folder.Parent = world
	local count = math.floor(Zones.RiverLength / Game.PadSpacing)
	for i = 1, count do
		local pos = Game.padPosition(i)
		local pad = Parts.block(
			"Pad",
			Vector3.new(0.4, 7, 7),
			CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90)),
			Parts.Colors.Pad,
			folder
		)
		pad.Shape = Enum.PartType.Cylinder
		pad.CanCollide = false
	end
end

local function buildZoneArches(world: Model)
	local folder = Instance.new("Folder")
	folder.Name = "Zones"
	folder.Parent = world
	local half = Game.RiverWidth / 2 + 2
	for _, zone in Zones.List do
		local x = Game.RiverOrigin.X + math.max(zone.distance, 6)
		local arch = Instance.new("Model")
		arch.Name = "Zone" .. zone.index
		for _, side in { -1, 1 } do
			Parts.block("Pillar", Vector3.new(3, 22, 3), CFrame.new(x, 11, side * half), zone.color, arch)
		end
		local beam = Parts.block("Beam", Vector3.new(3, 4, half * 2 + 3), CFrame.new(x, 23, 0), zone.color, arch)
		Parts.sign(beam, `Zone {zone.index}: {zone.name}`, `{Format.abbreviate(zone.wins)} Wins`, zone.color)
		arch.Parent = folder
	end

	local portalX = Game.RiverOrigin.X + Zones.RiverLength
	local portal = Parts.block(
		"Portal",
		Vector3.new(2, 30, Game.RiverWidth),
		CFrame.new(portalX, 15, 0),
		Color3.fromRGB(150, 90, 255),
		world,
		Enum.Material.Neon
	)
	portal.Transparency = 0.3
	portal.CanCollide = false
	Parts.sign(portal, "World 2", "Coming soon!", Color3.fromRGB(220, 180, 255))
end

function River.build(world: Model)
	buildPads(world)
	buildZoneArches(world)
end

return River
