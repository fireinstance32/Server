--!strict
-- Rebirth resets Hops and Wins, keeps frogs and pets, and adds a permanent
-- Hops multiplier (see Game.RebirthHopsBonus).

local Rebirths = {}

Rebirths.BaseCost = 5000
Rebirths.CostGrowth = 4

function Rebirths.costFor(currentRebirths: number): number
	return math.floor(Rebirths.BaseCost * Rebirths.CostGrowth ^ currentRebirths)
end

return Rebirths
