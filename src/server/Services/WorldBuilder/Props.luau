-- Simple low-poly bank props built from parts (placeholders until the
-- Blender models in Phase 6). Each builder places one prop at a ground point.

local Parts = require(script.Parent.Parts)

local Props = {}

local BROWN = Color3.fromRGB(120, 80, 50)
local LEAF = Color3.fromRGB(70, 170, 70)

local function ball(name: string, size: Vector3, cf: CFrame, color: Color3, parent: Instance, material: Enum.Material?)
	local part = Parts.block(name, size, cf, color, parent, material)
	part.Shape = Enum.PartType.Ball
	return part
end

local function cylinder(name: string, length: number, width: number, cf: CFrame, color: Color3, parent: Instance)
	-- Cylinders run along X; rotate so they stand up.
	local part = Parts.block(name, Vector3.new(length, width, width), cf * CFrame.Angles(0, 0, math.rad(90)), color, parent)
	part.Shape = Enum.PartType.Cylinder
	return part
end

local BUILDERS: { [string]: (Vector3, Random, Instance) -> () } = {
	tree = function(p, rng, parent)
		local h = rng:NextNumber(8, 13)
		cylinder("Trunk", h, 1.6, CFrame.new(p + Vector3.new(0, h / 2, 0)), BROWN, parent)
		local s = rng:NextNumber(7, 10)
		ball("Leaves", Vector3.one * s, CFrame.new(p + Vector3.new(0, h + s * 0.25, 0)), LEAF, parent, Enum.Material.Grass)
	end,
	palm = function(p, rng, parent)
		local h = rng:NextNumber(12, 16)
		cylinder("Trunk", h, 1.2, CFrame.new(p + Vector3.new(0, h / 2, 0)), Color3.fromRGB(170, 130, 80), parent)
		for i = 1, 5 do
			local angle = i / 5 * math.pi * 2
			local leaf = Parts.block(
				"Frond",
				Vector3.new(7, 0.4, 2),
				CFrame.new(p + Vector3.new(0, h, 0)) * CFrame.Angles(0, angle, math.rad(-20)) * CFrame.new(3.2, 0, 0),
				Color3.fromRGB(60, 180, 80),
				parent
			)
			leaf.CanCollide = false
		end
	end,
	willow = function(p, rng, parent)
		local h = rng:NextNumber(9, 12)
		cylinder("Trunk", h, 1.8, CFrame.new(p + Vector3.new(0, h / 2, 0)), BROWN, parent)
		ball("Canopy", Vector3.new(11, 9, 11), CFrame.new(p + Vector3.new(0, h, 0)), Color3.fromRGB(110, 180, 100), parent, Enum.Material.Grass)
		ball("Drape", Vector3.new(12, 6, 12), CFrame.new(p + Vector3.new(0, h - 3, 0)), Color3.fromRGB(95, 165, 90), parent, Enum.Material.Grass)
	end,
	rock = function(p, rng, parent)
		local s = rng:NextNumber(2.5, 6)
		ball("Rock", Vector3.new(s * 1.3, s, s), CFrame.new(p + Vector3.new(0, s * 0.3, 0)) * CFrame.Angles(0, rng:NextNumber(0, 6), 0), Color3.fromRGB(140, 140, 135), parent, Enum.Material.Slate)
	end,
	reed = function(p, rng, parent)
		for i = 1, 3 do
			local h = rng:NextNumber(3, 6)
			local offset = Vector3.new(rng:NextNumber(-1, 1), h / 2, rng:NextNumber(-1, 1))
			cylinder("Reed", h, 0.35, CFrame.new(p + offset), Color3.fromRGB(90, 160, 60), parent).CanCollide = false
		end
	end,
	flower = function(p, rng, parent)
		local colors = { Color3.fromRGB(255, 90, 120), Color3.fromRGB(255, 220, 60), Color3.fromRGB(160, 110, 255) }
		cylinder("Stem", 1.6, 0.25, CFrame.new(p + Vector3.new(0, 0.8, 0)), Color3.fromRGB(70, 150, 60), parent).CanCollide = false
		ball("Bloom", Vector3.one * 1.1, CFrame.new(p + Vector3.new(0, 1.8, 0)), colors[rng:NextInteger(1, #colors)], parent).CanCollide = false
	end,
	mushroom = function(p, rng, parent)
		local h = rng:NextNumber(2, 4)
		cylinder("Stem", h, 0.9, CFrame.new(p + Vector3.new(0, h / 2, 0)), Color3.fromRGB(240, 235, 220), parent)
		ball("Cap", Vector3.new(3.4, 1.8, 3.4), CFrame.new(p + Vector3.new(0, h, 0)), Color3.fromRGB(220, 60, 60), parent)
	end,
}

-- Builds a prop of `kind` standing on the ground at `position`.
function Props.place(kind: string, position: Vector3, rng: Random, parent: Instance)
	local builder = BUILDERS[kind]
	if not builder then
		return
	end
	local model = Instance.new("Model")
	model.Name = kind
	builder(position, rng, model)
	model.Parent = parent
end

return Props
