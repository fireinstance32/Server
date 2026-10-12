-- Global leaderboards: counts time played, writes each player's scores to
-- OrderedDataStores and draws the top rows on every hub's boards.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Leaderboards = require(Shared.Config.Leaderboards)
local Format = require(Shared.Util.Format)

local DataService = require(script.Parent.DataService)

local LeaderboardService = {}

local stores: { [string]: OrderedDataStore } = {}
local written: { [Player]: { [string]: number } } = {} -- last score sent, to skip repeats
local names: { [number]: string } = {}
local warned: { [string]: boolean } = {}

-- DataStore errors repeat every refresh (e.g. Studio without API access); log each kind once.
local function warnOnce(key: string, message: string)
	if not warned[key] then
		warned[key] = true
		warn(`[Leaderboards] {message}`)
	end
end

local function nameFor(userId: number): string
	if names[userId] then
		return names[userId]
	end
	local ok, name = pcall(function()
		return Players:GetNameFromUserIdAsync(userId)
	end)
	names[userId] = if ok then name else "Player"
	return names[userId]
end

local function writeScores()
	for _, player in Players:GetPlayers() do
		local data = DataService.get(player)
		if data then
			local mine = written[player] or {}
			written[player] = mine
			for _, def in Leaderboards.List do
				local store = stores[def.id]
				local score = def.value(data)
				if store and score > 0 and mine[def.id] ~= score then
					local ok, err = pcall(function()
						store:SetAsync(tostring(player.UserId), score)
					end)
					if ok then
						mine[def.id] = score
					else
						warnOnce(`write{def.id}`, `{def.id} write failed: {err}`)
					end
				end
			end
		end
	end
end

-- Every hub's board rows for one leaderboard.
local function boardRows(id: string): { SurfaceGui }
	local guis = {}
	local root = workspace:FindFirstChild("World")
	for _, world in if root then root:GetChildren() else {} do
		local folder = world:FindFirstChild("Leaderboards")
		local model = folder and folder:FindFirstChild(id)
		local board = model and model:FindFirstChild("Board")
		local gui = board and board:FindFirstChildOfClass("SurfaceGui")
		if gui then
			table.insert(guis, gui)
		end
	end
	return guis
end

local function readTop()
	for _, def in Leaderboards.List do
		local store = stores[def.id]
		if store then
			local ok, page = pcall(function()
				return store:GetSortedAsync(false, Leaderboards.Rows):GetCurrentPage()
			end)
			if ok then
				local lines = {}
				for rank, entry in page do
					local userId = tonumber(entry.key) or 0
					lines[rank] = `#{rank}  {nameFor(userId)}  {Format.abbreviate(entry.value)}{def.suffix}`
				end
				for _, gui in boardRows(def.id) do
					for i = 1, Leaderboards.Rows do
						local row = gui:FindFirstChild(`Row{i}`, true) :: TextLabel?
						if row then
							row.Text = lines[i] or (if i == 1 then "Be the first!" else "")
						end
					end
				end
			else
				warnOnce(`read{def.id}`, `{def.id} read failed: {page}`)
			end
		end
	end
end

function LeaderboardService.init()
	for _, def in Leaderboards.List do
		local ok, store = pcall(function()
			return DataStoreService:GetOrderedDataStore(`{Leaderboards.StorePrefix}{def.id}_v1`)
		end)
		if ok then
			stores[def.id] = store
		end
	end
end

function LeaderboardService.start()
	Players.PlayerRemoving:Connect(function(player)
		written[player] = nil
	end)

	-- Time played (saved with the profile, so it counts across sessions).
	task.spawn(function()
		while true do
			task.wait(Leaderboards.PlaytimeTick)
			for _, player in Players:GetPlayers() do
				local data = DataService.get(player)
				if data then
					data.stats.timePlayed += Leaderboards.PlaytimeTick
				end
			end
		end
	end)

	task.spawn(function()
		while true do
			writeScores()
			readTop()
			task.wait(Leaderboards.RefreshSeconds)
		end
	end)
end

return LeaderboardService
