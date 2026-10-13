-- Tutorial quest chain (reference: "GET 2 WINS (1/2)" bar). One quest at a
-- time; each pays a reward when its progress reaches the target. Progress
-- reads player data, so the same functions run on server and client.

local Ponds = require(script.Parent.Ponds)
local Frogs = require(script.Parent.Frogs)
local Pets = require(script.Parent.Pets)
local Game = require(script.Parent.Game)

export type Quest = {
	text: string,
	target: number,
	progress: (data: any) -> number,
	where: (() -> Vector3)?, -- guide beam target
	reward: { kind: string, id: string?, amount: number? },
	rewardLabel: string,
}

local function countKeys(t: { [any]: any }?): number
	local n = 0
	for _ in t or {} do
		n += 1
	end
	return n
end

local List: { Quest } = {
	{
		text = "Lift at the Starter Gym",
		target = 50,
		progress = function(data)
			return data.hops
		end,
		where = function()
			return Ponds.standPosition(Ponds.List[1])
		end,
		reward = { kind = "wins", amount = 10 },
		rewardLabel = "10 Wins",
	},
	{
		text = "Throw your rock down the field: get Wins",
		target = 2,
		progress = function(data)
			return data.stats.winsEarned
		end,
		where = Game.hopZoneCenter,
		reward = { kind = "potion", id = "Hops", amount = 1 },
		rewardLabel = "Strength Boost",
	},
	{
		text = "Buy a new rock",
		target = 1,
		progress = function(data)
			return countKeys(data.frogs) - 1
		end,
		where = function()
			return Frogs.podiumPosition(2)
		end,
		reward = { kind = "wins", amount = 50 },
		rewardLabel = "50 Wins",
	},
	{
		text = "Hatch an egg",
		target = 1,
		progress = function(data)
			return data.stats.hatched
		end,
		where = function()
			return Pets.Eggs[1].position
		end,
		reward = { kind = "potion", id = "Luck", amount = 1 },
		rewardLabel = "Luck Boost",
	},
	{
		text = "Reach Level 20",
		target = 20,
		progress = function(data)
			return if data.rebirths > 0 then 20 else data.level
		end,
		where = function()
			return Ponds.standPosition(Ponds.List[1])
		end,
		reward = { kind = "frog", id = "River" },
		rewardLabel = "River Stone",
	},
	{
		text = "Rebirth!",
		target = 1,
		progress = function(data)
			return data.rebirths
		end,
		reward = { kind = "frog", id = "Shadow" },
		rewardLabel = "Shadow Rock",
	},
}

return { List = List }
