--!strict
-- The inside of a gym (Config/Ponds) as a grid of Cell-stud cells inside its
-- rim: the stand pad at the front (where training locks you in place), an
-- irregular pool behind it, and themed ground round both. Row 1 is at the
-- front (-Z, the lobby side), column 1 at -X. Pure, so it's unit-tested;
-- WorldBuilder/PondRow draws it.

local Ponds = require(script.Parent.Parent.Config.Ponds)
local GridRects = require(script.Parent.GridRects)

local GymGrid = {}

export type Kind = "pad" | "pool" | "ground"

GymGrid.Cell = 2
GymGrid.Rim = Ponds.Rim
GymGrid.Cols = math.round((Ponds.WidthX - 2 * Ponds.Rim) / GymGrid.Cell)
GymGrid.Rows = math.round((Ponds.LengthZ - 2 * Ponds.Rim) / GymGrid.Cell)

-- The stand pad: Ponds.StandSize square, centred across, at the front.
local PAD_CELLS = Ponds.StandSize / GymGrid.Cell
local PAD_COL = (GymGrid.Cols - PAD_CELLS) // 2 + 1

-- The pool, row by row behind the pad: { first column, last column }.
local POOL: { [number]: { number } } = {
	[6] = { 2, 4 },
	[7] = { 2, 5 },
	[8] = { 1, 5 },
	[9] = { 1, 6 },
	[10] = { 1, 6 },
	[11] = { 2, 6 },
	[12] = { 2, 5 },
	[13] = { 3, 5 },
	[14] = { 3, 4 },
}

function GymGrid.kind(col: number, row: number): Kind
	if row <= PAD_CELLS and col >= PAD_COL and col < PAD_COL + PAD_CELLS then
		return "pad"
	end
	local span = POOL[row]
	if span and col >= span[1] and col <= span[2] then
		return "pool"
	end
	return "ground"
end

-- Offset (x, z) of cell (col, row)'s centre from the gym's centre.
function GymGrid.offset(col: number, row: number): (number, number)
	local cell = GymGrid.Cell
	return -GymGrid.Cols * cell / 2 + (col - 0.5) * cell, -GymGrid.Rows * cell / 2 + (row - 0.5) * cell
end

function GymGrid.light(col: number, row: number): boolean
	return (col + row) % 2 == 0
end

-- Cells of `kind` merged into rectangles { col, row, cols, rows }.
function GymGrid.rects(kind: Kind): { { number } }
	return GridRects(GymGrid.Cols, GymGrid.Rows, function(col, row)
		return GymGrid.kind(col, row) == kind
	end)
end

-- Cells of `kind` (col, row pairs), e.g. to scatter decor on.
function GymGrid.cells(kind: Kind): { { number } }
	local out = {}
	for row = 1, GymGrid.Rows do
		for col = 1, GymGrid.Cols do
			if GymGrid.kind(col, row) == kind then
				table.insert(out, { col, row })
			end
		end
	end
	return out
end

-- Ground cells next to the pool (for reeds and the like).
function GymGrid.shore(): { { number } }
	local out = {}
	for _, cell in GymGrid.cells("ground") do
		local col, row = cell[1], cell[2]
		for _, step in { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
			local c, r = col + step[1], row + step[2]
			if c >= 1 and r >= 1 and c <= GymGrid.Cols and r <= GymGrid.Rows and GymGrid.kind(c, r) == "pool" then
				table.insert(out, cell)
				break
			end
		end
	end
	return out
end

return GymGrid
