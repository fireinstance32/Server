--!strict
-- Imported Blender models (tools/blender/build_models.py, build_rocks.py and
-- build_props.py → assets/models/**/*.fbx → Studio 3D Importer → ReplicatedStorage.Assets).
-- Each is cloned, recoloured by part role, scaled and welded to its root.
-- A part's role is its name, or the part after the last "_" (the rock
-- models name parts "<Shape>_<Role>", e.g. RockLava_Glow).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = {}

local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.new(0, 0, 0)

local function same(c: Color3): Color3
	return c
end
local function lighter(t: number): (Color3) -> Color3
	return function(c)
		return c:Lerp(WHITE, t)
	end
end
local function darker(t: number): (Color3) -> Color3
	return function(c)
		return c:Lerp(BLACK, t)
	end
end
local function fixed(r: number, g: number, b: number): (Color3) -> Color3
	local color = Color3.fromRGB(r, g, b)
	return function()
		return color
	end
end

-- How each role is coloured from the frog/pet/egg/rock colour. Roles not
-- listed (eyes, pupils, mouth) keep the colour they were imported with.
-- Keep the rock roles in step with ROLE_TINTS/FIXED in build_rocks.py.
local TINTS: { [string]: (Color3) -> Color3 } = {
	Body = same,
	Shell = same,
	Belly = function(c)
		return c:Lerp(Color3.new(1, 1, 0.85), 0.6)
	end,
	Spots = lighter(0.55),
	Foot = darker(0.25),
	Ear = darker(0.3),
	-- Rocks
	Root = same,
	Shade = darker(0.35),
	Crust = darker(0.78),
	Crystal = lighter(0.3),
	-- Dark rocks' glow lightens more, or the Neon would stay dark.
	Glow = function(c)
		local luminance = 0.299 * c.R + 0.587 * c.G + 0.114 * c.B
		return c:Lerp(WHITE, if luminance < 0.3 then 0.55 else 0.15)
	end,
	Band = lighter(0.45),
	Cap = same,
	Jelly = same,
	Moss = same,
	Ore = same,
	Gem = same,
	Stone = fixed(125, 120, 115),
	Stem = fixed(240, 230, 210),
	Frosting = fixed(255, 235, 245),
	Sprinkles = fixed(255, 90, 170),
	Cherry = fixed(220, 20, 50),
	Stick = fixed(200, 160, 110),
	Shine = fixed(255, 255, 255),
	Gold = fixed(255, 195, 45),
	-- Props (build_props.py)
	Wood = fixed(176, 124, 78),
	Rubber = fixed(42, 42, 48),
	Steel = fixed(188, 194, 204),
	Iron = fixed(70, 72, 82),
	Chalk = fixed(246, 246, 240),
}

-- Surface looks per role (everything else is SmoothPlastic).
local LOOKS: { [string]: { material: Enum.Material?, reflectance: number?, transparency: number? } } = {
	Root = { transparency = 1 },
	Glow = { material = Enum.Material.Neon },
	Crystal = { reflectance = 0.2 },
	Gold = { material = Enum.Material.Metal, reflectance = 0.25 },
	Jelly = { transparency = 0.2, reflectance = 0.1 },
	Shine = { material = Enum.Material.Neon },
	Ore = { material = Enum.Material.Metal, reflectance = 0.15 },
	Gem = { material = Enum.Material.Glass, reflectance = 0.25, transparency = 0.1 },
	Wood = { material = Enum.Material.WoodPlanks },
	Steel = { material = Enum.Material.Metal, reflectance = 0.3 },
	Iron = { material = Enum.Material.Metal },
	Rubber = { material = Enum.Material.Rubber },
}

local function roleOf(name: string): string
	return string.match(name, "_(%a+)$") or name
end

-- The imported template, or nil if it hasn't been imported yet. Looks in
-- Assets and in Assets.Rocks / Assets.Props (the combined Rocks.fbx and
-- Props.fbx imports).
function Assets.template(name: string): Model?
	local folder = ReplicatedStorage:FindFirstChild("Assets")
	if not folder then
		return nil
	end
	local template = folder:FindFirstChild(name)
	for _, group in { "Rocks", "Props" } do
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
			part.CastShadow = false
			local role = roleOf(part.Name)
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
