-- A gym's body (Util/GymGrid): a raised border in the gym's colour with a
-- light outline and a gap at the front to step in, the theme's two-tone
-- ground checker, and the pool (Water) tinted toward the gym's colour.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Ponds = require(Shared.Config.Ponds)
local GymGrid = require(Shared.Util.GymGrid)

local Parts = require(script.Parent.Parent.Parts)
local Style = require(script.Parent.Parent.Style)
local Water = require(script.Parent.Parent.Water)
local Themes = require(script.Parent.Themes)

local Ground = {}

local WALK_TOP = Ponds.SurfaceY + 0.25 -- the lavender walk under the row (Hub/Paths)
local BOTTOM = WALK_TOP - 0.2
local RISE = 0.6 -- ground above the walk
local LIP = 0.45 -- border above the ground
local DEPTH = 0.45 -- water below the ground
local OUTLINE = 0.6

local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.new(0, 0, 0)

export type Levels = { ground: number, water: number }

-- Boxes { x, z, size x, size z } relative to the gym's centre.
local function boxes(list: { { number } }, name: string, y0: number, y1: number, color: Color3, center: Vector3, model: Model, quiet: boolean?)
	for _, s in list do
		local part = Parts.block(name, Vector3.new(s[3], y1 - y0, s[4]), CFrame.new(center.X + s[1], (y0 + y1) / 2, center.Z + s[2]), color, model)
		if quiet then
			Style.quiet(part)
		end
	end
end

local function rim(pond: Ponds.Pond, center: Vector3, ground: number, model: Model)
	local w, l, r = Ponds.WidthX, Ponds.LengthZ, Ponds.Rim
	boxes({
		{ 0, -(l - r) / 2, w, r },
		{ 0, (l - r) / 2, w, r },
		{ -(w - r) / 2, 0, r, l - 2 * r },
		{ (w - r) / 2, 0, r, l - 2 * r },
	}, "Rim", BOTTOM, ground, pond.color:Lerp(BLACK, 0.3), center, model)
	-- The raised lip, open across the stand pad at the front so you step in.
	local front = (w - Ponds.StandSize) / 2
	boxes({
		{ 0, (l - r) / 2, w, r },
		{ -(w - r) / 2, 0, r, l - 2 * r },
		{ (w - r) / 2, 0, r, l - 2 * r },
		{ -(w - front) / 2, -(l - r) / 2, front, r },
		{ (w - front) / 2, -(l - r) / 2, front, r },
	}, "Lip", ground, ground + LIP, pond.color, center, model)
	-- A light outline round its outside edge.
	local top = ground + LIP
	boxes({
		{ 0, (l - OUTLINE) / 2, w, OUTLINE },
		{ -(w - OUTLINE) / 2, 0, OUTLINE, l },
		{ (w - OUTLINE) / 2, 0, OUTLINE, l },
		{ -(w - front) / 2, -(l - OUTLINE) / 2, front, OUTLINE },
		{ (w - front) / 2, -(l - OUTLINE) / 2, front, OUTLINE },
	}, "Outline", top, top + 0.06, pond.color:Lerp(WHITE, 0.45), center, model, true)
end

-- Builds gym `pond`'s rim, ground and pool into `model`; returns the ground
-- and water heights.
function Ground.build(pond: Ponds.Pond, theme: Themes.Theme, model: Model): Levels
	local center = Ponds.center(pond)
	local ground = WALK_TOP + RISE
	local water = ground - DEPTH
	local cell = GymGrid.Cell
	rim(pond, center, ground, model)

	-- A grid rectangle { col, row, cols, rows } as a box relative to the centre.
	local function box(r: { number }): { number }
		local x0, z0 = GymGrid.offset(r[1], r[2])
		local w, d = r[3] * cell, r[4] * cell
		return { x0 - cell / 2 + w / 2, z0 - cell / 2 + d / 2, w, d }
	end
	local solid = {}
	for _, kind in { "ground", "pad" } do
		for _, r in GymGrid.rects(kind) do
			table.insert(solid, box(r))
		end
	end
	boxes(solid, "Ground", BOTTOM, ground, theme.ground[1], center, model)
	for _, c in GymGrid.cells("ground") do
		if GymGrid.light(c[1], c[2]) then
			local x, z = GymGrid.offset(c[1], c[2])
			Style.quiet(Parts.block("Tile", Vector3.new(cell, 0.06, cell), CFrame.new(center.X + x, ground + 0.03, center.Z + z), theme.ground[2], model))
		end
	end

	local tint = Water.Color:Lerp(pond.color, 0.3)
	for _, r in GymGrid.rects("pool") do
		local b = box(r)
		Water.surface("Pool", Vector2.new(b[3], b[4]), CFrame.new(center.X + b[1], water, center.Z + b[2]), model, tint, 14)
	end
	return { ground = ground, water = water }
end

return Ground
