-- The lobby floor grid: walks and the spawn plaza are path, the rest grass.
Vector3 = { new = function(x, y, z)
	return { X = x, Y = y, Z = z }
end }

local Lobby = require("@shared/Config/Lobby")
local Game = require("@shared/Config/Game")
local LobbyGrid = require("@shared/Util/LobbyGrid")
local t = require("@test")

local grid = LobbyGrid.build()

t.test("the lobby is a whole number of cells", function()
	t.equal(grid.cols * Lobby.Cell, LobbyGrid.MaxX - LobbyGrid.MinX)
	t.equal(grid.rows * Lobby.Cell, LobbyGrid.MaxZ - LobbyGrid.MinZ)
end)

t.test("the path runs from the spawn to the Throw Zone", function()
	t.equal(LobbyGrid.kindAt(Lobby.Spawn.X, Lobby.Spawn.Z), "path")
	for x = Lobby.Spawn.X, LobbyGrid.MaxX - 1, Lobby.Cell do
		t.equal(LobbyGrid.kindAt(x, 0), "path")
	end
	t.equal(LobbyGrid.kindAt(Lobby.egg(3).X, Lobby.egg(3).Z), "path")
end)

t.test("grass round the path, nothing inside the lane walls", function()
	t.equal(LobbyGrid.kindAt(-60, 20), "grass")
	t.equal(LobbyGrid.kindAt(Lobby.FrontX + 2, Game.RiverWidth / 2 + 2), "void")
end)

t.test("path rectangles cover every path cell exactly once", function()
	local covered = {}
	for _, rect in LobbyGrid.pathRects(grid) do
		for row = rect[2], rect[2] + rect[4] - 1 do
			for col = rect[1], rect[1] + rect[3] - 1 do
				local i = (row - 1) * grid.cols + col
				assert(not covered[i], "cell covered twice")
				t.equal(LobbyGrid.get(grid, col, row), "path")
				covered[i] = true
			end
		end
	end
	for i, kind in grid.kinds do
		t.equal(covered[i] == true, kind == "path")
	end
end)
