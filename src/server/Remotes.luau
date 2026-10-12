-- Server side of every RemoteFunction: per-player rate limits (Config/Security)
-- and error isolation, so one bad request can't break a service.
-- Services call Remotes.handle instead of setting OnServerInvoke directly.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Security = require(Shared.Config.Security)
local RateLimit = require(Shared.Util.RateLimit)
local Net = require(Shared.Net)

local Remotes = {}

local buckets: { [Player]: { [string]: RateLimit.Bucket } } = {}

Players.PlayerRemoving:Connect(function(player)
	buckets[player] = nil
end)

local function allowed(player: Player, name: string): boolean
	local limit = Security.limitFor(name)
	local now = os.clock()
	local mine = buckets[player]
	if not mine then
		mine = {}
		buckets[player] = mine
	end
	local bucket = mine[name]
	if not bucket then
		bucket = RateLimit.new(limit.burst, now)
		mine[name] = bucket
	end
	return RateLimit.take(bucket, limit.rate, limit.burst, now)
end

local function defaultReply(message: string): (boolean, string)
	return false, message
end

-- `reply(message)` shapes refusals for remotes that don't return (ok, message).
function Remotes.handle(name: string, handler: (Player, ...any) -> ...any, reply: ((string) -> ...any)?)
	local refuse = reply or defaultReply
	Net.func(name).OnServerInvoke = function(player: Player, ...)
		if not allowed(player, name) then
			return refuse("Slow down!")
		end
		local results = table.pack(pcall(handler, player, ...))
		if not results[1] then
			warn(`[Remotes] {name} failed for {player.Name}: {results[2]}`)
			return refuse("Something went wrong, try again")
		end
		return table.unpack(results, 2, results.n)
	end
end

return Remotes
