--!strict
-- How part-built pets look (Shared/Util/Models/Pet): each pet's animal, and
-- the features (Models/Pet/Features) each animal is made of. Pets not
-- listed use "bear".

local PetLooks = {}

PetLooks.Looks = {
	dog = { "floppyEars", "snout", "collar", "tail" },
	cat = { "pointyEars", "whiskers", "collar", "tail" },
	fox = { "bigPointyEars", "whiteSnout", "bushyTail" },
	bunny = { "longEars", "teeth", "puffTail" },
	bear = { "roundEars", "snout" },
	panda = { "darkRoundEars", "eyePatches", "snout" },
	mouse = { "bigRoundEars", "pinkNose", "whiskers", "thinTail" },
	otter = { "roundEars", "whiteSnout", "whiskers", "flatTail" },
	owl = { "tufts", "beak", "wings" },
	bat = { "batEars", "batWings", "fangs" },
	moth = { "antennae", "mothWings" },
	dragon = { "horns", "snout", "wings", "spikes", "tail" },
	unicorn = { "horn", "mane", "snout", "tail" },
	frog = { "noEyes", "topEyes", "wideMouth" },
	axolotl = { "gills", "wideMouth" },
	turtle = { "shell", "wideMouth" },
	slime = { "slime", "noFeet" },
	lizard = { "spikes", "wideMouth", "tail" },
	lamb = { "wool", "darkFace" },
	mole = { "pinkNose", "tinyEyes", "claws" },
	ghost = { "ghost", "noFeet" },
}

-- Face features drawn by the face decal instead, once it is uploaded
-- (Config/PetFaces). Until then they are built from parts.
PetLooks.FaceFeatures = {
	snout = true,
	whiteSnout = true,
	pinkNose = true,
	beak = true,
	wideMouth = true,
	teeth = true,
	fangs = true,
	whiskers = true,
	eyePatches = true,
	darkFace = true,
}

-- Frogs are built like pets with the "frog" look, plus these extras.
PetLooks.FrogExtras = {
	Golden = { "shiny" },
	Ninja = { "headband" },
	Royal = { "crown" },
	ShootingStar = { "shiny" },
	Phoenix = { "wings" },
	Mushroom = { "mushroomCap" },
	ToadKing = { "crown" },
	Lollipop = { "shiny" },
	CandyKing = { "crown" },
	Astro = { "helmet" },
	Nebula = { "shiny" },
	GalaxyKing = { "crown" },
	Obsidian = { "shiny" },
	VolcanoKing = { "crown" },
} :: { [string]: { string } }

-- Feature names that are switches for the base parts, not built parts.
PetLooks.Flags = { noEyes = true, noFeet = true, tinyEyes = true }

PetLooks.ByPet = {
	-- Lily Valley
	PebblePup = "dog",
	CloverBun = "bunny",
	BrookOtter = "otter",
	MossTurtle = "turtle",
	LilyFrogling = "frog",
	ReedFox = "fox",
	PondPanda = "panda",
	DragonflyKitty = "cat",
	FireflyBear = "bear",
	WillowOwl = "owl",
	CrystalAxolotl = "axolotl",
	GoldenToad = "frog",
	FortuneNeko = "cat",
	RainbowFrog = "frog",
	GalaxyCat = "cat",
	PrismDragon = "dragon",
	-- Mushroom Swamp
	SporeSlime = "slime",
	BogBat = "bat",
	CapToad = "frog",
	GlowMoth = "moth",
	WitchCat = "cat",
	SwampDragon = "dragon",
	-- Candy Falls
	GummyBear = "bear",
	CottonLamb = "lamb",
	LollipopPup = "dog",
	ChocoBunny = "bunny",
	CandyUnicorn = "unicorn",
	SugarDragon = "dragon",
	-- Cosmic Cove
	MoonMouse = "mouse",
	StarPuppy = "dog",
	AlienCat = "cat",
	CometFox = "fox",
	AstroOwl = "owl",
	NebulaDragon = "dragon",
	-- Lava Springs
	EmberPup = "dog",
	MagmaMole = "mole",
	LavaLizard = "lizard",
	FireFox = "fox",
	PhoenixOwl = "owl",
	InfernoDragon = "dragon",
	-- Halloween
	CandyBat = "bat",
	PumpkinCat = "cat",
	GhostFrog = "ghost",
	SpookyDragon = "dragon",
} :: { [string]: string }

return PetLooks
