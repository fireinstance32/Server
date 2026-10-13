-- Gym equipment around each gym's stand pad (imported Blender props, see
-- Parts.prop): a lifting platform on the pad itself, a loaded rack, a plate
-- tree, dumbbells and a kettlebell. Coloured by the gym. All
-- visual: nothing here changes how training works, and without the import
-- the gym keeps its plain pad.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Ponds = require(Shared.Config.Ponds)

local Parts = require(script.Parent.Parts)

local GymKit = {}

-- name, width (studs), offset from the stand pad's centre (X, Z), turn
-- (degrees). The rack stands behind the player (+Z, by the wall).
local LAYOUT: { { any } } = {
	{ "BarbellRack", 8, 0, 7, 0 },
	{ "PlateTree", 3, -5, 7, 0 },
	{ "Kettlebell", 2, 5, 7.5, 0 },
	{ "Dumbbell", 2.4, -5, -3, 20 },
	{ "Dumbbell", 2.4, 5, -3, -20 },
}

-- Dresses gym `pond` (its platform top at `floorY`) around its stand pad.
function GymKit.decorate(pond: Ponds.Pond, model: Model, pad: BasePart, floorY: number)
	local stand = Ponds.standPosition(pond)
	local floor = Vector3.new(stand.X, floorY, stand.Z)
	if Parts.prop("LiftPlatform", pond.color, 7, CFrame.new(floor), model) then
		-- The platform is the pad's look; the pad keeps the PondId and its collision.
		pad.Transparency = 1
	end
	for _, item in LAYOUT do
		local name, width, x, z, turn = item[1], item[2], item[3], item[4], item[5]
		Parts.prop(name, pond.color, width, CFrame.new(floor + Vector3.new(x, 0, z)) * CFrame.Angles(0, math.rad(turn), 0), model)
	end
end

return GymKit
