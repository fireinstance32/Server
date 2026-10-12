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

-- Simple floating pet: a coloured ball with a name tag.
function Models.pet(name: string, color: Color3): Model
	local model = Instance.new("Model")
	model.Name = name
	local body = part({
		Name = "Body",
		Shape = Enum.PartType.Ball,
		Size = Vector3.one * 1.4,
		Color = color,
		Material = Enum.Material.SmoothPlastic,
	})
	body.Parent = model
	model.PrimaryPart = body

	local tag = Instance.new("BillboardGui")
	tag.Size = UDim2.fromOffset(120, 24)
	tag.StudsOffset = Vector3.new(0, 1.4, 0)
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

return Models
