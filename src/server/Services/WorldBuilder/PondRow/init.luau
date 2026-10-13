-- Row of gyms from Config/Ponds along the lobby's +Z wall (reference: long
-- pools side by side on the lavender walk). Each gym is a raised border in
-- its colour round themed ground, an irregular pool (Ground), the stand pad
-- players train on (StandPad: where training locks you in place) and its
-- theme's decor (Decor, Themes), plus an invisible sign anchor. Lock state
-- differs per player, so the signs themselves are drawn by the client
-- (PondSigns).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Ponds = require(Shared.Config.Ponds)

local Parts = require(script.Parent.Parts)
local Ground = require(script.Ground)
local StandPad = require(script.StandPad)
local Decor = require(script.Decor)
local Themes = require(script.Themes)

local PondRow = {}

local function buildPond(pond: Ponds.Pond, folder: Folder)
	local model = Instance.new("Model")
	model.Name = pond.id
	local center = Ponds.center(pond)
	local theme = Themes.of(pond.id)
	local levels = Ground.build(pond, theme, model)
	StandPad.build(pond, levels.ground, model)
	Decor.build(pond, theme, levels, model)

	local anchor = Parts.block(
		"SignAnchor",
		Vector3.new(1, 1, 1),
		CFrame.new(center.X, levels.ground + 11, center.Z + Ponds.LengthZ / 2 - 5),
		Color3.new(1, 1, 1),
		model
	)
	anchor.Transparency = 1
	anchor.CanCollide = false
	anchor.CanQuery = false
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
