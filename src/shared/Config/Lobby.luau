--!strict
-- The lobby (hub) layout in world-local studs; Config/Worlds moves each world
-- to its offset. Reference: the "+1 Stone Skipping" lobby, a small walled
-- courtyard behind the Throw Zone. The throw lane runs along +X from x = 0.
--
--   x = -16..0      the Throw Zone strip at the water (Config/Game)
--   x = -26..-16    the entry between the lane's walls
--   +Z side         the gym row (Config/Ponds)
--   -Z side         the rock shelf (stepped, rows of 6) and the portals
--   back            eggs in front of the leaderboards and two waterfalls
--   spawn           in the middle, on the path to the Throw Zone

local Lobby = {}

-- Inner faces of the walls.
Lobby.BackX = -160
Lobby.FrontX = -26
Lobby.HalfZ = 70
Lobby.FloorY = 0.5

Lobby.Spawn = Vector3.new(-118, 0.5, 0)

-- Eggs: a row across the back, slot 1 at -Z.
function Lobby.egg(slot: number): Vector3
	return Vector3.new(-138, 0, -36 + (slot - 1) * 18)
end

-- Rock shelf: stepped rows of 6 along the -Z wall, cheapest row in front.
Lobby.ShelfColumns = 6
Lobby.ShelfRows = 3
Lobby.ShelfStepX = 12 -- column spacing
Lobby.ShelfStepZ = 10 -- row depth
Lobby.ShelfRise = 2.5 -- each row is this much higher than the one in front
Lobby.ShelfStartX = -96
Lobby.ShelfFrontZ = -35

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

-- Portals to the other worlds: a row along the -Z wall behind the shelf,
-- facing into the lobby (+Z).
function Lobby.portal(slot: number): Vector3
	return Vector3.new(-153 + (slot - 1) * 13, Lobby.FloorY, -62)
end

-- Leaderboards against the back wall, facing the lobby (+X).
function Lobby.board(index: number): Vector3
	return Vector3.new(-156, 0, -34 + (index - 1) * 34)
end

-- Waterfalls down the back wall, between the boards.
Lobby.Waterfalls = { -17, 17 }

return Lobby
