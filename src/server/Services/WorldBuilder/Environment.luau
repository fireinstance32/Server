-- Lighting, ground, river water and riverbed.

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)
local Zones = require(Shared.Config.Zones)

local Parts = require(script.Parent.Parts)
local Props = require(script.Parent.Props)

local Environment = {}

local function buildLighting(world: Model)
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

local function buildGround(world: Model)
	-- Parts are capped at 2048 studs per axis, so lay the banks in segments.
	-- One bank stretch per zone, coloured and dressed for its biome.
	local halfRiver = Game.RiverWidth / 2
	local bankWidth = 160
	local banks = Instance.new("Folder")
	banks.Name = "Banks"
	banks.Parent = world
	local props = Instance.new("Folder")
	props.Name = "Props"
	props.Parent = world
	local rng = Random.new(1234) -- fixed seed: same layout every server

	for i, zone in Zones.List do
		local startX = zone.distance
		local endX = if Zones.List[i + 1] then Zones.List[i + 1].distance else Zones.RiverLength + 200
		local len = endX - startX
		for _, side in { -1, 1 } do
			Parts.block(
				"Bank_" .. zone.index,
				Vector3.new(len, 6, bankWidth),
				CFrame.new(startX + len / 2, Parts.GroundTop - 3, side * (halfRiver + bankWidth / 2)),
				zone.bank,
				banks,
				zone.material
			)
			-- Props along the bank, thinning out away from the water.
			local x = startX + rng:NextNumber(4, 16)
			while x < endX do
				local z = side * (halfRiver + 6 + rng:NextNumber(0, 50))
				local kind = zone.props[rng:NextInteger(1, #zone.props)]
				Props.place(kind, Vector3.new(x, Parts.GroundTop, z), rng, props)
				x += rng:NextNumber(18, 32)
			end
		end
	end

	-- Start plaza west of the river.
	Parts.block("Plaza", Vector3.new(260, 6, 380), CFrame.new(-130, Parts.GroundTop - 3, 0), Parts.Colors.Grass, world, Enum.Material.Grass)

	-- River water (terrain) and a riverbed so swimmers have a floor.
	local riverCenter = Game.RiverOrigin + Vector3.new(Zones.RiverLength / 2 + 50, -4, 0)
	workspace.Terrain:FillBlock(
		CFrame.new(riverCenter),
		Vector3.new(Zones.RiverLength + 100, 8, Game.RiverWidth),
		Enum.Material.Water
	)
	Parts.block(
		"Riverbed",
		Vector3.new(Zones.RiverLength + 100, 2, Game.RiverWidth),
		CFrame.new(riverCenter - Vector3.new(0, 5, 0)),
		Color3.fromRGB(90, 80, 60),
		world,
		Enum.Material.Sand
	)
end

function Environment.build(world: Model)
	buildLighting(world)
	buildGround(world)
end

return Environment
