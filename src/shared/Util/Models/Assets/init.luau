--!strict
-- Imported Blender models (tools/blender/build_models.py, build_rocks.py and
-- build_props.py → assets/models/**/*.fbx → Studio 3D Importer → ReplicatedStorage.Assets).
-- Each is cloned, recoloured by part role (Assets/Roles), scaled and welded to its root.
-- A part's role is its name, or the part after the last "_" (the rock
-- models name parts "<Shape>_<Role>", e.g. RockLava_Glow).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = {}

local Roles = require(script.Roles)
local TINTS, LOOKS = Roles.TINTS, Roles.LOOKS

local function roleOf(name: string): string
	return string.match(name, "_(%a+)$") or name
end

-- The imported template, or nil if it hasn't been imported yet. Looks in
-- Assets and in Assets.Rocks / Props / Nature / Decor (the combined
-- Rocks.fbx, Props.fbx, Nature.fbx and Decor.fbx imports).
function Assets.template(name: string): Model?
	local folder = ReplicatedStorage:FindFirstChild("Assets")
	if not folder then
		return nil
	end
	local template = folder:FindFirstChild(name)
	for _, group in { "Rocks", "Props", "Nature", "Decor" } do
		local sub = folder:FindFirstChild(group)
		if not template and sub then
			template = sub:FindFirstChild(name)
		end
	end
	return if template and template:IsA("Model") then template else nil
end

-- Clone of `template` coloured from `color`, `width` studs wide, welded to
-- its part whose role is `rootName`.
function Assets.build(template: Model, rootName: string, color: Color3, width: number): Model?
	local model = template:Clone()
	local root: BasePart? = nil
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") and roleOf(part.Name) == rootName then
			root = part
			break
		end
	end
	if not root then
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
			local role = roleOf(part.Name)
			part.CastShadow = role ~= "Glow" -- the reference scenery throws shadows
			local tint = TINTS[role]
			if tint then
				part.Color = tint(color)
				-- An imported PBR look would hide the tint.
				local appearance = part:FindFirstChildOfClass("SurfaceAppearance")
				if appearance then
					appearance:Destroy()
				end
			end
			local look = LOOKS[role]
			if look then
				part.Material = look.material or part.Material
				part.Reflectance = look.reflectance or part.Reflectance
				part.Transparency = look.transparency or part.Transparency
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
