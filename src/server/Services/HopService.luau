-- The core loop. "Train" = quick hops in the small pond for Hops.
-- "Launch" = big hop down the river: Hops per lily pad plus Wins for the zone reached.
-- The server decides everything; the client only animates the returned result.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)
local Zones = require(Shared.Config.Zones)
local Ponds = require(Shared.Config.Ponds)
local Net = require(Shared.Net)

local Stats = require(script.Parent.Parent.Stats)
local DataService = require(script.Parent.DataService)
local ProgressionService = require(script.Parent.ProgressionService)
local HeldFrogService = require(script.Parent.HeldFrogService)
local Passes = require(script.Parent.Parent.Passes)

local HopService = {}

local busyUntil: { [Player]: number } = {}

local function rootPosition(player: Player): Vector3?
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return if root then (root :: BasePart).Position else nil
end

local function train(player: Player, data: any, pond: Ponds.Pond)
	local bounces = Game.TrainingBounces
	local context = { mode = "Train", pond = pond.id }
	local hopsGained = math.floor(bounces * Stats.perBounce(data) * Stats.hopsMultiplier(player, data, context))
	data.hops += hopsGained
	ProgressionService.addXp(player, data, bounces)
	busyUntil[player] = os.clock() + Game.TrainingCooldown
	DataService.changed(player)
	return { ok = true, mode = "Train", pond = pond.id, bounces = bounces, hopsGained = hopsGained }
end

local function launch(player: Player, data: any)
	local distance = math.min(Game.distanceForHops(data.hops), Zones.RiverLength)
	local bounces = math.max(1, math.floor(distance / Game.PadSpacing))
	local zone = Zones.zoneForDistance(distance)
	local context = { mode = "Launch", zone = zone.index }
	local hopsGained = math.floor(bounces * Stats.perBounce(data) * Stats.hopsMultiplier(player, data, context))
	local winsGained = math.floor(zone.wins * Stats.winsMultiplier(player, data, context))
	local flight = Game.flightTime(bounces)
	local previousBest = data.bestDistance

	busyUntil[player] = os.clock() + flight
	-- The frog leaves the hand after the wind-up and is back once it lands.
	HeldFrogService.hideDuring(player, HeldFrogService.ReleaseDelay, flight - HeldFrogService.ReleaseDelay)

	-- Pay out when the frog lands so the stats tick up with the animation.
	task.delay(flight, function()
		local current = DataService.get(player)
		if current ~= data then
			return -- player left (or data was replaced) mid-flight
		end
		data.hops += hopsGained
		data.wins += winsGained
		ProgressionService.addXp(player, data, bounces)
		if distance > data.bestDistance then
			data.bestDistance = distance
		end
		DataService.changed(player)
	end)

	return {
		ok = true,
		mode = "Launch",
		bounces = bounces,
		distance = distance,
		meters = Game.metersFor(distance),
		bestMeters = Game.metersFor(math.max(previousBest, distance)),
		newBest = distance > previousBest,
		zone = zone.index,
		zoneName = zone.name,
		hopsGained = hopsGained,
		winsGained = winsGained,
		flightTime = flight,
	}
end

local function onHop(player: Player, mode: unknown)
	if mode ~= "Train" and mode ~= "Launch" then
		return { ok = false, message = "Invalid hop" }
	end
	local data = DataService.get(player)
	if not data then
		return { ok = false, message = "Still loading..." }
	end
	if os.clock() < (busyUntil[player] or 0) then
		return { ok = false, message = "busy" }
	end

	local position = rootPosition(player)
	if not position then
		return { ok = false, message = "No character" }
	end

	if mode == "Train" then
		local pond = Ponds.at(position)
		if not pond then
			return { ok = false, message = "Stand on a training pond's pad!" }
		end
		local locked = Ponds.lockReason(pond, data.rebirths, function(pass)
			return Passes.owns(player, pass)
		end)
		if locked then
			return { ok = false, message = `{pond.name}: {locked}` }
		end
		return train(player, data, pond)
	else
		if not Game.inHopZone(position.X, position.Z) then
			return { ok = false, message = "Stand in the Hop Zone!" }
		end
		return launch(player, data)
	end
end

function HopService.start()
	Net.func("Hop").OnServerInvoke = onHop
	Players.PlayerRemoving:Connect(function(player)
		busyUntil[player] = nil
	end)
end

return HopService
