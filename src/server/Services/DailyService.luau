-- 7-day daily login rewards. Streak logic is in Shared.Config.DailyRewards.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local DailyRewards = require(Shared.Config.DailyRewards)
local Net = require(Shared.Net)

local Rewards = require(script.Parent.Parent.Rewards)
local DataService = require(script.Parent.DataService)
local PetService = require(script.Parent.PetService)

local DailyService = {}

local function claim(player: Player): (boolean, string)
	local data = DataService.get(player)
	if not data then
		return false, "Still loading..."
	end
	local today = DailyRewards.dayNumber(os.time())
	local canClaim, day = DailyRewards.status(data.daily.lastDay, data.daily.streak, today)
	if not canClaim then
		return false, "Come back tomorrow!"
	end
	local reward = DailyRewards.Days[day]
	Rewards.grant(data, reward)
	data.daily.lastDay = today
	data.daily.streak = day
	DataService.changed(player)
	PetService.refreshModels(player)
	return true, `Day {day}: {reward.label}!`
end

function DailyService.start()
	Net.func("ClaimDaily").OnServerInvoke = claim
end

return DailyService
