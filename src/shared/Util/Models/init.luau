--!strict
-- Frog, pet and egg models. Uses the imported cube-style meshes in
-- ReplicatedStorage.Assets when present (Models/Assets), otherwise the
-- part-built placeholders (Models/Placeholders). Callers only rely on
-- PrimaryPart, so both look the same to the rest of the game.

local Assets = require(script.Assets)
local Placeholders = require(script.Placeholders)

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

-- A cube frog `scale` studs wide, facing +X.
function Models.frog(color: Color3, scale: number?): Model
	local s = scale or 2
	local template = Assets.template("Frog")
	local model = template and Assets.build(template, "Body", color, s)
	if model then
		model.Name = "Frog"
		return model
	end
	return Placeholders.frog(color, s)
end

-- A cube pet `size` studs wide, facing -Z, with a name tag.
function Models.pet(name: string, color: Color3, size: number?): Model
	local s = size or 1.6
	local template = Assets.template("Pet")
	local model = template and Assets.build(template, "Body", color, s)
	if model then
		model.Name = name
		nameTag(model.PrimaryPart :: BasePart, name, s)
		return model
	end
	model = Placeholders.pet(color, s)
	nameTag(model.PrimaryPart :: BasePart, name, s)
	model.Name = name
	return model
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
