-- Friend Boost: +10% Hops per friend in the same server (max +50%).
-- Stored as the player's "FriendBoost" attribute; Stats reads it.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Game = require(ReplicatedStorage:WaitForChild("Shared").Config.Game)

local DataService = require(script.Parent.DataService)

local FriendService = {}

local friendCache: { [string]: boolean } = {}

local function areFriends(a: Player, b: Player): boolean
	local key = if a.UserId < b.UserId then `{a.UserId}:{b.UserId}` else `{b.UserId}:{a.UserId}`
	if friendCache[key] == nil then
		local ok, result = pcall(a.IsFriendsWith, a, b.UserId)
		friendCache[key] = ok and result == true
	end
	return friendCache[key]
end

local function recompute()
	local players = Players:GetPlayers()
	for _, player in players do
		local friends = 0
		for _, other in players do
			if other ~= player and areFriends(player, other) then
				friends += 1
			end
		end
		local boost = math.min(friends * Game.FriendBoostEach, Game.FriendBoostMax)
		if player:GetAttribute("FriendBoost") ~= boost then
			player:SetAttribute("FriendBoost", boost)
			DataService.changed(player)
		end
	end
end

function FriendService.start()
	Players.PlayerAdded:Connect(function()
		task.defer(recompute)
	end)
	Players.PlayerRemoving:Connect(function()
		task.defer(recompute)
	end)
	task.defer(recompute)
end

return FriendService
