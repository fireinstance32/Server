-- The lavender walks (reference): a raised two-tone lavender checker on the
-- same grid as the grass (Shared/Util/LobbyGrid), a darker raised border
-- wherever a walk meets grass, and dark chevrons down the main walk
-- pointing at the Throw Zone.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Lobby = require(Shared.Config.Lobby)
local LobbyGrid = require(Shared.Util.LobbyGrid)

local Parts = require(script.Parent.Parent.Parts)
local Style = require(script.Parent.Parent.Style)

local Paths = {}

local DARK = Color3.fromRGB(174, 162, 238)
local LIGHT = Color3.fromRGB(198, 190, 248)
local BORDER = Color3.fromRGB(126, 106, 208)
local CHEVRON = Color3.fromRGB(58, 50, 92)

local RAISE = 0.25 -- walk top above the grass
local BORDER_WIDTH = 0.9
local BORDER_RAISE = 0.3 -- border top above the walk

-- Grid sides: column/row step and which way the border strip runs.
local SIDES = {
	{ dc = 1, dr = 0 },
	{ dc = -1, dr = 0 },
	{ dc = 0, dr = 1 },
	{ dc = 0, dr = -1 },
}

local function borders(grid: LobbyGrid.Grid, top: number, parent: Instance)
	local cell = Lobby.Cell
	for _, side in SIDES do
		local along = side.dc ~= 0 -- runs along Z (row direction) when the side faces ±X
		local outer = if along then grid.cols else grid.rows
		local inner = if along then grid.rows else grid.cols
		for a = 1, outer do
			local b = 1
			while b <= inner do
				local function edge(i: number): boolean
					local col, row = if along then a else i, if along then i else a
					return LobbyGrid.get(grid, col, row) == "path" and LobbyGrid.get(grid, col + side.dc, row + side.dr) == "grass"
				end
				if edge(b) then
					local length = 1
					while b + length <= inner and edge(b + length) do
						length += 1
					end
					-- The strip sits inside the walk, along the shared edge.
					local col0, row0 = if along then a else b, if along then b else a
					local x, z = LobbyGrid.center(col0, row0)
					local run = (length - 1) * cell
					local size, at
					if along then
						size = Vector3.new(BORDER_WIDTH, BORDER_RAISE, run + cell)
						at = Vector3.new(x + side.dc * (cell - BORDER_WIDTH) / 2, top + BORDER_RAISE / 2, z + run / 2)
					else
						size = Vector3.new(run + cell, BORDER_RAISE, BORDER_WIDTH)
						at = Vector3.new(x + run / 2, top + BORDER_RAISE / 2, z + side.dr * (cell - BORDER_WIDTH) / 2)
					end
					Parts.block("Border", size, CFrame.new(at), BORDER, parent)
					b += length
				else
					b += 1
				end
			end
		end
	end
end

local function chevrons(fromX: number, toX: number, y: number, parent: Instance)
	for x = fromX, toX, 10 do
		local at = CFrame.new(x, y, 0)
		for _, s in { -1, 1 } do
			-- Two bars meeting at the tip: a ">" pointing at the water (+X).
			local bar = Parts.block("Chevron", Vector3.new(5.5, 0.06, 1.5), at * CFrame.new(-1.8, 0, s * 2) * CFrame.Angles(0, s * math.rad(42), 0), CHEVRON, parent)
			Style.quiet(bar)
		end
	end
end

function Paths.build(map: Model, grid: LobbyGrid.Grid)
	local folder = Instance.new("Folder")
	folder.Name = "Paths"
	local cell = Lobby.Cell
	local top = Lobby.FloorY + RAISE
	for _, rect in LobbyGrid.pathRects(grid) do
		local x0, z0 = LobbyGrid.center(rect[1], rect[2])
		local w, d = rect[3] * cell, rect[4] * cell
		Parts.block("Walk", Vector3.new(w, RAISE + 1, d), CFrame.new(x0 - cell / 2 + w / 2, top - (RAISE + 1) / 2, z0 - cell / 2 + d / 2), DARK, folder)
	end
	for row = 1, grid.rows do
		for col = 1, grid.cols do
			if LobbyGrid.get(grid, col, row) == "path" and LobbyGrid.light(col, row) then
				local x, z = LobbyGrid.center(col, row)
				Style.quiet(Parts.block("Tile", Vector3.new(cell, 0.06, cell), CFrame.new(x, top + 0.03, z), LIGHT, folder))
			end
		end
	end
	borders(grid, top, folder)
	chevrons(Lobby.Spawn.X + Lobby.SpawnPlazaRadius + 8, LobbyGrid.MaxX - 6, top + 0.07, folder)
	folder.Parent = map
end

return Paths
