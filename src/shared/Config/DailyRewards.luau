--!strict
-- 7-day login calendar (reference Daily Rewards). Claim once per UTC day;
-- missing a day restarts at Day 1; after Day 7 it starts over.

export type Reward = {
	kind: "potion" | "pet" | "frog" | "wins" | "hops",
	id: string?,
	amount: number?,
	label: string,
}

local Days: { Reward } = {
	{ kind = "potion", id = "Hops", amount = 1, label = "1 Strength Boost" },
	{ kind = "pet", id = "FortuneNeko", label = "Fortune Neko" },
	{ kind = "potion", id = "Wins", amount = 1, label = "1 Wins Boost" },
	{ kind = "frog", id = "Nugget", label = "Gold Nugget (Limited!)" },
	{ kind = "potion", id = "Hops", amount = 3, label = "3 Strength Boosts" },
	{ kind = "potion", id = "Wins", amount = 3, label = "3 Wins Boosts" },
	{ kind = "frog", id = "ShootingStar", label = "Meteorite (Limited!)" },
}

local DailyRewards = { Days = Days }

local SECONDS_PER_DAY = 86400

function DailyRewards.dayNumber(time: number): number
	return time // SECONDS_PER_DAY
end

-- Given the last claimed day number and streak (1–7, 0 = never), returns
-- whether today can be claimed and which calendar day (1–7) it would be.
function DailyRewards.status(lastDay: number, streak: number, today: number): (boolean, number)
	if lastDay == today then
		return false, math.max(streak, 1)
	end
	if lastDay == today - 1 and streak >= 1 then
		return true, (streak % #Days) + 1
	end
	return true, 1
end

return DailyRewards
