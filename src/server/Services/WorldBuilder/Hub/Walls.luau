-- The lobby's walls (reference): two-tier terraced checker walls round the
-- back and both sides, in the world's first-zone wall colours with grass on
-- top, bushes on the ledge and trees up top. The front is the throw lane's
-- banks (Lane/Banks), whose ends face the lobby.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Worlds = require(Shared.Config.Worlds)
local Zones = require(Shared.Config.Zones)
local Lobby = require(Shared.Config.Lobby)

local Terraces = require(script.Parent.Parent.Terraces)
local Props = require(script.Parent.Parent.Props)

local Walls = {}

local LEDGE_PROPS = { "bush", "flower", "bush", "rock" }

-- Props along one run: small ones on the ledge, the zone's trees up top.
local function dress(run: Terraces.Run, zone: Zones.Zone, rng: Random, props: Instance)
	local along = rng:NextNumber(4, 12)
	while along < run.length - 4 do
		Props.place(LEDGE_PROPS[rng:NextInteger(1, #LEDGE_PROPS)], Terraces.point(run, along, 1, rng:NextNumber(3, 7)), rng, props)
		along += rng:NextNumber(14, 24)
	end
	along = rng:NextNumber(4, 12)
	while along < run.length - 4 do
		local kind = zone.props[rng:NextInteger(1, #zone.props)]
		Props.place(kind, Terraces.point(run, along, 2, rng:NextNumber(5, 30)), rng, props)
		along += rng:NextNumber(12, 22)
	end
end

function Walls.build(map: Model, config: Worlds.World)
	local folder = Instance.new("Folder")
	folder.Name = "Walls"
	local props = Instance.new("Folder")
	props.Name = "WallProps"
	local theme = Worlds.theme(config)
	local zone = (Zones.ByWorld[config.id] or Zones.List)[1]
	local rng = Random.new(4321)
	local back, front, half = Lobby.BackX, Lobby.FrontX, Lobby.HalfZ

	-- Each run's frame: X along the wall, Z outward (Terraces.Run).
	local runs = {
		{ "BackWall", Vector3.new(back, 0, -half), Vector3.zAxis, -Vector3.xAxis, half * 2, true, true },
		{ "SideNorth", Vector3.new(back, 0, half), Vector3.xAxis, Vector3.zAxis, front - back, true, false },
		{ "SideSouth", Vector3.new(front, 0, -half), -Vector3.xAxis, -Vector3.zAxis, front - back, false, true },
	}
	for _, r in runs do
		local run: Terraces.Run = {
			name = r[1],
			frame = CFrame.fromMatrix(r[2], r[3], Vector3.yAxis, r[4]),
			length = r[5],
			faceBottom = Lobby.FloorY,
			extendStart = r[6],
			extendEnd = r[7],
			wall = zone.wall,
			grass = theme.plaza,
			ledge = theme.plazaAlt,
		}
		Terraces.build(run, folder)
		dress(run, zone, rng, props)
	end
	for _, part in props:GetDescendants() do
		if part:IsA("BasePart") then
			part.CastShadow = false
			part.CanQuery = false
		end
	end
	folder.Parent = map
	props.Parent = map
end

return Walls
