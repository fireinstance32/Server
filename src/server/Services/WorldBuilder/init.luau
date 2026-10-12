-- Builds the World 1 greybox at server start from Shared.Config, so balance
-- changes move the map. Each area lives in its own module in this folder.
-- To use a hand-built map instead, put a Model named "World" in Workspace;
-- generation is skipped if it already exists.

local Environment = require(script.Environment)
local River = require(script.River)
local Plaza = require(script.Plaza)
local Stands = require(script.Stands)
local PondRow = require(script.PondRow)
local FrogPodiums = require(script.FrogPodiums)

local WorldBuilder = {}

function WorldBuilder.init()
	if workspace:FindFirstChild("World") then
		return
	end
	local baseplate = workspace:FindFirstChild("Baseplate")
	if baseplate then
		baseplate:Destroy()
	end

	local world = Instance.new("Model")
	world.Name = "World"
	world.Parent = workspace

	Environment.build(world)
	River.build(world)
	Plaza.build(world)
	Stands.build(world)
	PondRow.build(world)
	FrogPodiums.build(world)
end

return WorldBuilder
