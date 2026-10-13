-- The lobby floor (reference: bright green checker), from the back wall to
-- the water. The Throw Zone strip (ThrowZone) covers its last stretch.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Worlds = require(Shared.Config.Worlds)
local Lobby = require(Shared.Config.Lobby)
local Game = require(Shared.Config.Game)

local Parts = require(script.Parent.Parent.Parts)
local Style = require(script.Parent.Parent.Style)

local Floor = {}

local CELL = 8
local MARGIN = 12 -- the slab runs on under the walls

function Floor.build(map: Model, config: Worlds.World)
	local theme = Worlds.theme(config)
	local minX, maxX = Lobby.BackX - MARGIN, Game.RiverOrigin.X
	local sizeZ = (Lobby.HalfZ + MARGIN) * 2
	local slab = Parts.block("Floor", Vector3.new(maxX - minX, 6, sizeZ), CFrame.new((minX + maxX) / 2, Lobby.FloorY - 3, 0), theme.plaza, map)
	-- Checker over the courtyard and the entry between the lane's walls.
	local inner = Lobby.FrontX - Lobby.BackX
	Style.checkerFloor(CFrame.new((Lobby.BackX + Lobby.FrontX) / 2, Lobby.FloorY, 0), Vector2.new(inner, Lobby.HalfZ * 2), CELL, theme.plazaAlt, slab)
	local entryEnd = Game.hopZoneCenter().X - Game.HopZoneSizeX / 2
	Style.checkerFloor(
		CFrame.new((Lobby.FrontX + entryEnd) / 2, Lobby.FloorY, 0),
		Vector2.new(entryEnd - Lobby.FrontX, Game.RiverWidth),
		CELL,
		theme.plazaAlt,
		slab
	)
end

return Floor
