--!strict
-- Rock, pet and egg models. Uses the imported Blender meshes in
-- ReplicatedStorage.Assets when present (Models/Assets), otherwise the
-- part-built models (Models/Rock, Models/Pet, Models/Placeholders for the
-- egg). Callers only rely on PrimaryPart, so both look the same to the rest
-- of the game.

local Assets = require(script.Assets)
local Placeholders = require(script.Placeholders)
local Pet = require(script.Pet)
local Rock = require(script.Rock)
local PetLooks = require(script.Parent.Parent.Config.PetLooks)
local RockLooks = require(script.Parent.Parent.Config.RockLooks)

local Models = {}

-- Name tag over a pet (both model kinds).
local function nameTag(body: BasePart, name: string, height: number)
	local tag = Instance.new("BillboardGui")
	tag.Size = UDim2.fromOffset(120, 24)
	tag.StudsOffset = Vector3.new(0, height, 0)
	tag.AlwaysOnTop = true
	tag.MaxDistance = 60
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.3
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.Parent = tag
	tag.Parent = body
end

-- A rock `scale` studs across (the equipped item). Uses the rock's Blender
-- shape (Config/RockLooks) from ReplicatedStorage.Assets, then the plain
-- "Rock" shape, then the part-built rock (Models/Rock). Crowned rocks wear
-- Assets.Crown; glowing rocks (the ultimate ones) get a light.
function Models.rock(color: Color3, scale: number?, rockId: string?, glow: boolean?): Model
	local s = scale or 2
	local template = Assets.template(RockLooks.shapeFor(rockId)) or Assets.template("Rock")
	local model = template and Assets.build(template, "Root", color, s)
	if not model then
		return Rock.build(color, s, rockId, glow)
	end
	model.Name = "Rock"
	local root = model.PrimaryPart :: BasePart
	local crownTemplate = rockId and RockLooks.Crowned[rockId] and Assets.template("Crown")
	local crown = crownTemplate and Assets.build(crownTemplate, "Root", color, s * 0.6)
	if crown then
		local box, size = model:GetBoundingBox()
		local top = root.CFrame:PointToObjectSpace(box.Position).Y + size.Y / 2
		local height = crown:GetExtentsSize().Y
		crown:PivotTo(root.CFrame * CFrame.new(0, top + height * 0.2, 0))
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = root
		weld.Part1 = crown.PrimaryPart
		weld.Parent = crown.PrimaryPart
		crown.Parent = model
	end
	if glow then
		local light = Instance.new("PointLight")
		light.Color = color
		light.Range = s * 4
		light.Brightness = 1.5
		light.Parent = root
	end
	return model
end

export type PetDef = { id: string, name: string, color: Color3, rarity: string }

-- A cube pet `size` studs wide, facing -Z, with a name tag. Part-built
-- per animal look (Models/Pet) unless an imported Assets.Pet mesh exists.
function Models.pet(def: PetDef, size: number?): Model
	local s = size or 1.6
	local template = Assets.template("Pet")
	local model = template and Assets.build(template, "Body", def.color, s)
	if not model then
		model = Pet.build(def.color, s, PetLooks.ByPet[def.id], def.rarity)
	end
	local built = model :: Model
	built.Name = def.name
	nameTag(built.PrimaryPart :: BasePart, def.name, s)
	return built
end

-- An egg `height` studs tall.
function Models.egg(color: Color3, height: number?): Model
	local h = height or 4
	local template = Assets.template("Egg")
	local model = template and Assets.build(template, "Shell", color, h * 0.78)
	if model then
		model.Name = "Egg"
		return model
	end
	return Placeholders.egg(color, h)
end

return Models
