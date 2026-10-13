-- Each gym's look (reference: themed ground and decor round every pool):
-- its two ground colours and which decor kinds (Props) go where (Decor).
--
--   guard    a pair either side of the stand pad
--   corner   one in each back corner (the big piece: trees, crystals)
--   gate     a gate across the pool (Golden)
--   shore    a few along the pool's edge
--   water    a few floating on the pool
--   scatter  a few on the rest of the ground

local Themes = {}

local rgb = Color3.fromRGB

export type Theme = {
	ground: { Color3 },
	guard: string?,
	corner: string?,
	gate: string?,
	shore: { string },
	water: { string },
	scatter: { string },
}

local LIST: { [string]: Theme } = {
	Starter = {
		ground = { rgb(84, 176, 60), rgb(116, 204, 82) },
		guard = "flower",
		corner = "bush",
		shore = { "reed", "reed", "flower" },
		water = { "lilypad" },
		scatter = { "grass", "flower" },
	},
	Lotus = {
		ground = { rgb(62, 140, 108), rgb(88, 168, 130) },
		guard = "lantern",
		corner = "bamboo",
		shore = { "reed", "grass" },
		water = { "lotus", "lilypad" },
		scatter = { "grass" },
	},
	Crystal = {
		ground = { rgb(70, 58, 102), rgb(94, 80, 134) },
		guard = "candle",
		corner = "crystal",
		shore = { "candle", "jackolantern" },
		water = {},
		scatter = { "candle", "crystal" },
	},
	Royal = {
		ground = { rgb(148, 150, 172), rgb(176, 178, 198) },
		guard = "stonelantern",
		corner = "voxel",
		shore = { "flower", "grass" },
		water = { "lilypad" },
		scatter = { "flower" },
	},
	Golden = {
		ground = { rgb(228, 196, 124), rgb(244, 220, 158) },
		guard = "lantern",
		corner = "stonelantern",
		gate = "torii",
		shore = { "grass", "reed" },
		water = { "lotus" },
		scatter = { "grass" },
	},
	Rainbow = {
		ground = { rgb(242, 164, 202), rgb(252, 198, 224) },
		guard = "flower",
		corner = "cherry",
		shore = { "flower", "grass" },
		water = { "lilypad", "lotus" },
		scatter = { "flower" },
	},
	Cosmic = {
		ground = { rgb(36, 38, 70), rgb(54, 56, 98) },
		guard = "crystal",
		corner = "crystal",
		shore = { "mushroom", "crystal" },
		water = {},
		scatter = { "mushroom" },
	},
}

-- The theme of gym `id` (the Starter look for an unknown one).
function Themes.of(id: string): Theme
	return LIST[id] or LIST.Starter
end

return Themes
