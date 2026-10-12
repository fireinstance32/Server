--!strict
-- Frog, pet and egg models. Uses the imported cube-style meshes in
-- ReplicatedStorage.Assets when present (Models/Assets), otherwise the
-- part-built models (Models/Pet for frogs and pets, Models/Placeholders for the egg). Callers only rely on
-- PrimaryPart, so both look the same to the rest of the game.

local Assets = require(script.Assets)
local Placeholders = require(script.Placeholders)
local Pet = require(script.Pet)
local PetLooks = require(script.Parent.Parent.Config.PetLooks)

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

-- A cube frog `scale` studs wide, facing +X. Built like the pets ("frog"
-- look + per-frog extras such as crowns) unless an Assets.Frog mesh exists.
function Models.frog(color: Color3, scale: number?, frogId: string?): Model
	local s = scale or 2
	local template = Assets.template("Frog")
	local model = template and Assets.build(template, "Body", color, s)
	if model then
		model.Name = "Frog"
		return model
	end
	local frog = Pet.build(color, s * 0.8, "frog", nil, PetLooks.FrogExtras[frogId or ""])
	frog.Name = "Frog"
	-- Pets face -Z; turn the frog to face +X and keep its pivot unrotated, so
	-- callers' PivotTo(CFrame.new(pos)) keeps it facing +X.
	local body = frog.PrimaryPart :: BasePart
	frog:PivotTo(CFrame.Angles(0, -math.pi / 2, 0))
	body.PivotOffset = CFrame.Angles(0, math.pi / 2, 0)
	return frog
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
