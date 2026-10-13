--!strict
-- Part-built rocks (the held item, thrown down the field and shown on
-- podiums). A few rotated blocks overlap into a chunky faceted rock; the
-- angles come from the rock id, so a rock looks the same everywhere. Glowing
-- rocks (ultimate) get neon flecks and a light. Blender rocks replace these
-- in stage 4 of the Rock Pivot.

local Rock = {}

local function part(props: { [string]: any }): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for key, value in props do
		(p :: any)[key] = value
	end
	return p
end

local function seedFor(id: string): number
	local seed = 7
	for i = 1, #id do
		seed = (seed * 31 + string.byte(id, i)) % 2147483647
	end
	return seed
end

-- A rock about `size` studs across, centred on its pivot.
function Rock.build(color: Color3, size: number, id: string?, glow: boolean?): Model
	local random = Random.new(seedFor(id or "rock"))
	local model = Instance.new("Model")
	model.Name = "Rock"
	local function angles(): CFrame
		return CFrame.Angles(random:NextNumber(-0.6, 0.6), random:NextNumber(0, math.pi), random:NextNumber(-0.6, 0.6))
	end

	local body = part({
		Name = "Body",
		Size = Vector3.new(size, size * 0.8, size * 0.9),
		Color = color,
		CFrame = angles(),
	})
	body.Parent = model
	model.PrimaryPart = body

	-- Lumps: smaller blocks pushed out from the centre, slightly lighter or
	-- darker, so the outline breaks up into facets.
	for k = 1, 4 do
		local s = size * random:NextNumber(0.55, 0.75)
		local dir = Vector3.new(random:NextNumber(-1, 1), random:NextNumber(-0.5, 0.8), random:NextNumber(-1, 1))
		if dir.Magnitude < 0.1 then
			dir = Vector3.yAxis
		end
		local shade = if k % 2 == 0 then color:Lerp(Color3.new(1, 1, 1), 0.12) else color:Lerp(Color3.new(0, 0, 0), 0.15)
		part({
			Name = `Lump{k}`,
			Size = Vector3.new(s, s * 0.8, s * 0.9),
			Color = shade,
			CFrame = CFrame.new(dir.Unit * size * 0.22) * angles(),
		}).Parent = model
	end

	if glow then
		for k = 1, 3 do
			local dir = Vector3.new(random:NextNumber(-1, 1), random:NextNumber(-1, 1), random:NextNumber(-1, 1))
			if dir.Magnitude < 0.1 then
				dir = Vector3.xAxis
			end
			part({
				Name = `Fleck{k}`,
				Size = Vector3.new(size * 0.18, size * 0.18, size * 0.18),
				Color = color:Lerp(Color3.new(1, 1, 1), 0.4),
				Material = Enum.Material.Neon,
				CFrame = CFrame.new(dir.Unit * size * 0.42) * angles(),
			}).Parent = model
		end
		local light = Instance.new("PointLight")
		light.Color = color
		light.Range = size * 4
		light.Brightness = 1.5
		light.Parent = body
	end

	-- Weld everything to the body so the rock holds together once unanchored
	-- (the held rock).
	for _, item in model:GetChildren() do
		if item ~= body and item:IsA("BasePart") then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = body
			weld.Part1 = item
			weld.Parent = item
		end
	end

	-- Keep the pivot unrotated so callers' PivotTo(CFrame.new(pos)) works.
	body.PivotOffset = body.CFrame:Inverse()
	return model
end

return Rock
