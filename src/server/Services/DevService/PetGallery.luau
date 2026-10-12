-- /petgallery: every pet lined up near spawn in Lily Valley, facing spawn,
-- so pet models can be reviewed in Studio. Run it again to remove them.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Pets = require(Shared.Config.Pets)
local PetLooks = require(Shared.Config.PetLooks)
local Models = require(Shared.Util.Models)

local PetGallery = {}

local SIZE = 3 -- studs (equipped pets are 1.6)
local SPACING = 5.5
local PER_ROW = 22
local START = Vector3.new(-30, 0.5, 48) -- first pet; rows go back along +Z

function PetGallery.toggle(): string
	local existing = workspace:FindFirstChild("PetGallery")
	if existing then
		existing:Destroy()
		return "Pet gallery removed"
	end
	local folder = Instance.new("Folder")
	folder.Name = "PetGallery"
	for i, def in Pets.List do
		local row, col = (i - 1) // PER_ROW, (i - 1) % PER_ROW
		local model = Models.pet(def, SIZE)
		local position = START + Vector3.new(-col * SPACING, SIZE * 0.64, row * 8)
		model:PivotTo(CFrame.new(position))
		local tag = model.PrimaryPart and model.PrimaryPart:FindFirstChildOfClass("BillboardGui")
		local label = tag and tag:FindFirstChildOfClass("TextLabel")
		if label then
			label.Text = `{def.name} ({PetLooks.ByPet[def.id] or "bear"})`
			label.TextColor3 = Pets.RarityColors[def.rarity]
		end
		model.Parent = folder
	end
	folder.Parent = workspace
	return `Pet gallery: {#Pets.List} pets next to spawn (run /petgallery again to remove)`
end

return PetGallery
