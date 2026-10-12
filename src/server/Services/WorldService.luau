-- World travel through the hub portals. A world unlocks permanently the
-- first time the player travels there with enough Hops (its gate).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Worlds = require(Shared.Config.Worlds)
local Format = require(Shared.Util.Format)
local Net = require(Shared.Net)

local DataService = require(script.Parent.DataService)

local WorldService = {}

-- Where travellers arrive (above the spawn / landing pad).
local ARRIVAL = Vector3.new(-100, 5, 0)

function WorldService.arrivalPoint(world: Worlds.World): Vector3
	return ARRIVAL + Worlds.offset(world)
end

-- Unlocks (if affordable) and teleports. Returns ok, message.
function WorldService.travel(player: Player, worldId: unknown): (boolean, string)
	local data = DataService.get(player)
	local world = typeof(worldId) == "string" and Worlds.ById[worldId]
	if not data or not world then
		return false, "Invalid world"
	end
	if not Worlds.isUnlocked(world, data.worldsUnlocked) then
		if data.hops < world.gateHops then
			return false, `{world.name} needs {Format.abbreviate(world.gateHops)} Hops`
		end
		data.worldsUnlocked[world.id] = true
		DataService.changed(player)
	end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then
		return false, "No character"
	end
	root.CFrame = CFrame.new(WorldService.arrivalPoint(world))
	return true, `Welcome to {world.name}!`
end

function WorldService.start()
	Net.func("TravelWorld").OnServerInvoke = WorldService.travel
end

return WorldService
