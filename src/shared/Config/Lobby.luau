--!strict
-- The lobby (hub) layout in world-local studs; Config/Worlds moves each world
-- to its offset. Reference: the "+1 Stone Skipping" lobby, a small walled
-- courtyard behind the Throw Zone. The throw lane runs along +X from x = 0.
-- Everything sits on a Cell-stud grid so the floor checker, the paths and
-- their borders line up.
--
--   x = -20..0      the Throw Zone strip at the water (Config/Game)
--   x = -24..-20    the entry between the lane's walls
--   +Z side         the gym row on a lavender walk (Config/Ponds)
--   -Z side         the rock shelf (stepped, rows of 6) and the portals
--   back            eggs in front of the leaderboards and two waterfalls
--   spawn           on a round plaza on the path to the Throw Zone

local Lobby = {}

Lobby.Cell = 4 -- floor checker / path grid (studs)

-- Inner faces of the walls.
Lobby.BackX = -172
Lobby.FrontX = -24
Lobby.HalfZ = 84
Lobby.FloorY = 0.5

Lobby.Spawn = Vector3.new(-112, 0.5, 0)
Lobby.SpawnPlazaRadius = 18

-- Eggs: a row across the back, slot 1 at -Z.
function Lobby.egg(slot: number): Vector3
	return Vector3.new(-152, 0, -36 + (slot - 1) * 18)
end

-- Rock shelf: stepped rows of 6 along the -Z wall, cheapest row in front.
Lobby.ShelfColumns = 6
Lobby.ShelfRows = 3
Lobby.ShelfStepX = 12 -- column spacing
Lobby.ShelfStepZ = 10 -- row depth
Lobby.ShelfRise = 2.5 -- each row is this much higher than the one in front
Lobby.ShelfStartX = -98
Lobby.ShelfFrontZ = -44

-- Top of shelf row `row` (0 = front).
function Lobby.shelfTop(row: number): number
	return Lobby.FloorY + (row + 1) * Lobby.ShelfRise
end

-- Where the index-th rock's podium stands (on its row's step).
function Lobby.shelf(index: number): Vector3
	local col = (index - 1) % Lobby.ShelfColumns
	local row = (index - 1) // Lobby.ShelfColumns
	local z = Lobby.ShelfFrontZ - (row + 0.5) * Lobby.ShelfStepZ
	return Vector3.new(Lobby.ShelfStartX + col * Lobby.ShelfStepX, Lobby.shelfTop(row), z)
end

-- Portals to the other worlds: a row along the -Z wall beside the shelf,
-- facing into the lobby (+Z).
function Lobby.portal(slot: number): Vector3
	return Vector3.new(-160 + (slot - 1) * 14, Lobby.FloorY, -74)
end

-- Leaderboards against the back wall, facing the lobby (+X).
function Lobby.board(index: number): Vector3
	return Vector3.new(-168, 0, -34 + (index - 1) * 34)
end

-- Waterfalls down the back wall, between the boards.
Lobby.Waterfalls = { -17, 17 }

-- Lavender walks (the paths) as grid-aligned rectangles { x0, z0, x1, z1 },
-- plus the round spawn plaza. Hub/Floor turns them into checker paths with
-- a border wherever they meet grass.
Lobby.Walks = {
	{ -144, -8, -20, 8 }, -- eggs → spawn → Throw Zone
	{ -160, -48, -144, 48 }, -- in front of the eggs and boards
	{ -116, -44, -108, 40 }, -- shelf → spawn → gyms
	{ -172, 40, -24, 84 }, -- the gym row
	{ -108, -44, -28, -36 }, -- along the front of the shelf
	{ -172, -84, -108, -64 }, -- the portals
}

return Lobby
