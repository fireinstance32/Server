--!strict
-- Global tuning knobs for +1 Frog Hop. Balance lives here, not in services.

local Game = {}

Game.DataStoreName = "FrogHop_PlayerData_v1"
Game.AutosaveInterval = 120

-- World layout (studs). The river runs along +X starting at RiverOrigin.
Game.RiverOrigin = Vector3.new(0, 0, 0)
Game.RiverWidth = 44
Game.PadSpacing = 12

-- Hop Zone: the painted strip at the river start where players stand to
-- launch (reference: "THROW ZONE"). A rectangle on the plaza, X × Z studs.
-- (Training happens at the ponds in Config/Ponds.)
Game.HopZoneCenterX = -14
Game.HopZoneCenterZ = 0
Game.HopZoneSizeX = 24
Game.HopZoneSizeZ = 44

-- The hold-and-toss: wind-up before the frog leaves the hand (seconds).
Game.TossWindup = 0.35

-- Training: a short hop session on a training pond.
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

-- True when (x, z) is inside the Hop Zone. Plain numbers so it's testable.
function Game.inHopZone(x: number, z: number): boolean
	return math.abs(x - Game.HopZoneCenterX) <= Game.HopZoneSizeX / 2
		and math.abs(z - Game.HopZoneCenterZ) <= Game.HopZoneSizeZ / 2
end

function Game.hopZoneCenter(): Vector3
	return Vector3.new(Game.HopZoneCenterX, 0, Game.HopZoneCenterZ)
end

function Game.distanceForHops(hops: number): number
	return Game.DistanceBase + Game.DistanceScale * math.max(hops, 0) ^ Game.DistanceExponent
end

-- Lily pad i (1-based) on the river. Shared so the world and the hop
-- animation agree on where every pad is.
function Game.padPosition(i: number): Vector3
	return Game.RiverOrigin + Vector3.new(i * Game.PadSpacing, 0.3, math.sin(i * 0.7) * 6)
end

function Game.flightTime(bounces: number): number
	local visualHops = math.clamp(bounces, 1, Game.MaxVisualHops)
	return Game.TossWindup + visualHops * Game.SecondsPerVisualHop + Game.LandingPause
end

return Game
