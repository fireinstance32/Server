-- Cube pets built from parts: a cube body and feet, the 3D details of the
-- pet's look (Config/PetLooks: ears, tails, wings, collars...), a face decal
-- and tinted pattern decals (Config/PetFaces). Until a face image is
-- uploaded, the face is built from parts instead. Faces -Z. Legendary and
-- Rainbow pets sparkle.

local Features = require(script.Features)
local Builder = require(script.Builder)
local PetLooks = require(script.Parent.Parent.Parent.Config.PetLooks)
local PetFaces = require(script.Parent.Parent.Parent.Config.PetFaces)

local Pet = {}

local TINTS = {
	dark = function(c: Color3)
		return c:Lerp(Color3.new(0, 0, 0), 0.35)
	end,
	light = function(c: Color3)
		return c:Lerp(Color3.new(1, 1, 1), 0.45)
	end,
	black = function()
		return Color3.fromRGB(25, 25, 30)
	end,
}

local function addPatterns(b: Builder.Builder, look: string)
	for _, pattern in PetFaces.Patterns[look] or {} do
		local content = PetFaces.content(pattern.image)
		if content then
			for _, face in pattern.faces do
				local decal = b:decal(b.body, face, content, pattern.image)
				decal.Color3 = TINTS[pattern.tint](b.color)
				decal.ZIndex = 1
			end
		end
	end
end

function Pet.build(color: Color3, size: number, look: string?, rarity: string?): Model
	local b = Builder.new(color, size)
	local lookName = if look and PetLooks.Looks[look] then look else "bear"
	local features = PetLooks.Looks[lookName]
	local flags: { [string]: boolean } = {}
	for _, name in features do
		flags[name] = true
	end

	local faceImage = PetFaces.content("face_" .. lookName)
	if faceImage then
		b:decal(b.body, "Front", faceImage, "face_" .. lookName).ZIndex = 2
	elseif not flags.noEyes then
		Features.eyes(b, if flags.tinyEyes then 0.55 else 1)
	end
	if not faceImage then
		Features.blush(b)
	end
	if not flags.noFeet then
		Features.feet(b)
	end
	for _, name in features do
		local feature = Features[name]
		if feature and not (faceImage and PetLooks.FaceFeatures[name]) then
			feature(b)
		end
	end
	addPatterns(b, lookName)
	if rarity == "Legendary" or rarity == "Rainbow" then
		Features.sparkle(b, rarity == "Rainbow")
	end
	return b.model
end

return Pet
