--!strict
-- Placeholder models built from parts so the rough copy needs no uploaded
-- assets. Swap these for real meshes later; callers only rely on PrimaryPart.

local Models = {}

local function part(props: { [string]: any }): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for key, value in props do
		(p :: any)[key] = value
	end
	return p
end

local function weldTo(root: BasePart, child: BasePart)
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = child
	weld.Parent = child
end

-- A chubby cartoon frog roughly `scale` studs wide, facing +X.
function Models.frog(color: Color3, scale: number?): Model
	local s = scale or 2
	local model = Instance.new("Model")
	model.Name = "Frog"

	local body = part({
		Name = "Body",
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(s, s * 0.8, s),
		Color = color,
		Material = Enum.Material.SmoothPlastic,
	})
	body.Parent = model
	model.PrimaryPart = body

	local belly = part({
		Name = "Belly",
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(s * 0.7, s * 0.55, s * 0.8),
		Color = color:Lerp(Color3.new(1, 1, 0.85), 0.6),
		CFrame = body.CFrame * CFrame.new(s * 0.18, -s * 0.12, 0),
	})
	belly.Parent = model
	weldTo(body, belly)

	for _, side in { -1, 1 } do
		local eye = part({
			Name = "Eye",
			Shape = Enum.PartType.Ball,
			Size = Vector3.one * s * 0.38,
			Color = Color3.new(1, 1, 1),
			CFrame = body.CFrame * CFrame.new(s * 0.2, s * 0.38, side * s * 0.25),
		})
		eye.Parent = model
		weldTo(body, eye)

		local pupil = part({
			Name = "Pupil",
			Shape = Enum.PartType.Ball,
			Size = Vector3.one * s * 0.18,
			Color = Color3.new(0.05, 0.05, 0.05),
			CFrame = eye.CFrame * CFrame.new(s * 0.13, 0, 0),
		})
		pupil.Parent = model
		weldTo(body, pupil)

		local foot = part({
			Name = "Foot",
			Size = Vector3.new(s * 0.45, s * 0.12, s * 0.3),
			Color = color:Lerp(Color3.new(0, 0, 0), 0.15),
			CFrame = body.CFrame * CFrame.new(-s * 0.15, -s * 0.38, side * s * 0.38),
		})
		foot.Parent = model
		weldTo(body, foot)
	end

	return model
end

-- Cube animal pet (reference style): rounded cube body, eyes, little ears,
-- and a name tag. Placeholder until the Blender models.
function Models.pet(name: string, color: Color3, size: number?): Model
	local s = size or 1.6
	local model = Instance.new("Model")
	model.Name = name
	local body = part({
		Name = "Body",
		Size = Vector3.one * s,
		Color = color,
		Material = Enum.Material.SmoothPlastic,
	})
	body.Parent = model
	model.PrimaryPart = body

	for _, side in { -1, 1 } do
		local eye = part({
			Name = "Eye",
			Shape = Enum.PartType.Ball,
			Size = Vector3.one * s * 0.28,
			Color = Color3.new(0.05, 0.05, 0.05),
			CFrame = body.CFrame * CFrame.new(side * s * 0.22, s * 0.08, -s * 0.48),
		})
		eye.Parent = model
		weldTo(body, eye)
		local shine = part({
			Name = "Shine",
			Shape = Enum.PartType.Ball,
			Size = Vector3.one * s * 0.1,
			Color = Color3.new(1, 1, 1),
			CFrame = eye.CFrame * CFrame.new(s * 0.04, s * 0.05, -s * 0.11),
		})
		shine.Parent = model
		weldTo(body, shine)
		local ear = part({
			Name = "Ear",
			Size = Vector3.new(s * 0.22, s * 0.3, s * 0.12),
			Color = color:Lerp(Color3.new(0, 0, 0), 0.2),
			CFrame = body.CFrame * CFrame.new(side * s * 0.3, s * 0.62, 0),
		})
		ear.Parent = model
		weldTo(body, ear)
	end

	local tag = Instance.new("BillboardGui")
	tag.Size = UDim2.fromOffset(120, 24)
	tag.StudsOffset = Vector3.new(0, s, 0)
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

	return model
end

-- Egg shape for stands and the hatch screen. Ball parts are always round,
-- so a sphere mesh stretches it into an egg.
function Models.egg(color: Color3, height: number?): Model
	local h = height or 4
	local model = Instance.new("Model")
	model.Name = "Egg"
	local shell = part({
		Name = "Shell",
		Size = Vector3.new(h * 0.78, h, h * 0.78),
		Color = color,
		Material = Enum.Material.SmoothPlastic,
	})
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = shell
	shell.Parent = model
	model.PrimaryPart = shell
	return model
end

return Models
