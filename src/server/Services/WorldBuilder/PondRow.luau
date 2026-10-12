-- Row of training ponds from Config/Ponds: water, rim, lily pads, the stand
-- pad players train on, and an invisible sign anchor. Lock state differs per
-- player, so the signs themselves are drawn by the client (PondSigns).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Ponds = require(Shared.Config.Ponds)

local Parts = require(script.Parent.Parts)

local PondRow = {}

local function flatCylinder(name: string, diameter: number, position: Vector3, color: Color3, parent: Instance): Part
	local part = Parts.block(
		name,
		Vector3.new(0.4, diameter, diameter),
		CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90)),
		color,
		parent
	)
	part.Shape = Enum.PartType.Cylinder
	part.CanCollide = false
	return part
end

local function buildPond(pond: Ponds.Pond, folder: Folder)
	local model = Instance.new("Model")
	model.Name = pond.id
	local center = Ponds.center(pond)
	local top = Parts.GroundTop

	local rim = Parts.block(
		"Rim",
		Vector3.new(Ponds.WidthX + 4, 1.2, Ponds.LengthZ + 4),
		CFrame.new(center.X, top + 0.1, center.Z),
		pond.color:Lerp(Color3.new(0, 0, 0), 0.35),
		model,
		Enum.Material.Slate
	)
	rim.CanCollide = false
	local water = Parts.block(
		"Water",
		Vector3.new(Ponds.WidthX, 1.2, Ponds.LengthZ),
		CFrame.new(center.X, top + 0.2, center.Z),
		pond.color,
		model,
		Enum.Material.Glass
	)
	water.Transparency = 0.2
	water.CanCollide = false

	for i = 1, Ponds.PadsPerPond do
		flatCylinder("LilyPad", 5, Ponds.padPosition(pond, i) + Vector3.new(0, 0.6, 0), Parts.Colors.Pad, model)
	end

	local stand = Ponds.standPosition(pond)
	local pad = Parts.block(
		"StandPad",
		Vector3.new(10, 0.6, 8),
		CFrame.new(stand.X, top + 0.3, stand.Z),
		Color3.fromRGB(230, 120, 70),
		model,
		Enum.Material.Brick
	)
	pad:SetAttribute("PondId", pond.id)

	local anchor = Parts.block(
		"SignAnchor",
		Vector3.new(1, 1, 1),
		CFrame.new(center.X, top + 9, center.Z + Ponds.LengthZ / 2),
		Color3.new(1, 1, 1),
		model
	)
	anchor.Transparency = 1
	anchor.CanCollide = false
	anchor:SetAttribute("PondId", pond.id)

	model.Parent = folder
end

function PondRow.build(world: Model)
	local folder = Instance.new("Folder")
	folder.Name = "Ponds"
	for _, pond in Ponds.List do
		buildPond(pond, folder)
	end
	folder.Parent = world
end

return PondRow
