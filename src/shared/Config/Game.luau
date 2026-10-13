--!strict
-- Global tuning knobs for +1 Frog Hop. Balance lives here, not in services.

local Game = {}

Game.DataStoreName = "FrogHop_PlayerData_v1"
Game.AutosaveInterval = 120

-- World layout (studs). The river runs along +X starting at RiverOrigin.
Game.RiverOrigin = Vector3.new(0, 0, 0)
Game.RiverWidth = 64
Game.PadSpacing = 12

-- Hop Zone: the painted strip at the water's edge where players stand to
-- throw (reference: "THROW ZONE"), as wide as the lane. X × Z studs.
-- (Training happens at the gyms in Config/Ponds; lobby layout: Config/Lobby.)
Game.HopZoneCenterX = -10 -- x = -20..0, right at the water
Game.HopZoneCenterZ = 0
Game.HopZoneSizeX = 20
Game.HopZoneSizeZ = Game.RiverWidth

Game.WalkSpeed = 24 -- every character's walk speed (Roblox default is 16)

-- The hold-and-toss: wind-up before the frog leaves the hand (seconds).
Game.TossWindup = 0.35

-- Training: a short hop session on a training pond.
Game.TrainingBounces = 5
Game.TrainingCooldown = 0.6

-- (How far a throw goes: Config/Zones.distanceForStrength.)

-- Distance shown to players in metres (studs × MetersPerStud).
Game.MetersPerStud = 0.5

function Game.metersFor(studs: number): number
	return math.floor(math.max(studs, 0) * Game.MetersPerStud)
end

-- Flight animation pacing (shared so server cooldowns match client visuals).
Game.MaxVisualHops = 40
Game.SecondsPerVisualHop = 0.18
Game.LandingPause = 0.6

-- Offline training: while logged out you keep training at a fraction of
-- the online rate (online ≈ 8 pads/s), capped at OfflineMaxHours.
Game.OfflinePadsPerSecond = 0.8
Game.OfflineMaxHours = 8
Game.OfflineMinSeconds = 60 -- shorter breaks don't count

function Game.offlineHops(seconds: number, perBounce: number, multiplier: number, doubled: boolean): number
	if seconds < Game.OfflineMinSeconds then
		return 0
	end
	local capped = math.min(seconds, Game.OfflineMaxHours * 3600)
	local hops = capped * Game.OfflinePadsPerSecond * perBounce * multiplier
	return math.floor(if doubled then hops * 2 else hops)
end

-- Friend Boost: +FriendBoostEach per friend in the server, up to the max.
Game.FriendBoostEach = 0.1
Game.FriendBoostMax = 0.5

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
