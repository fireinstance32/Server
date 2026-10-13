-- The hub floor west of the lane: a studded checker of the world's two
-- grass colours (reference: bright green checker with studs).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Worlds = require(ReplicatedStorage:WaitForChild("Shared").Config.Worlds)

local Parts = require(script.Parent.Parent.Parts)
local Style = require(script.Parent.Parent.Style)

local Floor = {}

-- Hub floor bounds (local studs): x from MinX to the lane at 0, z ±HalfZ.
Floor.MinX = -260
Floor.HalfZ = 190
local CELL = 16

function Floor.build(world: Model, config: Worlds.World)
	local theme = Worlds.theme(config)
	local sizeX, sizeZ = -Floor.MinX, Floor.HalfZ * 2
	local centre = CFrame.new(Floor.MinX / 2, Parts.GroundTop - 3, 0)
	local plaza = Parts.block("Plaza", Vector3.new(sizeX, 6, sizeZ), centre, theme.plaza, world)
	Style.studs(plaza)
	local checker = Instance.new("Folder")
	checker.Name = "Checker"
	Style.checkerFloor(CFrame.new(Floor.MinX / 2, Parts.GroundTop, 0), Vector2.new(sizeX, sizeZ), CELL, theme.plazaAlt, checker)
	checker.Parent = world
end

return Floor
