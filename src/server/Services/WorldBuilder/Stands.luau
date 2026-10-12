-- Egg stands and the frog shop, each with a ProximityPrompt the client handles.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Pets = require(Shared.Config.Pets)
local Format = require(Shared.Util.Format)

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

local function buildStands(world: Model)
	for _, egg in Pets.Eggs do
		local stand = standWithPrompt(
			world,
			"EggStand_" .. egg.id,
			egg.position,
			Color3.fromRGB(240, 230, 210),
			"Hatch",
			`{egg.name} ({Format.abbreviate(egg.price)} Wins)`
		)
		local prompt = stand:FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt
		prompt:SetAttribute("EggId", egg.id)

		local eggPart = Parts.block(
			"Egg",
			Vector3.new(5, 6.5, 5),
			stand.CFrame * CFrame.new(0, 4.75, 0),
			Pets.RarityColors[Pets.ById[egg.pets[#egg.pets].pet].rarity],
			stand
		)
		eggPart.Shape = Enum.PartType.Ball
		Parts.sign(eggPart, egg.name, `{Format.abbreviate(egg.price)} Wins`)
	end

	local shop = standWithPrompt(
		world,
		"FrogShop",
		Vector3.new(-70, 0, -50),
		Color3.fromRGB(120, 210, 120),
		"Open",
		"Frog Shop"
	)
	local prompt = shop:FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt
	prompt:SetAttribute("OpenMenu", "Frogs")
	Parts.sign(shop, "FROG SHOP", "Better frogs = more Hops!")
end

function Stands.build(world: Model)
	buildStands(world)
end

return Stands
