-- Onboarding funnel for Roblox Analytics (Creator Dashboard > Analytics >
-- Funnels). Steps are logged once per player, in order, when `done` is true.

export type Step = { name: string, done: (data: any) -> boolean }

local function count(map: { [any]: any }): number
	local n = 0
	for _ in map do
		n += 1
	end
	return n
end

local Funnel = {}

Funnel.Steps = {
	{ name = "Joined", done = function()
		return true
	end },
	{ name = "First Hops", done = function(data)
		return data.hops > 0 or data.stats.launches > 0 or data.rebirths > 0
	end },
	{ name = "First River Hop", done = function(data)
		return data.stats.launches > 0
	end },
	{ name = "Bought a Frog", done = function(data)
		return count(data.frogs) > 1
	end },
	{ name = "Hatched an Egg", done = function(data)
		return data.stats.hatched > 0
	end },
	{ name = "First Rebirth", done = function(data)
		return data.rebirths > 0
	end },
	{ name = "Reached World 2", done = function(data)
		return data.worldsUnlocked.Swamp == true
	end },
} :: { Step }

-- Step numbers newly reached after `logged` (consecutive, stopping at the
-- first unfinished step, as funnels must be logged in order).
function Funnel.newSteps(data: any, logged: number): { number }
	local steps = {}
	local i = logged + 1
	while Funnel.Steps[i] and Funnel.Steps[i].done(data) do
		table.insert(steps, i)
		i += 1
	end
	return steps
end

return Funnel
