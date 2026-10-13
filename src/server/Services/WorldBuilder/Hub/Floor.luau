-- The lobby floor (reference: a bright two-tone green checker), one cell
-- per Lobby.Cell studs (Shared/Util/LobbyGrid), from the back wall to the
-- Throw Zone. The walks on top of it are Hub/Paths.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Worlds = require(Shared.Config.Worlds)
local Lobby = require(Shared.Config.Lobby)
local Game = require(Shared.Config.Game)
local LobbyGrid = require(Shared.Util.LobbyGrid)

local Parts = require(script.Parent.Parent.Parts)
local Style = require(script.Parent.Parent.Style)

local Floor = {}

local MARGIN = 12 -- the slab runs on under the walls

function Floor.build(map: Model, config: Worlds.World, grid: LobbyGrid.Grid)
	local theme = Worlds.theme(config)
	local minX, maxX = Lobby.BackX - MARGIN, Game.RiverOrigin.X
	local sizeZ = (Lobby.HalfZ + MARGIN) * 2
	local slab = Parts.block("Floor", Vector3.new(maxX - minX, 6, sizeZ), CFrame.new((minX + maxX) / 2, Lobby.FloorY - 3, 0), theme.plaza, map)
	-- Light squares on the grass cells (the dark ones are the slab).
	for row = 1, grid.rows do
		for col = 1, grid.cols do
			if LobbyGrid.get(grid, col, row) == "grass" and LobbyGrid.light(col, row) then
				local x, z = LobbyGrid.center(col, row)
				local tile = Parts.block("Tile", Vector3.new(Lobby.Cell, 0.06, Lobby.Cell), CFrame.new(x, Lobby.FloorY + 0.03, z), theme.plazaAlt, slab)
				Style.quiet(tile)
			end
		end
	end
end

return Floor
