-- Loads, saves and replicates player data. Every other service mutates the
-- profile table returned by DataService.get and then calls DataService.changed.
-- Parts: Template (new/upgrade), Snapshot (client view), Store (DataStore +
-- session locking).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)
local Net = require(Shared.Net)

local Leaderstats = require(script.Parent.Parent.Leaderstats)
local Template = require(script.Template)
local Snapshot = require(script.Snapshot)
local Store = require(script.Store)

local DataService = {}

local profiles: { [Player]: any } = {}
local loaded: { [Player]: boolean } = {} -- true once this server owns the saved profile

-- Fires (player, data) after every change, for server systems that react
-- to data (e.g. the frog held in hand).
local changedEvent = Instance.new("BindableEvent")
DataService.Changed = changedEvent.Event

-- Fires (player, data) once a player's profile has loaded.
local loadedEvent = Instance.new("BindableEvent")
DataService.Loaded = loadedEvent.Event

function DataService.get(player: Player): any?
	return profiles[player]
end

-- Replace a player's profile with a fresh one (dev/testing only).
function DataService.reset(player: Player)
	if profiles[player] then
		profiles[player] = Template.new()
		DataService.changed(player)
	end
end

function DataService.changed(player: Player)
	local data = profiles[player]
	if not data then
		return
	end
	Leaderstats.update(player, data)
	Net.event("DataChanged"):FireClient(player, Snapshot(player, data))
	changedEvent:Fire(player, data)
end

local function save(player: Player, release: boolean)
	local data = profiles[player]
	if not data or not loaded[player] then
		return
	end
	data.lastSeen = os.time()
	Store.save(player, data, release)
end

-- Save right away (after a Robux purchase), without waiting for autosave.
function DataService.saveNow(player: Player)
	task.spawn(save, player, false)
end

local function onPlayerAdded(player: Player)
	Leaderstats.setup(player)

	local data = Template.new()
	if Store.available() then
		local status, result = Store.load(player)
		if status == "ok" then
			if result ~= nil then
				data = Template.reconcile(result)
			end
			loaded[player] = true
		elseif status == "locked" then
			player:Kick("Your progress is still saving in another server. Please rejoin in a moment!")
			return
		else
			-- Don't let a failed load overwrite real data with an empty profile.
			warn(`[DataService] Failed to load {player.Name}, saving disabled this session: {result}`)
		end
	end

	if not player.Parent then
		-- Left while loading: hand the claim straight back.
		if loaded[player] then
			Store.save(player, data, true)
			loaded[player] = nil
		end
		return
	end
	profiles[player] = data
	DataService.changed(player)
	loadedEvent:Fire(player, data)
end

local function onPlayerRemoving(player: Player)
	save(player, true)
	profiles[player] = nil
	loaded[player] = nil
end

function DataService.init()
	Store.init()
end

function DataService.start()
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end

	task.spawn(function()
		while true do
			task.wait(Game.AutosaveInterval)
			for player in profiles do
				task.spawn(save, player, false)
			end
		end
	end)

	game:BindToClose(function()
		local pending = 0
		for player in profiles do
			pending += 1
			task.spawn(function()
				save(player, true)
				pending -= 1
			end)
		end
		local deadline = os.clock() + 25
		while pending > 0 and os.clock() < deadline do
			task.wait(0.1)
		end
	end)
end

return DataService
