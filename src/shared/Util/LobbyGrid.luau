--!strict
-- The lobby floor as a grid of Lobby.Cell-stud cells (Config/Lobby): each
-- cell is grass, path (a lavender walk or the round spawn plaza) or void
-- (inside the lane's walls beside the entry). Pure, so it's unit-tested;
-- WorldBuilder/Hub/Floor and Hub/Paths draw it.

local Lobby = require(script.Parent.Parent.Config.Lobby)
local Game = require(script.Parent.Parent.Config.Game)
local GridRects = require(script.Parent.GridRects)

local LobbyGrid = {}

export type Kind = "grass" | "path" | "void"
export type Grid = {
	cols: number,
	rows: number,
	kinds: { Kind }, -- index (row - 1) * cols + col
}

-- The grid runs from the back wall to the Throw Zone and across the lobby.
LobbyGrid.MinX = Lobby.BackX
LobbyGrid.MaxX = Game.HopZoneCenterX - Game.HopZoneSizeX / 2
LobbyGrid.MinZ = -Lobby.HalfZ
LobbyGrid.MaxZ = Lobby.HalfZ

-- Centre (x, z) of cell (col, row), 1-based.
function LobbyGrid.center(col: number, row: number): (number, number)
	return LobbyGrid.MinX + (col - 0.5) * Lobby.Cell, LobbyGrid.MinZ + (row - 0.5) * Lobby.Cell
end

-- What the floor is at (x, z).
function LobbyGrid.kindAt(x: number, z: number): Kind
	if x > Lobby.FrontX and math.abs(z) > Game.RiverWidth / 2 then
		return "void"
	end
	for _, walk in Lobby.Walks do
		if x >= walk[1] and x <= walk[3] and z >= walk[2] and z <= walk[4] then
			return "path"
		end
	end
	local dx, dz = x - Lobby.Spawn.X, z - Lobby.Spawn.Z
	if dx * dx + dz * dz <= Lobby.SpawnPlazaRadius ^ 2 then
		return "path"
	end
	return "grass"
end

function LobbyGrid.build(): Grid
	local cols = math.round((LobbyGrid.MaxX - LobbyGrid.MinX) / Lobby.Cell)
	local rows = math.round((LobbyGrid.MaxZ - LobbyGrid.MinZ) / Lobby.Cell)
	local kinds: { Kind } = {}
	for row = 1, rows do
		for col = 1, cols do
			kinds[(row - 1) * cols + col] = LobbyGrid.kindAt(LobbyGrid.center(col, row))
		end
	end
	return { cols = cols, rows = rows, kinds = kinds }
end

-- The kind of cell (col, row), or nil off the grid.
function LobbyGrid.get(grid: Grid, col: number, row: number): Kind?
	if col < 1 or row < 1 or col > grid.cols or row > grid.rows then
		return nil
	end
	return grid.kinds[(row - 1) * grid.cols + col]
end

-- The checker colour of a cell: true for the light squares.
function LobbyGrid.light(col: number, row: number): boolean
	return (col + row) % 2 == 1
end

-- Path cells merged into rectangles { col, row, cols, rows } (Util/GridRects),
-- so a walk is a few parts.
function LobbyGrid.pathRects(grid: Grid): { { number } }
	return GridRects(grid.cols, grid.rows, function(col, row)
		return LobbyGrid.get(grid, col, row) == "path"
	end)
end

return LobbyGrid
