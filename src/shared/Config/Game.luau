--!strict
-- Global tuning knobs for +1 Frog Hop. Balance lives here, not in services.

local Game = {}

Game.DataStoreName = "FrogHop_PlayerData_v1"
Game.AutosaveInterval = 120

-- World layout (studs). The river runs along +X starting at RiverOrigin.
Game.RiverOrigin = Vector3.new(0, 0, 0)
Game.RiverWidth = 44
Game.PadSpacing = 12

-- Where players stand to use each mode, and how close they must be.
Game.LaunchDock = Vector3.new(-14, 0, 0)
Game.TrainingPond = Vector3.new(-70, 0.5, 60) -- Y = plaza surface
Game.UseRadius = 22

-- Training: a short hop session in the small pond.
Game.TrainingBounces = 5
Game.TrainingCooldown = 0.6

-- Distance curve: distance = Base + Scale * Hops ^ Exponent (studs).
Game.DistanceBase = 20
Game.DistanceScale = 6
Game.DistanceExponent = 0.5

-- Flight animation pacing (shared so server cooldowns match client visuals).
Game.MaxVisualHops = 40
Game.SecondsPerVisualHop = 0.18
Game.LandingPause = 0.6

-- Pets
Game.MaxEquippedPets = 3
Game.MaxPetInventory = 50

-- Each rebirth adds this much to the Hops multiplier (1 = +1x, so 1 rebirth
-- = x2, 2 rebirths = x3), matching the reference game.
Game.RebirthHopsBonus = 1

function Game.distanceForHops(hops: number): number
	return Game.DistanceBase + Game.DistanceScale * math.max(hops, 0) ^ Game.DistanceExponent
end

-- Lily pad i (1-based) on the river. Shared so the world and the hop
-- animation agree on where every pad is.
function Game.padPosition(i: number): Vector3
	return Game.RiverOrigin + Vector3.new(i * Game.PadSpacing, 0.3, math.sin(i * 0.7) * 6)
end

-- Pads in the training pond sit on a ring.
Game.TrainingPadCount = 8
Game.TrainingPondRadius = 26
function Game.trainingPadPosition(i: number): Vector3
	local angle = (i / Game.TrainingPadCount) * math.pi * 2
	return Game.TrainingPond + Vector3.new(math.cos(angle) * 14, 0.3, math.sin(angle) * 14)
end

function Game.flightTime(bounces: number): number
	local visualHops = math.clamp(bounces, 1, Game.MaxVisualHops)
	return visualHops * Game.SecondsPerVisualHop + Game.LandingPause
end

return Game
