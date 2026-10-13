--!strict
-- Playtime gifts: unlock as you play this session (reference Gifts button
-- with its countdown). They reset every session.

export type Gift = { minutes: number, reward: { kind: string, id: string?, amount: number? }, label: string, icon: string }

-- Same 12 slots as the reference Playtime Rewards (Skill → Hops). Row 1
-- (1–4) blue, row 2 (5–8) purple, row 3 (9–11) orange, the last rainbow.
local List: { Gift } = {
	{ minutes = 1, reward = { kind = "hops", amount = 5000 }, label = "+5K Strength", icon = "⚡" },
	{ minutes = 2, reward = { kind = "wins", amount = 5 }, label = "+5 Wins", icon = "🏆" },
	{ minutes = 4, reward = { kind = "egg", id = "Common" }, label = "Common Egg", icon = "🥚" },
	{ minutes = 6, reward = { kind = "potion", id = "Hops", amount = 1 }, label = "1 Strength Boost", icon = "🧪" },
	{ minutes = 8, reward = { kind = "wins", amount = 500 }, label = "+500 Wins", icon = "🏆" },
	{ minutes = 10, reward = { kind = "hops", amount = 15000 }, label = "+15K Strength", icon = "⚡" },
	{ minutes = 13, reward = { kind = "potion", id = "Wins", amount = 1 }, label = "1 Win Boost", icon = "⭐" },
	{ minutes = 16, reward = { kind = "egg", id = "Uncommon" }, label = "Uncommon Egg", icon = "🥚" },
	{ minutes = 20, reward = { kind = "potion", id = "Luck", amount = 1 }, label = "1 Luck Boost", icon = "🍀" },
	{ minutes = 25, reward = { kind = "wins", amount = 5000 }, label = "+5K Wins", icon = "🏆" },
	{ minutes = 45, reward = { kind = "hops", amount = 50000 }, label = "+50K Strength", icon = "⚡" },
	{ minutes = 65, reward = { kind = "egg", id = "Rare" }, label = "Rare Egg", icon = "🥚" },
}

local Gifts = { List = List }

function Gifts.isReady(index: number, elapsedSeconds: number): boolean
	local gift = List[index]
	return gift ~= nil and elapsedSeconds >= gift.minutes * 60
end

-- Seconds until the next unclaimed gift (0 = one is ready, nil = all done).
function Gifts.nextIn(elapsedSeconds: number, claimed: { [number]: boolean }): number?
	local best: number? = nil
	for i, gift in List do
		if not claimed[i] then
			local left = math.max(gift.minutes * 60 - elapsedSeconds, 0)
			if best == nil or left < best then
				best = left
			end
		end
	end
	return best
end

-- Claimed indexes are stored as a "1,3,4" attribute string.
function Gifts.parseClaimed(text: string?): { [number]: boolean }
	local claimed = {}
	for part in string.gmatch(text or "", "%d+") do
		claimed[tonumber(part) :: number] = true
	end
	return claimed
end

return Gifts
