--!strict
-- Potions: timed x2 boosts (reference: Skill / Win / Luck boosts). Using
-- one while it's active adds its duration on top (stacks time, not power).

export type Potion = {
	id: string,
	name: string,
	stat: "hops" | "wins" | "luck",
	factor: number,
	duration: number, -- seconds
	icon: string,
}

local List: { Potion } = {
	{ id = "Hops", name = "Strength Boost", stat = "hops", factor = 2, duration = 600, icon = "🧪" },
	{ id = "Wins", name = "Wins Boost", stat = "wins", factor = 2, duration = 600, icon = "⭐" },
	{ id = "Luck", name = "Luck Boost", stat = "luck", factor = 2, duration = 600, icon = "🍀" },
}

local byId: { [string]: Potion } = {}
for _, potion in List do
	byId[potion.id] = potion
end

-- What players call each stat (the stat ids stay "hops" etc. in code).
local StatWord: { [string]: string } = { hops = "STRENGTH", wins = "WINS", luck = "LUCK" }

local Potions = { List = List, ById = byId, StatWord = StatWord }

-- New expiry time after drinking a potion at `now` (pure; unit-tested).
function Potions.extend(currentExpiry: number?, now: number, duration: number): number
	return math.max(currentExpiry or 0, now) + duration
end

-- Seconds left (0 when inactive).
function Potions.remaining(expiry: number?, now: number): number
	return math.max((expiry or 0) - now, 0)
end

return Potions
