-- Row of pedestals, one per frog, each showing the frog with a prompt and a
-- sign anchor. Signs and prompt text depend on what each player owns, so
-- the client fills them in (client FrogPodiums controller).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Frogs = require(Shared.Config.Frogs)
local Models = require(Shared.Util.Models)

local Parts = require(script.Parent.Parts)

local FrogPodiums = {}

function FrogPodiums.build(world: Model)
	local folder = Instance.new("Folder")
	folder.Name = "FrogPodiums"
	for i, frog in Frogs.List do
		local base = Frogs.podiumPosition(i)
		local model = Instance.new("Model")
		model.Name = frog.id

		local pedestal = Parts.block(
			"Pedestal",
			Vector3.new(8, 3, 8),
			CFrame.new(base + Vector3.new(0, 1.5, 0)),
			if frog.robuxOnly then Color3.fromRGB(120, 60, 160) else Color3.fromRGB(225, 225, 235),
			model,
			Enum.Material.SmoothPlastic
		)
		local display = Models.frog(frog.color, 3)
		display:PivotTo(CFrame.new(base + Vector3.new(0, 4.6, 0)) * CFrame.Angles(0, math.rad(-90), 0))
		display.Name = "Display"
		display.Parent = model

		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Buy"
		prompt.ObjectText = frog.name
		prompt.HoldDuration = 0
		prompt.MaxActivationDistance = 10
		prompt.RequiresLineOfSight = false
		prompt:SetAttribute("FrogId", frog.id)
		prompt.Parent = pedestal

		local anchor = Parts.block("SignAnchor", Vector3.one, CFrame.new(base + Vector3.new(0, 9.5, 0)), Color3.new(1, 1, 1), model)
		anchor.Transparency = 1
		anchor.CanCollide = false

		model.Parent = folder
	end
	folder.Parent = world
end

return FrogPodiums
