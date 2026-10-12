-- The player-list stats (leaderstats folder) shown in the Roblox leaderboard.

local Leaderstats = {}

function Leaderstats.setup(player: Player)
	local folder = Instance.new("Folder")
	folder.Name = "leaderstats"
	for _, name in { "Hops", "Wins", "Rebirths" } do
		local value = Instance.new("NumberValue")
		value.Name = name
		value.Parent = folder
	end
	folder.Parent = player
end

function Leaderstats.update(player: Player, data: any)
	local folder = player:FindFirstChild("leaderstats")
	if not folder then
		return
	end
	(folder :: any).Hops.Value = data.hops;
	(folder :: any).Wins.Value = data.wins;
	(folder :: any).Rebirths.Value = data.rebirths
end

return Leaderstats
