--!strict
-- Imported Blender models (tools/blender/build_models.py → assets/models/*.fbx
-- → Studio 3D Importer → ReplicatedStorage.Assets.<Frog|Pet|Egg>). Each is
-- cloned, recoloured by part name, scaled and welded to its Body/Shell.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = {}

local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.new(0, 0, 0)

-- How each named part is coloured from the frog/pet/egg colour. Parts not
-- listed (eyes, pupils, mouth) keep the colour they were imported with.
local TINTS: { [string]: (Color3) -> Color3 } = {
	Body = function(c)
		return c
	end,
	Shell = function(c)
		return c
	end,
	Belly = function(c)
		return c:Lerp(Color3.new(1, 1, 0.85), 0.6)
	end,
	Spots = function(c)
		return c:Lerp(WHITE, 0.55)
	end,
	Foot = function(c)
		return c:Lerp(BLACK, 0.25)
	end,
	Ear = function(c)
		return c:Lerp(BLACK, 0.3)
	end,
}

-- The imported template, or nil if it hasn't been imported yet.
function Assets.template(name: string): Model?
	local folder = ReplicatedStorage:FindFirstChild("Assets")
	local template = folder and folder:FindFirstChild(name)
	return if template and template:IsA("Model") then template else nil
end

-- Clone of `template` coloured from `color`, `width` studs wide.
function Assets.build(template: Model, rootName: string, color: Color3, width: number): Model?
	local model = template:Clone()
	local root = model:FindFirstChild(rootName, true)
	if not (root and root:IsA("BasePart")) then
		warn(`[Models] Assets.{template.Name} has no part named {rootName}; using the placeholder`)
		model:Destroy()
		return nil
	end
	model.PrimaryPart = root
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.CastShadow = false
			local tint = TINTS[part.Name]
			if tint then
				part.Color = tint(color)
			end
			if part ~= root then
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = root
				weld.Part1 = part
				weld.Parent = part
			end
		end
	end
	local size = model:GetExtentsSize()
	-- ScaleTo is absolute, so scale relative to the template's own factor.
	local current: number = (model :: any):GetScale()
	model:ScaleTo(current * width / math.max(size.X, size.Z))
	return model
end

return Assets
