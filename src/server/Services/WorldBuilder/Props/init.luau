-- Scenery props along the throw lane and on the hub cliffs. Each kind uses
-- its Blender model (assets/models/Nature, imported into Assets.Nature) when
-- it's there, else the part-built fallback (Plants / Things).

local Parts = require(script.Parent.Parts)
local Plants = require(script.Plants)
local Things = require(script.Things)

local Props = {}

local BUILDERS: { [string]: (Vector3, Random, Instance) -> () } = {}
for kind, builder in Plants do
	BUILDERS[kind] = builder
end
for kind, builder in Things do
	BUILDERS[kind] = builder
end

local rgb = Color3.fromRGB

-- Colours for the models' tinted parts (autumn leaves, mushroom caps,
-- crystals, candy, petals); one is picked at random.
local AUTUMN = { rgb(240, 140, 40), rgb(225, 80, 45), rgb(250, 195, 60) }
local CAPS = { rgb(220, 60, 60), rgb(170, 90, 220), rgb(240, 150, 60) }
local GEMS = { rgb(170, 120, 255), rgb(110, 200, 255), rgb(255, 120, 220) }
local SWEETS = { rgb(255, 90, 160), rgb(120, 200, 255), rgb(255, 200, 60), rgb(160, 110, 255) }
local PETALS = { rgb(255, 90, 120), rgb(255, 220, 60), rgb(160, 110, 255), rgb(255, 255, 255) }

type ModelSpec = { names: { string }, width: NumberRange, colors: { Color3 }? }

-- kind → Blender model names (one picked at random), width range (studs),
-- and colours for the tinted parts
local MODELS: { [string]: ModelSpec } = {
	palm = { names = { "PalmTree", "PalmTreeBent" }, width = NumberRange.new(11, 15) },
	tree = { names = { "RoundTree", "RoundTreeTall" }, width = NumberRange.new(8, 11) },
	voxel = { names = { "VoxelTree", "VoxelTreeTall" }, width = NumberRange.new(8, 10) },
	bush = { names = { "Bush" }, width = NumberRange.new(4, 6) },
	autumn = { names = { "AutumnTree", "AutumnTreeTall" }, width = NumberRange.new(7, 10), colors = AUTUMN },
	pine = { names = { "SnowPine", "SnowPineTall" }, width = NumberRange.new(6.5, 8.5) },
	cactus = { names = { "Cactus", "CactusTall" }, width = NumberRange.new(4, 6) },
	mushroom = { names = { "Mushroom", "MushroomPair" }, width = NumberRange.new(3, 5.5), colors = CAPS },
	rock = { names = { "Boulder", "BoulderPair" }, width = NumberRange.new(3, 7) },
	ice = { names = { "IceSpikes" }, width = NumberRange.new(3.5, 5.5) },
	crystal = { names = { "CrystalCluster" }, width = NumberRange.new(4, 6.5), colors = GEMS },
	lollipop = { names = { "Lollipop" }, width = NumberRange.new(3.5, 4.5), colors = SWEETS },
	candy = { names = { "Gumdrops" }, width = NumberRange.new(4, 6) },
	pumpkin = { names = { "Pumpkin" }, width = NumberRange.new(2.5, 4) },
	reed = { names = { "Reeds" }, width = NumberRange.new(2, 3) },
	flower = { names = { "Flowers" }, width = NumberRange.new(2, 3), colors = PETALS },
}

-- Builds a prop of `kind` standing on the ground at `position`.
function Props.place(kind: string, position: Vector3, rng: Random, parent: Instance)
	local model = MODELS[kind]
	if model then
		local name = model.names[rng:NextInteger(1, #model.names)]
		local width = rng:NextNumber(model.width.Min, model.width.Max)
		local cframe = CFrame.new(position) * CFrame.Angles(0, rng:NextNumber(0, math.pi * 2), 0)
		local colors = model.colors
		local color = if colors then colors[rng:NextInteger(1, #colors)] else Color3.new(1, 1, 1)
		if Parts.prop(name, color, width, cframe, parent) then
			return
		end
	end
	local builder = BUILDERS[kind]
	if not builder then
		return
	end
	local built = Instance.new("Model")
	built.Name = kind
	builder(position, rng, built)
	built.Parent = parent
end

return Props
