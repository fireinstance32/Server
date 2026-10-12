-- Every pet has a look, and every look is made of features that exist.
local function color(r, g, b)
	return setmetatable({ r, g, b }, { __index = { Lerp = function(self)
		return self
	end } })
end
Color3 = { fromRGB = color, new = color }
Vector3 = { new = function(x, y, z)
	return { X = x, Y = y, Z = z }
end }
CFrame = { Angles = function()
	return {}
end, new = function()
	return {}
end }
Enum = setmetatable({}, { __index = function(_, kind)
	return setmetatable({}, { __index = function(_, item)
		return `{kind}.{item}`
	end })
end })

local Pets = require("@shared/Config/Pets")
local PetLooks = require("@shared/Config/PetLooks")
local Features = require("@shared/Util/Models/Pet/Features")
local t = require("@test")

t.test("every pet has a known look", function()
	for _, pet in Pets.List do
		local look = PetLooks.ByPet[pet.id]
		assert(look, `{pet.id} has no look`)
		assert(PetLooks.Looks[look], `{pet.id} uses unknown look {look}`)
	end
end)

t.test("every look's features exist", function()
	for look, features in PetLooks.Looks do
		for _, name in features do
			assert(Features[name] or PetLooks.Flags[name], `{look} uses unknown feature {name}`)
		end
	end
end)

local PetFaces = require("@shared/Config/PetFaces")

t.test("every look has a face image slot and patterns use known images", function()
	for look in PetLooks.Looks do
		assert(PetFaces.Images["face_" .. look] ~= nil, `no face_{look} in PetFaces.Images`)
	end
	for look, patterns in PetFaces.Patterns do
		assert(PetLooks.Looks[look], `pattern for unknown look {look}`)
		for _, pattern in patterns do
			assert(PetFaces.Images[pattern.image] ~= nil, `unknown pattern image {pattern.image}`)
		end
	end
end)
