--!strict
-- Which Blender model each rock (Config/Frogs) uses. Shapes are the
-- templates built by tools/blender/build_rocks.py and imported into
-- ReplicatedStorage.Assets (see docs/Tech/Art Pipeline.md); the game colours
-- them from the rock's colour. Rocks not listed use "Rock". Crowned rocks
-- also wear the "Crown" model.

local RockLooks = {}

-- Every shape build_rocks.py makes (the unit test checks against this).
RockLooks.Shapes = {
	"Rock",
	"RockPebble",
	"RockRiver",
	"RockMossy",
	"RockBoulder",
	"RockNugget",
	"RockLava",
	"RockMeteor",
	"RockMoon",
	"RockCandy",
	"RockGummy",
	"RockFrosted",
	"RockMushroom",
	"RockToxic",
	"RockRune",
	"RockRoyal",
	"RockComet",
	"RockGalaxy",
	"RockPhoenix",
}

RockLooks.ByRock = {
	-- Lily Valley
	Baby = "RockPebble",
	Leaf = "RockMossy",
	Mud = "Rock",
	Pond = "RockRiver",
	Tree = "Rock",
	Dart = "RockToxic",
	Bull = "RockBoulder",
	Golden = "RockNugget",
	Ninja = "RockRune",
	Royal = "RockRoyal",
	ShootingStar = "RockMeteor",
	Phoenix = "RockPhoenix",
	-- Swamp
	Swamp = "RockMossy",
	Mushroom = "RockMushroom",
	Bog = "RockBoulder",
	ToadKing = "RockToxic",
	-- Candy
	Gummy = "RockGummy",
	Lollipop = "RockCandy",
	Cupcake = "RockFrosted",
	CandyKing = "RockCandy",
	-- Space
	Astro = "RockMoon",
	Comet = "RockComet",
	Nebula = "RockGalaxy",
	GalaxyKing = "RockGalaxy",
	-- Lava
	Ember = "RockLava",
	Magma = "RockLava",
	Obsidian = "RockRune",
	VolcanoKing = "RockLava",
} :: { [string]: string }

RockLooks.Crowned = {
	ToadKing = true,
	CandyKing = true,
	GalaxyKing = true,
	VolcanoKing = true,
} :: { [string]: boolean }

function RockLooks.shapeFor(rockId: string?): string
	return rockId and RockLooks.ByRock[rockId] or "Rock"
end

return RockLooks
