--!strict
-- Playtime gifts: unlock as you play this session (reference Gifts button
-- with its countdown). They reset every session.

export type Gift = { minutes: number, reward: { kind: string, id: string?, amount: number? }, label: string, icon: string }

local List: { Gift } = {
	{ minutes = 1, reward = { kind = "wins", amount = 25 }, label = "25 Wins", icon = "🏆" },
	{ minutes = 3, reward = { kind = "potion", id = "Hops", amount = 1 }, label = "Hops Boost", icon = "🧪" },
	{ minutes = 5, reward = { kind = "wins", amount = 100 }, label = "100 Wins", icon = "🏆" },
	{ minutes = 8, reward = { kind = "potion", id = "Luck", amount = 1 }, label = "Luck Boost", icon = "🍀" },
	{ minutes = 12, reward = { kind = "wins", amount = 250 }, label = "250 Wins", icon = "🏆" },
	{ minutes = 15, reward = { kind = "potion", id = "Wins", amount = 1 }, label = "Wins Boost", icon = "⭐" },
	{ minutes = 20, reward = { kind = "wins", amount = 500 }, label = "500 Wins", icon = "🏆" },
	{ minutes = 30, reward = { kind = "potion", id = "Hops", amount = 2 }, label = "2 Hops Boosts", icon = "🧪" },
	{ minutes = 45, reward = { kind = "wins", amount = 1000 }, label = "1K Wins", icon = "🏆" },
	{ minutes = 60, reward = { kind = "pet", id = "FortuneNeko" }, label = "Fortune Neko", icon = "🐱" },
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
