-- Builds the worlds from Shared.Config, in two parts:
--
--   Workspace.Map.<WorldId>    the static scenery (lobby floor, terraced
--                              walls, paths, rock shelf, waterfalls, Throw
--                              Zone, the throw lane and its water). Built
--                              once and saved with the place so it can be
--                              edited in Studio (e.g. a stud plugin). The
--                              server only builds a world's map if it's
--                              missing. To rebuild one in Studio (Edit):
--                              require(game.ServerScriptService.Server.Services.WorldBuilder).buildMap("Lily")
--   Workspace.World.<WorldId>  the interactive parts (spawn, gyms, rock
--                              podiums, eggs, portals, leaderboards), always
--                              rebuilt at server start from the config.
--
-- Each world is built in the same local layout, then moved to its offset
-- (Config/Worlds). Each area lives in its own module.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Worlds = require(Shared.Config.Worlds)
local Game = require(Shared.Config.Game)
local LobbyGrid = require(Shared.Util.LobbyGrid)

local Environment = require(script.Environment)
local Lane = require(script.Lane)
local Floor = require(script.Hub.Floor)
local Walls = require(script.Hub.Walls)
local Waterfalls = require(script.Hub.Waterfalls)
local Paths = require(script.Hub.Paths)
local Shelf = require(script.Hub.Shelf)
local ThrowZone = require(script.Hub.ThrowZone)
local Spawn = require(script.Spawn)
local Stands = require(script.Stands)
local PondRow = require(script.PondRow)
local FrogPodiums = require(script.FrogPodiums)
local Portals = require(script.Portals)
local Leaderboards = require(script.Leaderboards)

local WorldBuilder = {}

local function folder(name: string): Instance
	local existing = workspace:FindFirstChild(name)
	if existing then
		return existing
	end
	local made = Instance.new("Folder")
	made.Name = name
	made.Parent = workspace
	return made
end

-- Builds (or rebuilds) the map of world `worldId`, or of every world.
function WorldBuilder.buildMap(worldId: string?)
	local root = folder("Map")
	for _, config in Worlds.List do
		if worldId == nil or config.id == worldId then
			local old = root:FindFirstChild(config.id)
			if old then
				old:Destroy()
			end
			local map = Instance.new("Model")
			map.Name = config.id
			local grid = LobbyGrid.build()
			Floor.build(map, config, grid)
			Walls.build(map, config)
			Waterfalls.build(map)
			Paths.build(map, grid)
			Shelf.build(map, config)
			ThrowZone.build(map)
			Lane.build(map, config)
			map:TranslateBy(Worlds.offset(config))
			map.Parent = root
		end
	end
end

-- Rebuilds every world's interactive parts.
function WorldBuilder.buildWorld()
	local old = workspace:FindFirstChild("World")
	if old then
		old:Destroy()
	end
	local root = Instance.new("Folder")
	root.Name = "World"
	for _, config in Worlds.List do
		local world = Instance.new("Model")
		world.Name = config.id
		Spawn.build(world, config)
		Stands.build(world, config)
		PondRow.build(world)
		FrogPodiums.build(world, config)
		Portals.build(world, config)
		Leaderboards.build(world)
		world:TranslateBy(Worlds.offset(config))
		world.Parent = root
	end
	root.Parent = workspace
end

function WorldBuilder.init()
	StarterPlayer.CharacterWalkSpeed = Game.WalkSpeed
	-- The template's baseplate and spawn would sit in the middle of the map.
	for _, name in { "Baseplate", "SpawnLocation" } do
		local leftover = workspace:FindFirstChild(name)
		if leftover then
			leftover:Destroy()
		end
	end
	Environment.buildLighting()
	local maps = folder("Map")
	for _, config in Worlds.List do
		if not maps:FindFirstChild(config.id) then
			WorldBuilder.buildMap(config.id)
		end
	end
	WorldBuilder.buildWorld()
end

return WorldBuilder
