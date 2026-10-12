-- Offline training: when a player comes back, grant the Hops they "trained"
-- while away (Game.offlineHops) and show a welcome-back message.
-- lastSeen is stamped by DataService on every save.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)
local Net = require(Shared.Net)

local Stats = require(script.Parent.Parent.Stats)
local Passes = require(script.Parent.Parent.Passes)
local DataService = require(script.Parent.DataService)

local OfflineService = {}

local function apply(player: Player, data: any)
	local lastSeen = data.lastSeen or 0
	if lastSeen <= 0 then
		return -- brand-new player
	end
	local seconds = os.time() - lastSeen
	local hops = Game.offlineHops(
		seconds,
		Stats.perBounce(data),
		Stats.hopsMultiplier(player, data),
		Passes.owns(player, "OfflineDouble")
	)
	if hops <= 0 then
		return
	end
	data.hops += hops
	data.lastSeen = os.time()
	DataService.changed(player)
	Net.event("Notify"):FireClient(player, {
		kind = "Offline",
		hops = hops,
		seconds = math.min(seconds, Game.OfflineMaxHours * 3600),
	})
end

function OfflineService.start()
	DataService.Loaded:Connect(apply)
end

return OfflineService
