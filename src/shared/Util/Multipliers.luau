--!strict
-- Pure maths for combining boosts. No Roblox APIs, so it is unit-tested
-- offline (tools/luau-check/tests).
--
-- Two kinds of part:
--   "add"  – a bonus fraction; all adds are summed first (0.25 = +25%)
--   "mult" – a factor applied on top (2 = x2)
-- total = (1 + sum(adds)) * product(mults)

export type Kind = "add" | "mult"

export type Part = {
	id: string,
	label: string,
	kind: Kind,
	value: number,
}

export type Breakdown = {
	total: number,
	parts: { Part },
}

local Multipliers = {}

-- A part that changes nothing (x1, +0%) is left out of breakdowns.
function Multipliers.isNeutral(kind: Kind, value: number): boolean
	if kind == "add" then
		return value == 0
	end
	return value == 1
end

function Multipliers.combine(parts: { Part }): number
	local add, mult = 0, 1
	for _, part in parts do
		if part.kind == "add" then
			add += part.value
		else
			mult *= part.value
		end
	end
	return math.max(1 + add, 0) * mult
end

function Multipliers.breakdown(parts: { Part }): Breakdown
	local kept = {}
	for _, part in parts do
		if not Multipliers.isNeutral(part.kind, part.value) then
			table.insert(kept, part)
		end
	end
	return { total = Multipliers.combine(kept), parts = kept }
end

return Multipliers
