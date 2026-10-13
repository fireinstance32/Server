-- The playtest chat commands (/help lists them). Each edits the profile;
-- DevService handles chat, permissions and replies.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Levels = require(Shared.Config.Levels)
local Frogs = require(Shared.Config.Frogs)
local Game = require(Shared.Config.Game)
local Ponds = require(Shared.Config.Ponds)
local Worlds = require(Shared.Config.Worlds)
local Potions = require(Shared.Config.Potions)
local Events = require(Shared.Config.Events)
local Monetization = require(Shared.Config.Monetization)

local DataService = require(script.Parent.Parent.DataService)
local MonetizationService = require(script.Parent.Parent.MonetizationService)
local WorldService = require(script.Parent.Parent.WorldService)
local PetService = require(script.Parent.Parent.PetService)
local Passes = require(script.Parent.Parent.Parent.Passes)
local PetGallery = require(script.Parent.PetGallery)

local function number(arg: string?): number?
	local n = tonumber(arg)
	if n and n == n and n >= 0 then
		return n
	end
	return nil
end

export type Command = { usage: string, run: (Player, any, { string }) -> string }

local COMMANDS: { [string]: Command } = {
	hops = {
		usage = "/hops <n>  set Strength",
		run = function(_, data, args)
			data.hops = number(args[1]) or data.hops
			return `Strength = {data.hops}`
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
		usage = "/frogs  unlock every rock",
		run = function(_, data)
			for _, frog in Frogs.List do
				data.frogs[frog.id] = true
			end
			return "All rocks unlocked"
		end,
	},
	goto = {
		usage = "/goto river | train | pond <1-7>  teleport to the Throw Zone or a gym",
		run = function(player, _, args)
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
			if not root then
				return "No character"
			end
			if args[1] == "river" then
				root.CFrame = CFrame.new(Game.hopZoneCenter() + Vector3.new(0, 5, 0))
				return "Teleported to the Throw Zone"
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
	world = {
		usage = "/world <lily|swamp|candy|space|lava>  unlock and travel to a world",
		run = function(player, data, args)
			for _, world in Worlds.List do
				if string.lower(world.id) == args[1] then
					data.worldsUnlocked[world.id] = true
					local ok, message = WorldService.travel(player, world.id)
					return if ok then message else `Unlocked {world.name}: {message}`
				end
			end
			return "Unknown world"
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
	event = {
		usage = "/event <id|none|auto> [n]  force an event on/off, or give n event currency",
		run = function(_, data, args)
			local arg = args[1]
			if arg == "auto" then
				ReplicatedStorage:SetAttribute(Events.OverrideAttribute, nil)
				return "Events follow the calendar again"
			elseif arg == "none" then
				ReplicatedStorage:SetAttribute(Events.OverrideAttribute, "none")
				return "No event running"
			end
			for _, event in Events.List do
				if string.lower(event.id) == arg or string.lower(event.name) == arg then
					ReplicatedStorage:SetAttribute(Events.OverrideAttribute, event.id)
					if data.event.id ~= event.id then
						data.event = { id = event.id, currency = 0 }
					end
					data.event.currency += number(args[2]) or 0
					return `{event.name} is running ({data.event.currency} {event.currency})`
				end
			end
			return "Unknown event (see Config/Events)"
		end,
	},
	petgallery = {
		usage = "/petgallery  show/hide every pet next to spawn",
		run = function()
			return PetGallery.toggle()
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

return COMMANDS
