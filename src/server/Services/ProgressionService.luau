-- Levels (XP), rebirths and redeemable codes.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Levels = require(Shared.Config.Levels)
local Codes = require(Shared.Config.Codes)
local Net = require(Shared.Net)

local DataService = require(script.Parent.DataService)
local Remotes = require(script.Parent.Parent.Remotes)

local ProgressionService = {}

-- Called by gameplay with the number of pads hopped. Does not replicate;
-- the caller calls DataService.changed once after all its changes.
function ProgressionService.addXp(player: Player, data: any, amount: number): number
	local level, xp, gained = Levels.addXp(data.level, data.xp, amount, Levels.capFor(data.rebirths))
	data.level, data.xp = level, xp
	if gained > 0 then
		Net.event("Notify"):FireClient(player, { kind = "LevelUp", level = level, maxed = level >= Levels.capFor(data.rebirths) })
	end
	return gained
end

-- Resets Hops and Level (Wins are kept) and adds a rebirth. `force` skips the level check (used by
-- the Skip Rebirth product). Does not replicate; callers call changed().
function ProgressionService.applyRebirth(data: any, force: boolean?): (boolean, string)
	local cap = Levels.capFor(data.rebirths)
	if not force and data.level < cap then
		return false, `Reach Level {cap} to rebirth`
	end
	data.hops = 0
	data.level = 1
	data.xp = 0
	data.rebirths += 1
	return true, `Rebirth {data.rebirths}! Max level is now {Levels.capFor(data.rebirths)}.`
end

local function rebirth(player: Player): (boolean, string)
	local data = DataService.get(player)
	if not data then
		return false, "Still loading..."
	end
	local ok, message = ProgressionService.applyRebirth(data)
	if ok then
		DataService.changed(player)
	end
	return ok, message
end

local function redeemCode(player: Player, input: unknown): (boolean, string)
	if typeof(input) ~= "string" or #input > 30 then
		return false, "Invalid code"
	end
	local data = DataService.get(player)
	if not data then
		return false, "Still loading..."
	end
	local code = string.upper((input:gsub("%s", "")))
	local reward = Codes[code]
	if not reward then
		return false, "That code doesn't exist"
	end
	if data.codes[code] then
		return false, "Already redeemed"
	end
	data.codes[code] = true
	data.wins += reward.wins or 0
	data.hops += reward.hops or 0
	DataService.changed(player)
	return true, "Code redeemed!"
end

function ProgressionService.start()
	Remotes.handle("Rebirth", rebirth)
	Remotes.handle("RedeemCode", redeemCode)
end

return ProgressionService
