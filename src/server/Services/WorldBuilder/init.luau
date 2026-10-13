-- Builds every world's hub at server start from Shared.Config. Each world is
-- built in the same local layout inside Workspace.World.<WorldId>, then
-- moved to its offset (Config/Worlds). Each area lives in its own module.
-- To use a hand-built map instead, put a Folder named "World" in Workspace;
-- generation is skipped if it already exists.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Worlds = require(ReplicatedStorage:WaitForChild("Shared").Config.Worlds)

local Environment = require(script.Environment)
local Lane = require(script.Lane)
local Floor = require(script.Hub.Floor)
local Paths = require(script.Hub.Paths)
local Cliffs = require(script.Hub.Cliffs)
local Plaza = require(script.Plaza)
local Stands = require(script.Stands)
local PondRow = require(script.PondRow)
local FrogPodiums = require(script.FrogPodiums)
local Portals = require(script.Portals)
local Leaderboards = require(script.Leaderboards)

local WorldBuilder = {}

function WorldBuilder.init()
	if workspace:FindFirstChild("World") then
		return
	end
	local baseplate = workspace:FindFirstChild("Baseplate")
	if baseplate then
		baseplate:Destroy()
	end

	local root = Instance.new("Folder")
	root.Name = "World"
	root.Parent = workspace
	Environment.buildLighting()

	for _, config in Worlds.List do
		local world = Instance.new("Model")
		world.Name = config.id
		Floor.build(world, config)
		Paths.build(world)
		Cliffs.build(world, config)
		Lane.build(world, config)
		Plaza.build(world, config)
		Stands.build(world, config)
		PondRow.build(world)
		FrogPodiums.build(world, config)
		Portals.build(world, config)
		Leaderboards.build(world)
		world:TranslateBy(Worlds.offset(config))
		world.Parent = root
	end
end

return WorldBuilder
