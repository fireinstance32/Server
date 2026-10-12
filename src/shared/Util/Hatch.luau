--!strict
-- Pure egg maths: luck-adjusted weights, displayed chances, and picking a
-- pet from a 0–1 roll. No Roblox APIs, so it's unit-tested offline.

export type Entry = { pet: string, weight: number }

local Hatch = {}

-- Weights after luck: pets for which `isLucky(petId)` is true get ×luck.
function Hatch.weights(entries: { Entry }, luck: number, isLucky: (string) -> boolean): { number }
	local result = {}
	for i, entry in entries do
		result[i] = if isLucky(entry.pet) then entry.weight * math.max(luck, 1) else entry.weight
	end
	return result
end

-- Percent chance per pet id (0–100), as shown to players.
function Hatch.chances(entries: { Entry }, weights: { number }): { [string]: number }
	local total = 0
	for _, w in weights do
		total += w
	end
	local result = {}
	for i, entry in entries do
		result[entry.pet] = if total > 0 then weights[i] / total * 100 else 0
	end
	return result
end

-- Picks the pet for a roll in [0, 1).
function Hatch.pick(entries: { Entry }, weights: { number }, roll: number): string
	local total = 0
	for _, w in weights do
		total += w
	end
	local target = math.clamp(roll, 0, 1) * total
	for i, entry in entries do
		target -= weights[i]
		if target < 0 then
			return entry.pet
		end
	end
	return entries[#entries].pet
end

-- "40%", "2.5%", "0.1%" – short percent text for signs and cards.
function Hatch.percentText(percent: number): string
	if percent >= 10 then
		return `{math.floor(percent + 0.5)}%`
	elseif percent >= 1 then
		return `{math.floor(percent * 10 + 0.5) / 10}%`
	end
	return `{math.floor(percent * 100 + 0.5) / 100}%`
end

return Hatch
