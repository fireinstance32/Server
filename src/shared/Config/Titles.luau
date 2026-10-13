--!strict
-- Titles (reference: "My Titles", 0 / 27). Each unlocks at a milestone, can be
-- equipped (one at a time, shown above the head) and gives a small boost.
-- Progress reads player data, so the same function runs on server and client.

export type Requirement =
	"launches" -- river hops thrown
	| "distance" -- best distance (studs)
	| "hatched" -- eggs hatched
	| "playtime" -- seconds played
	| "frogs" -- frogs owned
	| "discovered" -- different pets hatched
	| "rebirths"
	| "level"
	| "winsEarned" -- lifetime Wins

export type Title = {
	id: string,
	name: string,
	rarity: string, -- a Config/Pets rarity (border colour)
	need: Requirement,
	amount: number,
	stat: "hops" | "wins", -- hops: added to the multiplier; wins: multiplies Wins
	bonus: number,
}

local function title(id: string, name: string, rarity: string, need: Requirement, amount: number, stat: "hops" | "wins", bonus: number): Title
	return { id = id, name = name, rarity = rarity, need = need, amount = amount, stat = stat, bonus = bonus }
end

local HOUR = 3600

local List: { Title } = {
	title("Tadpole", "Tadpole", "Common", "launches", 1, "hops", 0.5),
	title("PondHopper", "Pebble Lifter", "Common", "launches", 25, "hops", 1),
	title("Splasher", "Splasher", "Common", "distance", 100, "hops", 1),
	title("EggSeeker", "Egg Seeker", "Common", "hatched", 10, "hops", 1),
	title("Regular", "Regular", "Common", "playtime", HOUR / 2, "wins", 1.05),
	title("LilyLeaper", "Rock Rookie", "Uncommon", "distance", 250, "hops", 2),
	title("FrogFan", "Rock Collector", "Uncommon", "frogs", 3, "hops", 2),
	title("Hatcher", "Hatcher", "Uncommon", "hatched", 50, "hops", 2),
	title("Reborn", "Reborn", "Uncommon", "rebirths", 1, "wins", 1.1),
	title("Trainee", "Trainee", "Uncommon", "level", 10, "hops", 2),
	title("RiverRunner", "Field Thrower", "Rare", "distance", 1000, "hops", 4),
	title("Winner", "Winner", "Rare", "winsEarned", 1000, "wins", 1.15),
	title("PetPal", "Pet Pal", "Rare", "discovered", 10, "hops", 4),
	title("Collector", "Collector", "Rare", "frogs", 6, "hops", 4),
	title("TwiceBorn", "Twice Born", "Rare", "rebirths", 5, "wins", 1.2),
	title("Dedicated", "Dedicated", "Rare", "playtime", 5 * HOUR, "hops", 4),
	title("LagoonLegend", "Lagoon Legend", "Epic", "distance", 1900, "hops", 8),
	title("EggMaster", "Egg Master", "Epic", "hatched", 500, "hops", 8),
	title("Champion", "Champion", "Epic", "winsEarned", 100000, "wins", 1.3),
	title("ZooKeeper", "Zoo Keeper", "Epic", "discovered", 25, "hops", 8),
	title("Veteran", "Veteran", "Epic", "level", 100, "hops", 8),
	title("Phoenix", "Phoenix", "Epic", "rebirths", 25, "wins", 1.4),
	title("PondKing", "King of the Quarry", "Legendary", "distance", 2500, "hops", 15),
	title("FrogRoyalty", "Rock Royalty", "Legendary", "frogs", 12, "hops", 15),
	title("Unstoppable", "Unstoppable", "Legendary", "rebirths", 100, "wins", 1.6),
	title("NoLife", "No Life", "Legendary", "playtime", 50 * HOUR, "hops", 15),
	title("Hopfather", "The Rockfather", "Rainbow", "rebirths", 250, "wins", 2),
}

local ById: { [string]: Title } = {}
for _, t in List do
	ById[t.id] = t
end

local function countKeys(t: { [any]: any }?): number
	local n = 0
	for _ in t or {} do
		n += 1
	end
	return n
end

local READ: { [Requirement]: (data: any) -> number } = {
	launches = function(data)
		return data.stats and data.stats.launches or 0
	end,
	distance = function(data)
		return data.bestDistance or 0
	end,
	hatched = function(data)
		return data.stats and data.stats.hatched or 0
	end,
	playtime = function(data)
		return data.stats and data.stats.timePlayed or 0
	end,
	frogs = function(data)
		return countKeys(data.frogs)
	end,
	discovered = function(data)
		return countKeys(data.discovered)
	end,
	rebirths = function(data)
		return data.rebirths or 0
	end,
	level = function(data)
		return data.level or 1
	end,
	winsEarned = function(data)
		return data.stats and data.stats.winsEarned or 0
	end,
}

local Titles = {
	List = List,
	ById = ById,
}

-- How far along `t` is: (current, target), current capped at target.
function Titles.progress(t: Title, data: any): (number, number)
	return math.min(READ[t.need](data), t.amount), t.amount
end

function Titles.isUnlocked(t: Title, data: any): boolean
	return READ[t.need](data) >= t.amount
end

-- Ids of titles `data` qualifies for but hasn't been given yet.
function Titles.newlyEarned(data: any): { string }
	local earned = {}
	for _, t in List do
		if not (data.titles and data.titles[t.id]) and Titles.isUnlocked(t, data) then
			table.insert(earned, t.id)
		end
	end
	return earned
end

-- "Hop 1,000 studs" style requirement text for the card.
function Titles.describe(t: Title): string
	local n = t.amount
	local function fmt(v: number): string
		local s = tostring(math.floor(v))
		return (s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
	end
	if t.need == "launches" then
		return `Throw {fmt(n)} time{if n == 1 then "" else "s"}`
	elseif t.need == "distance" then
		return `Reach {fmt(n)} studs`
	elseif t.need == "hatched" then
		return `Hatch {fmt(n)} eggs`
	elseif t.need == "playtime" then
		return if n < 3600 then `Play {n // 60} minutes` else `Play {n // 3600} hours`
	elseif t.need == "frogs" then
		return `Own {n} rocks`
	elseif t.need == "discovered" then
		return `Discover {n} pets`
	elseif t.need == "rebirths" then
		return `Rebirth {fmt(n)} time{if n == 1 then "" else "s"}`
	elseif t.need == "level" then
		return `Reach level {n}`
	end
	return `Earn {fmt(n)} Wins`
end

-- "+4 Hops" / "x1.2 Wins" for the card's bonus line.
function Titles.bonusText(t: Title): string
	if t.stat == "hops" then
		return `+{t.bonus} Strength`
	end
	return `x{t.bonus} Wins`
end

return Titles
