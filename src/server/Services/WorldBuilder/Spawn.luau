-- The spawn pad in the middle of the lobby (Config/Lobby), facing the
-- Throw Zone. (The Throw Zone itself is part of the map: Hub/ThrowZone.)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Worlds = require(Shared.Config.Worlds)
local Lobby = require(Shared.Config.Lobby)

local Spawn = {}

function Spawn.build(world: Model, config: Worlds.World)
	-- Only the first world has the real SpawnLocation; others get a plain
	-- landing pad that world travel teleports to.
	local spawn = if config.index == 1 then Instance.new("SpawnLocation") else Instance.new("Part")
	spawn.Name = if config.index == 1 then "Spawn" else "Landing"
	spawn.Anchored = true
	spawn.Size = Vector3.new(10, 1, 10)
	local at = Lobby.Spawn + Vector3.new(0, 0.6, 0)
	spawn.CFrame = CFrame.lookAt(at, at + Vector3.xAxis)
	spawn.Color = Color3.fromRGB(255, 220, 90)
	spawn.Material = Enum.Material.SmoothPlastic
	spawn.TopSurface = Enum.SurfaceType.Smooth
	if spawn:IsA("SpawnLocation") then
		spawn.Duration = 0
	end
	spawn.Parent = world
end

return Spawn
