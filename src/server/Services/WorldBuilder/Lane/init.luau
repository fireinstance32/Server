-- The throw lane (reference "+1 Stone Skipping"): a long straight stretch of
-- water between raised checker-brick banks, one themed stretch per zone
-- (Banks), the zone names floating over the water (Signs), and the portal at
-- the far end.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)
local Zones = require(Shared.Config.Zones)
local Worlds = require(Shared.Config.Worlds)

local Parts = require(script.Parent.Parts)
local Banks = require(script.Banks)
local Signs = require(script.Signs)

local Lane = {}

local TAIL = 200 -- lane past the last zone's distance

local function buildWater(world: Model, config: Worlds.World)
	-- Terrain can't be moved later, so it's placed at the world's offset now.
	local length = Zones.RiverLength + TAIL
	local center = Game.RiverOrigin + Vector3.new(length / 2, -4, 0)
	workspace.Terrain:FillBlock(
		CFrame.new(center + Worlds.offset(config)),
		Vector3.new(length, 8, Game.RiverWidth),
		Enum.Material.Water
	)
	-- The end of the lane.
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
	Parts.sign(portal, `End of {config.name}`, "Travel worlds at the portals by spawn", Color3.fromRGB(220, 180, 255))
end

function Lane.build(world: Model, config: Worlds.World)
	local banks = Instance.new("Folder")
	banks.Name = "Lane"
	local props = Instance.new("Folder")
	props.Name = "Props"
	local signs = Instance.new("Folder")
	signs.Name = "ZoneSigns"
	local rng = Random.new(1234) -- fixed seed: same layout every server

	local zones = Zones.ByWorld[config.id] or Zones.List
	for i, zone in zones do
		local startX = Game.RiverOrigin.X + zone.distance
		local endX = Game.RiverOrigin.X + if zones[i + 1] then zones[i + 1].distance else Zones.RiverLength + TAIL
		Banks.build(zone, startX, endX, banks, props, rng)
		Signs.build(zone, startX + math.max(60 - zone.distance, 0) + 10, signs)
	end
	-- Performance (8.5): hundreds of small props per world; they don't need
	-- shadows or to be hit by raycasts.
	for _, part in props:GetDescendants() do
		if part:IsA("BasePart") then
			part.CastShadow = false
			part.CanQuery = false
		end
	end
	banks.Parent = world
	props.Parent = world
	signs.Parent = world
	buildWater(world, config)
end

return Lane
