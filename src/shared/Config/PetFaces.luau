--!strict
-- Pet face and pattern decals (assets/textures/pets/*.png, drawn by
-- tools/textures/pet_textures.py). Upload the PNGs to Roblox and paste each
-- image id below. 0 = not uploaded yet: that pet keeps its part-built face.

local PetFaces = {}

PetFaces.Images = {
	face_dog = 0,
	face_cat = 0,
	face_fox = 0,
	face_bunny = 0,
	face_bear = 0,
	face_panda = 0,
	face_mouse = 0,
	face_otter = 0,
	face_owl = 0,
	face_bat = 0,
	face_moth = 0,
	face_dragon = 0,
	face_unicorn = 0,
	face_unicat = 0,
	face_frog = 0,
	face_axolotl = 0,
	face_turtle = 0,
	face_slime = 0,
	face_lizard = 0,
	face_lamb = 0,
	face_mole = 0,
	face_ghost = 0,
	eye = 0, -- pupils on frog-style eye cubes
	spots = 0,
	stripes = 0,
	patch = 0,
	patches = 0,
} :: { [string]: number }

export type Pattern = { image: string, faces: { string }, tint: "dark" | "light" | "black" }

-- White pattern decals tinted from the pet colour, per look.
PetFaces.Patterns = {
	dog = { { image = "spots", faces = { "Top", "Left", "Right", "Back" }, tint = "dark" }, { image = "patch", faces = { "Front" }, tint = "dark" } },
	cat = { { image = "stripes", faces = { "Top", "Left", "Right", "Back" }, tint = "dark" } },
	panda = { { image = "patches", faces = { "Front" }, tint = "black" } },
	lizard = { { image = "spots", faces = { "Top", "Left", "Right" }, tint = "dark" } },
	dragon = { { image = "spots", faces = { "Left", "Right" }, tint = "light" } },
} :: { [string]: { Pattern } }

-- Content id for a texture, or nil if it hasn't been uploaded.
function PetFaces.content(image: string): string?
	local id = PetFaces.Images[image]
	if id and id ~= 0 then
		return `rbxassetid://{id}`
	end
	return nil
end

return PetFaces
