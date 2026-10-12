-- Rebirths and redeemable codes.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Rebirths = require(Shared.Config.Rebirths)
local Codes = require(Shared.Config.Codes)
local Format = require(Shared.Util.Format)
local Net = require(Shared.Net)

local DataService = require(script.Parent.DataService)

local ProgressionService = {}

local function rebirth(player: Player): (boolean, string)
	local data = DataService.get(player)
	if not data then
		return false, "Still loading..."
	end
	local cost = Rebirths.costFor(data.rebirths)
	if data.hops < cost then
		return false, `You need {Format.abbreviate(cost)} Hops`
	end
	data.hops = 0
	data.wins = 0
	data.rebirths += 1
	DataService.changed(player)
	return true, `Rebirth {data.rebirths}! Your Hops are boosted forever.`
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
	Net.func("Rebirth").OnServerInvoke = rebirth
	Net.func("RedeemCode").OnServerInvoke = redeemCode
end

return ProgressionService
