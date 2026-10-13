-- Row of gyms from Config/Ponds along the lobby's +Z wall: a low coloured
-- platform, the stand pad players train on, the gym kit (GymKit) and an
-- invisible sign anchor. Lock state differs per
-- player, so the signs themselves are drawn by the client (PondSigns).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Ponds = require(Shared.Config.Ponds)

local Parts = require(script.Parent.Parts)
local GymKit = require(script.Parent.GymKit)

local PondRow = {}

local RISE = 0.4 -- platform height above the floor

local function buildPond(pond: Ponds.Pond, folder: Folder)
	local model = Instance.new("Model")
	model.Name = pond.id
	local center = Ponds.center(pond)
	local base = Ponds.SurfaceY
	local floor = base + RISE

	-- A low platform in the gym's dark colour with a glassy inlay in its
	-- colour, and the stand pad in the middle.
	Parts.block(
		"Base",
		Vector3.new(Ponds.WidthX, RISE + 1, Ponds.LengthZ),
		CFrame.new(center.X, floor - (RISE + 1) / 2, center.Z),
		pond.color:Lerp(Color3.new(0, 0, 0), 0.35),
		model
	)
	local inlay = Parts.block(
		"Inlay",
		Vector3.new(Ponds.WidthX - 2, 0.1, Ponds.LengthZ - 2),
		CFrame.new(center.X, floor + 0.05, center.Z),
		pond.color,
		model,
		Enum.Material.Glass
	)
	inlay.Transparency = 0.15
	inlay.CanCollide = false

	local stand = Ponds.standPosition(pond)
	local pad = Parts.block(
		"StandPad",
		Vector3.new(7, 0.3, 7),
		CFrame.new(stand.X, floor + 0.15, stand.Z),
		pond.color:Lerp(Color3.new(1, 1, 1), 0.45),
		model
	)
	pad:SetAttribute("PondId", pond.id)
	GymKit.decorate(pond, model, pad, floor)

	local anchor = Parts.block(
		"SignAnchor",
		Vector3.new(1, 1, 1),
		CFrame.new(center.X, base + 11, center.Z + Ponds.LengthZ / 2 - 1),
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
