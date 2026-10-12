--!strict
-- Level system. XP comes from pads hopped (training bounces and river pads),
-- not from Hops, so multipliers don't make levels trivial. Each rebirth raises
-- the level cap; reaching the cap ("MAX LEVEL") is what unlocks the next
-- rebirth. Pure functions only: unit-tested offline.

local Levels = {}

Levels.BaseXp = 10 -- XP to go from level 1 to 2
Levels.Growth = 1.15 -- each level needs 15% more XP than the last
Levels.CapBase = 20 -- max level before the first rebirth
Levels.CapPerRebirth = 20 -- each rebirth raises the cap by this much
Levels.HopsBonusPerLevel = 0.02 -- +2% Hops per level above 1 (additive)

-- XP needed to go from `level` to `level + 1`.
function Levels.xpForLevel(level: number): number
	return math.ceil(Levels.BaseXp * Levels.Growth ^ (level - 1))
end

function Levels.capFor(rebirths: number): number
	return Levels.CapBase + Levels.CapPerRebirth * rebirths
end

-- Adds XP, levelling up as many times as it covers. At the cap, XP is held
-- at 0 and further gains are discarded.
-- Returns newLevel, newXp, levelsGained.
function Levels.addXp(level: number, xp: number, gain: number, cap: number): (number, number, number)
	local start = level
	if level >= cap then
		return cap, 0, 0
	end
	xp += math.max(gain, 0)
	while level < cap do
		local need = Levels.xpForLevel(level)
		if xp < need then
			break
		end
		xp -= need
		level += 1
	end
	if level >= cap then
		level, xp = cap, 0
	end
	return level, xp, level - start
end

function Levels.hopsBonus(level: number): number
	return (level - 1) * Levels.HopsBonusPerLevel
end

return Levels
