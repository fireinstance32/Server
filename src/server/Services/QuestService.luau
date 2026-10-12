-- Tutorial quests: watches data changes, pays the current quest's reward
-- when its target is reached, and moves to the next one.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Quests = require(Shared.Config.Quests)
local Net = require(Shared.Net)

local Rewards = require(script.Parent.Parent.Rewards)
local DataService = require(script.Parent.DataService)

local QuestService = {}

local checking: { [Player]: boolean } = {}

local function check(player: Player, data: any)
	if checking[player] then
		return
	end
	local quest = Quests.List[data.questStep]
	if not quest or quest.progress(data) < quest.target then
		return
	end
	checking[player] = true
	-- Defer so we don't re-enter DataService.changed from inside its signal.
	task.defer(function()
		local current = DataService.get(player)
		if current == data and Quests.List[data.questStep] == quest then
			Rewards.grant(data, quest.reward)
			data.questStep += 1
			Net.event("Notify"):FireClient(player, { kind = "Quest", text = quest.text, reward = quest.rewardLabel })
			checking[player] = nil
			DataService.changed(player) -- also checks the next quest
		else
			checking[player] = nil
		end
	end)
end

function QuestService.start()
	DataService.Changed:Connect(check)
end

return QuestService
