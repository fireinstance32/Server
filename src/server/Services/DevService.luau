-- Chat commands for playtesting. Type /help in chat (Studio only by default).
-- Every command edits the profile through the same path real gameplay uses.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Dev = require(Shared.Config.Dev)
local Levels = require(Shared.Config.Levels)
local Frogs = require(Shared.Config.Frogs)
local Game = require(Shared.Config.Game)
local Ponds = require(Shared.Config.Ponds)
local Potions = require(Shared.Config.Potions)
local Net = require(Shared.Net)

local DataService = require(script.Parent.DataService)
local MonetizationService = require(script.Parent.MonetizationService)
local Passes = require(script.Parent.Parent.Passes)
local Monetization = require(Shared.Config.Monetization)
local PetService = require(script.Parent.PetService)

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

local function number(arg: string?): number?
	local n = tonumber(arg)
	if n and n == n and n >= 0 then
		return n
	end
	return nil
end

type Command = { usage: string, run: (Player, any, { string }) -> string }

local COMMANDS: { [string]: Command } = {
	hops = {
		usage = "/hops <n>  set Hops",
		run = function(_, data, args)
			data.hops = number(args[1]) or data.hops
			return `Hops = {data.hops}`
		end,
	},
	wins = {
		usage = "/wins <n>  set Wins",
		run = function(_, data, args)
			data.wins = number(args[1]) or data.wins
			return `Wins = {data.wins}`
		end,
	},
	level = {
		usage = "/level <n>  set Level (clamped to the cap)",
		run = function(_, data, args)
			local cap = Levels.capFor(data.rebirths)
			data.level = math.clamp(math.floor(number(args[1]) or data.level), 1, cap)
			data.xp = 0
			return `Level = {data.level} (cap {cap})`
		end,
	},
	maxlevel = {
		usage = "/maxlevel  jump to MAX LEVEL",
		run = function(_, data)
			data.level, data.xp = Levels.capFor(data.rebirths), 0
			return `Level = {data.level} (MAX)`
		end,
	},
	rebirths = {
		usage = "/rebirths <n>  set Rebirths",
		run = function(_, data, args)
			data.rebirths = math.floor(number(args[1]) or data.rebirths)
			data.level = math.min(data.level, Levels.capFor(data.rebirths))
			return `Rebirths = {data.rebirths}`
		end,
	},
	frogs = {
		usage = "/frogs  unlock every frog",
		run = function(_, data)
			for _, frog in Frogs.List do
				data.frogs[frog.id] = true
			end
			return "All frogs unlocked"
		end,
	},
	goto = {
		usage = "/goto river | train | pond <1-7>  teleport to a hop spot",
		run = function(player, _, args)
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
			if not root then
				return "No character"
			end
			if args[1] == "river" then
				root.CFrame = CFrame.new(Game.hopZoneCenter() + Vector3.new(0, 5, 0))
				return "Teleported to the Hop Zone"
			end
			local pond = Ponds.List[tonumber(args[2]) or 1] or Ponds.List[1]
			root.CFrame = CFrame.new(Ponds.standPosition(pond) + Vector3.new(0, 5, 0))
			return `Teleported to {pond.name}`
		end,
	},
	potion = {
		usage = "/potion hops|wins|luck <n>  add potions",
		run = function(_, data, args)
			local id = args[1] and (string.upper(string.sub(args[1], 1, 1)) .. string.sub(args[1], 2))
			if not id or not Potions.ById[id] then
				return "Unknown potion"
			end
			data.potions[id] = (data.potions[id] or 0) + (number(args[2]) or 1)
			return `{id} potions: {data.potions[id]}`
		end,
	},
	grant = {
		usage = "/grant <PassName>  pretend you own a pass (this session)",
		run = function(player, _, args)
			for name in Monetization.Passes do
				if string.lower(name) == args[1] then
					Passes.grant(player, name)
					return `Granted pass {name}`
				end
			end
			return "Unknown pass (see Config/Monetization)"
		end,
	},
	buy = {
		usage = "/buy <ProductName>  run a product's effect without paying",
		run = function(player, _, args)
			for name in Monetization.Products do
				if string.lower(name) == args[1] then
					return if MonetizationService.simulate(player, name) then `Simulated {name}` else `{name} failed`
				end
			end
			return "Unknown product (see Config/Monetization)"
		end,
	},
	daily = {
		usage = "/daily next | reset  pretend a day passed / restart the streak",
		run = function(_, data, args)
			if args[1] == "reset" then
				data.daily.lastDay, data.daily.streak = 0, 0
				return "Daily streak reset"
			end
			data.daily.lastDay -= 1
			return "Pretending a day has passed"
		end,
	},
	reset = {
		usage = "/reset  wipe your data to a new player",
		run = function(player)
			DataService.reset(player)
			PetService.refreshModels(player)
			return "Data reset"
		end,
	},
}

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
