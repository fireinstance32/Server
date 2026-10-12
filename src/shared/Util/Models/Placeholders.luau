--!strict
-- Part-built egg used until the Blender egg is imported into
-- ReplicatedStorage.Assets (see Models/init). Frogs and pets: Models/Pet.

local Placeholders = {}

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


-- Egg shape for stands and the hatch screen. Ball parts are always round,
-- so a sphere mesh stretches it into an egg.
function Placeholders.egg(color: Color3, height: number?): Model
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

return Placeholders
