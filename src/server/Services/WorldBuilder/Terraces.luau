-- Terraced checker walls (reference): two tiers, each a solid block in the
-- dark wall colour with a grass cap, light checker tiles on the face it
-- shows, and a grass checker on the first tier's ledge. The lobby walls and
-- the throw lane's banks are both made of these.

local Parts = require(script.Parent.Parts)
local Style = require(script.Parent.Style)

local Terraces = {}

-- Depth (outward) and top (Y) of each tier; the last one reaches far back.
Terraces.Tiers = {
	{ depth = 10, top = 10.5 },
	{ depth = 80, top = 20.5 },
}
local BOTTOM = -8 -- blocks reach down under the floor / riverbed
local CAP = 1 -- grass cap thickness (it shows as a grass edge above the checker)
local LEDGE_CELL = 5

export type Run = {
	name: string,
	-- At the start of the wall's foot line, y = 0. X runs along the wall,
	-- Z points outward (away from the open side), so LookVector faces in.
	frame: CFrame,
	length: number,
	faceBottom: number, -- Y where the first tier's face starts showing (floor or water)
	extendStart: boolean?, -- an inner corner at the start (the next wall turns in)
	extendEnd: boolean?,
	capStart: number?, -- checker end faces at the start, this far out (the lane's end facing the lobby)
	capEnd: number?,
	wall: { Color3 }, -- dark, light
	grass: Color3,
	ledge: Color3, -- the light squares of the first tier's grass checker
	cell: Vector2?, -- wall checker cell (width, height)
}

-- End faces across the run at local x = `x`, looking along `-dir * X`. Each
-- tier's end is open from the bottom up (nothing stands in front of it).
local function endCap(run: Run, model: Model, x: number, dir: number, reach: number, cell: Vector2)
	local offset = 0
	for _, tier in Terraces.Tiers do
		local width = math.min(tier.depth, reach - offset)
		if width <= 0 then
			break
		end
		local height = tier.top - CAP - run.faceBottom
		local centre = run.frame * CFrame.new(x, run.faceBottom + height / 2, offset + width / 2)
		local face = CFrame.lookAt(centre.Position, centre.Position - run.frame.XVector * dir)
		Style.checkerTiles(face, Vector2.new(width, height), cell, run.wall[2], model)
		offset += tier.depth
	end
end

function Terraces.build(run: Run, parent: Instance): Model
	local model = Instance.new("Model")
	model.Name = run.name
	local cell = run.cell or Vector2.new(6, 4.75)
	local offset = 0
	local below = run.faceBottom
	for i, tier in Terraces.Tiers do
		-- The block reaches round inner corners; its visible face stops where
		-- the other wall's face of the same tier begins.
		local x0 = if run.extendStart then -(offset + tier.depth) else 0
		local x1 = run.length + if run.extendEnd then offset + tier.depth else 0
		local midZ = offset + tier.depth / 2
		local body = tier.top - CAP - BOTTOM
		Parts.block(`Tier{i}`, Vector3.new(x1 - x0, body, tier.depth), run.frame * CFrame.new((x0 + x1) / 2, BOTTOM + body / 2, midZ), run.wall[1], model)
		Parts.block("Grass", Vector3.new(x1 - x0, CAP, tier.depth), run.frame * CFrame.new((x0 + x1) / 2, tier.top - CAP / 2, midZ), run.grass, model)

		local f0 = if run.extendStart then -offset else 0
		local f1 = run.length + if run.extendEnd then offset else 0
		local height = tier.top - CAP - below
		local face = run.frame * CFrame.new((f0 + f1) / 2, below + height / 2, offset)
		Style.checkerTiles(face, Vector2.new(f1 - f0, height), cell, run.wall[2], model)
		if i == 1 then
			local top = run.frame * CFrame.new((f0 + f1) / 2, tier.top, midZ)
			Style.checkerFloor(top, Vector2.new(f1 - f0, tier.depth), LEDGE_CELL, run.ledge, model)
		end
		below = tier.top
		offset += tier.depth
	end
	if run.capStart then
		endCap(run, model, 0, 1, run.capStart, cell)
	end
	if run.capEnd then
		endCap(run, model, run.length, -1, run.capEnd, cell)
	end
	model.Parent = parent
	return model
end

-- A point on top of tier `tier` of `run`, `along` studs from its start and
-- `out` studs into the tier (0 = its front edge).
function Terraces.point(run: Run, along: number, tier: number, out: number): Vector3
	local offset = 0
	for i = 1, tier - 1 do
		offset += Terraces.Tiers[i].depth
	end
	return (run.frame * CFrame.new(along, Terraces.Tiers[tier].top, offset + out)).Position
end

return Terraces
