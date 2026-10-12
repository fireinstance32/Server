-- Adds parts to a pet relative to its body (units = body size), welded to it.

export type Builder = {
	model: Model,
	body: Part,
	s: number,
	color: Color3,
	dark: Color3,
	light: Color3,
	add: (self: Builder, name: string, size: Vector3, at: CFrame, color: Color3, props: { [string]: any }?) -> Part,
	decal: (self: Builder, part: BasePart, face: string, content: string, name: string) -> Decal,
}

local Builder = {}

local PINK = Color3.fromRGB(255, 150, 170)
Builder.Pink = PINK

local function newPart(props: { [string]: any }): Part
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

-- `size` and the position in `at` are in body units; `at` may also rotate.
local function add(self: Builder, name: string, size: Vector3, at: CFrame, color: Color3, props: { [string]: any }?): Part
	local s = self.s
	local p = newPart({
		Name = name,
		Size = size * s,
		Color = color,
		CFrame = self.body.CFrame * (CFrame.new(at.Position * s) * at.Rotation),
	})
	for key, value in props or {} do
		(p :: any)[key] = value
	end
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = self.body
	weld.Part1 = p
	weld.Parent = p
	p.Parent = self.model
	return p
end

-- A texture on one face of `part` ("Front" = the pet's face side).
local function decal(_self: Builder, part: BasePart, face: string, content: string, name: string): Decal
	local d = Instance.new("Decal")
	d.Name = name
	d.Face = (Enum.NormalId :: any)[face]
	d.Texture = content
	d.Parent = part
	return d
end

function Builder.new(color: Color3, size: number): Builder
	local model = Instance.new("Model")
	model.Name = "Pet"
	local body = newPart({ Name = "Body", Size = Vector3.one * size, Color = color })
	body.Parent = model
	model.PrimaryPart = body
	return {
		model = model,
		body = body,
		s = size,
		color = color,
		dark = color:Lerp(Color3.new(0, 0, 0), 0.3),
		light = color:Lerp(Color3.new(1, 1, 1), 0.5),
		add = add,
		decal = decal,
	}
end

return Builder
