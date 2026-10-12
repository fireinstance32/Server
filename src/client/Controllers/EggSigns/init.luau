-- Egg signs in every hub: name + price from afar, the odds panel (luck
-- changes the odds per player) when you walk up. Event egg signs only show
-- while their event runs. Each sign is built by Sign.luau.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Pets = require(Shared.Config.Pets)
local Worlds = require(Shared.Config.Worlds)
local Events = require(Shared.Config.Events)

local Theme = require(script.Parent.Parent.UI.Theme)
local State = require(script.Parent.Parent.State)
local Sign = require(script.Sign)

local EggSigns = {}

local NEAR = 18 -- studs from the stand to show the odds panel

function EggSigns.init()
	local root = Workspace:WaitForChild("World")
	local container = Theme.new("Folder", { Name = "EggSigns", Parent = Players.LocalPlayer:WaitForChild("PlayerGui") })
	local signs: { { egg: Pets.Egg, stand: BasePart, sign: Sign.Sign } } = {}
	for _, world in Worlds.List do
		local hub = root:WaitForChild(world.id)
		for _, egg in Pets.eggsForWorld(world.id) do
			local stand = hub:WaitForChild("EggStand_" .. egg.id) :: BasePart
			table.insert(signs, { egg = egg, stand = stand, sign = Sign.build(egg, stand, container) })
		end
	end

	local function eventRunning(egg: Pets.Egg): boolean
		if not egg.event then
			return true
		end
		local active = Events.active(Workspace:GetServerTimeNow(), ReplicatedStorage:GetAttribute(Events.OverrideAttribute))
		return active ~= nil and active.id == egg.event
	end

	State.observe(function(data)
		for _, entry in signs do
			entry.sign.refresh(data)
		end
	end)

	-- Show the odds panel for the egg you're standing at; hide ended events.
	task.spawn(function()
		while container.Parent do
			local character = Players.LocalPlayer.Character
			local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
			for _, entry in signs do
				local running = eventRunning(entry.egg)
				entry.sign.title.Enabled = running
				local near = root ~= nil and (root.Position - entry.stand.Position).Magnitude <= NEAR
				entry.sign.odds.Enabled = running and near
			end
			task.wait(0.25)
		end
	end)
end

return EggSigns
