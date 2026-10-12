-- Egg stands, each with a ProximityPrompt (E) the client handles.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Pets = require(Shared.Config.Pets)
local Worlds = require(Shared.Config.Worlds)
local Events = require(Shared.Config.Events)
local Format = require(Shared.Util.Format)
local Models = require(Shared.Util.Models)

local Parts = require(script.Parent.Parts)

local Stands = {}

local function standWithPrompt(world: Model, name: string, position: Vector3, color: Color3, actionText: string, objectText: string): Part
	local base = Parts.block(
		name,
		Vector3.new(10, 3, 10),
		CFrame.new(position + Vector3.new(0, Parts.GroundTop + 1.5, 0)),
		color,
		world
	)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 14
	prompt.RequiresLineOfSight = false
	prompt.Parent = base
	return base
end

local function buildStands(world: Model, config: Worlds.World)
	for _, egg in Pets.eggsForWorld(config.id) do
		local stand = standWithPrompt(
			world,
			"EggStand_" .. egg.id,
			egg.position,
			Color3.fromRGB(240, 230, 210),
			"Hatch",
			if egg.product then `{egg.name} (Robux)`
				elseif egg.event then `{egg.name} ({egg.price} {Events.ById[egg.event].currency})`
				else `{egg.name} ({Format.abbreviate(egg.price)} Wins)`
		)
		local prompt = stand:FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt
		prompt:SetAttribute("EggId", egg.id)

		local display = Models.egg(egg.color, 6.5)
		display:PivotTo(stand.CFrame * CFrame.new(0, 4.75, 0))
		display.Parent = stand
		-- Name, price and odds are drawn by the client (EggSigns), since luck
		-- changes the odds per player.
	end
end

function Stands.build(world: Model, config: Worlds.World)
	buildStands(world, config)
end

return Stands
