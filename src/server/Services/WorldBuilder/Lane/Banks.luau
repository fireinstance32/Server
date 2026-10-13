-- One zone's stretch of the throw lane (reference): two-tier checker banks
-- in the zone's wall colours with grass on top, a grass checker along the
-- lower ledge, the water (tinted a little by the zone) and its props on
-- both tiers.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)
local Lobby = require(Shared.Config.Lobby)
local Zones = require(Shared.Config.Zones)

local Terraces = require(script.Parent.Parent.Terraces)
local Props = require(script.Parent.Parent.Props)
local Water = require(script.Parent.Parent.Water)

local Banks = {}

local CELL = Vector2.new(7, 4.75) -- wall checker cell (width, height)
-- Small things on the lower ledge; the zone's own props go up top.
local LEDGE_PROPS = { "bush", "flower", "rock", "reed" }

local function scatter(run: Terraces.Run, tier: number, from: number, to: number, spacing: NumberRange, kinds: { string }, rng: Random, props: Instance)
	local along = rng:NextNumber(2, spacing.Max)
	local depth = Terraces.Tiers[tier].depth
	while along < run.length - 2 do
		local out = if tier == 1 then rng:NextNumber(3, depth - 3) else rng:NextNumber(from, to)
		Props.place(kinds[rng:NextInteger(1, #kinds)], Terraces.point(run, along, tier, out), rng, props)
		along += rng:NextNumber(spacing.Min, spacing.Max)
	end
end

-- Builds zone `zone` from lane X `startX` to `endX` into `folder`; props go
-- into `props`. The first zone starts at the lobby's front wall and shows
-- checker end faces to the lobby. `rng` is the world's fixed-seed random.
function Banks.build(zone: Zones.Zone, startX: number, endX: number, first: boolean, folder: Instance, props: Instance, rng: Random)
	local half = Game.RiverWidth / 2
	local len = endX - startX
	local model = Instance.new("Model")
	model.Name = "Zone" .. zone.index
	local ledge = zone.bank:Lerp(Color3.new(1, 1, 1), 0.2)
	-- How far the end faces reach out: past the lobby's side walls' first
	-- tier (the second tier's end shows above their ledge).
	local capReach = if first then Lobby.HalfZ - half + Terraces.Tiers[1].depth else nil

	for _, side in { -1, 1 } do
		-- +Z bank runs +X; −Z bank runs −X (so Z always points outward).
		local start = if side == 1 then Vector3.new(startX, 0, half) else Vector3.new(endX, 0, -half)
		local along = if side == 1 then Vector3.xAxis else -Vector3.xAxis
		local run: Terraces.Run = {
			name = if side == 1 then "BankNorth" else "BankSouth",
			frame = CFrame.fromMatrix(start, along, Vector3.yAxis, Vector3.zAxis * side),
			length = len,
			faceBottom = 0,
			capStart = if side == 1 then capReach else nil,
			capEnd = if side == -1 then capReach else nil,
			wall = zone.wall,
			grass = zone.bank,
			ledge = ledge,
			cell = CELL,
		}
		Terraces.build(run, model)
		scatter(run, 1, 0, 0, NumberRange.new(16, 30), LEDGE_PROPS, rng, props)
		scatter(run, 2, 6, 44, NumberRange.new(14, 26), zone.props, rng, props)
	end

	-- The water, a touch of the zone's colour in the reference blue.
	local waterFrom = math.max(startX, Game.RiverOrigin.X)
	Water.surface("Water", Vector2.new(endX - waterFrom, Game.RiverWidth), CFrame.new((waterFrom + endX) / 2, 0, 0), model, Water.Color:Lerp(zone.water, 0.25))
	model.Parent = folder
end

return Banks
