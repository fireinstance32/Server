-- Chat commands for playtesting. Type /help in chat (Studio only by default).
-- Every command edits the profile through the same path real gameplay uses.
-- The commands themselves live in Commands.luau.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Dev = require(Shared.Config.Dev)
local Net = require(Shared.Net)

local DataService = require(script.Parent.DataService)
local COMMANDS = require(script.Commands)

local DevService = {}

local function allowed(player: Player): boolean
	if RunService:IsStudio() and Dev.EnabledInStudio then
		return true
	end
	return table.find(Dev.AllowedUserIds, player.UserId) ~= nil
end

local function say(player: Player, text: string)
	print(`[Dev] {player.Name}: {text}`)
	Net.event("Notify"):FireClient(player, { kind = "Dev", text = text })
end

local function onChatted(player: Player, message: string)
	if string.sub(message, 1, 1) ~= "/" or not allowed(player) then
		return
	end
	local words = string.split(string.lower(string.sub(message, 2)), " ")
	local name = table.remove(words, 1)
	if name == "help" then
		local lines = {}
		for _, command in COMMANDS do
			table.insert(lines, command.usage)
		end
		table.sort(lines)
		say(player, table.concat(lines, "\n"))
		return
	end
	local command = name and COMMANDS[name]
	local data = DataService.get(player)
	if not command or not data then
		return
	end
	local result = command.run(player, data, words)
	if name ~= "reset" then
		DataService.changed(player)
	end
	say(player, result)
end

function DevService.start()
	if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		-- Modern chat: register real chat commands (they fire on the server).
		local folder = Instance.new("Folder")
		folder.Name = "DevCommands"
		local names = { "help" }
		for name in COMMANDS do
			table.insert(names, name)
		end
		for _, name in names do
			local command = Instance.new("TextChatCommand")
			command.Name = "Dev_" .. name
			command.PrimaryAlias = "/" .. name
			command.Triggered:Connect(function(source: TextSource, message: string)
				local player = Players:GetPlayerByUserId(source.UserId)
				if player then
					onChatted(player, message)
				end
			end)
			command.Parent = folder
		end
		folder.Parent = TextChatService
	else
		-- Legacy chat fallback.
		local function hook(player: Player)
			player.Chatted:Connect(function(message)
				onChatted(player, message)
			end)
		end
		Players.PlayerAdded:Connect(hook)
		for _, player in Players:GetPlayers() do
			hook(player)
		end
	end
end

return DevService
