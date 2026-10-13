--!strict
-- How each part role of an imported model is coloured (from the colour the
-- game passes) and what surface it gets. Keep in step with ROLE_TINTS/FIXED
-- in tools/blender/build_rocks.py (and the NATURE roles in build_nature.py).

export type Look = { material: Enum.Material?, reflectance: number?, transparency: number? }

local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.new(0, 0, 0)

local function same(c: Color3): Color3
	return c
end
local function lighter(t: number): (Color3) -> Color3
	return function(c)
		return c:Lerp(WHITE, t)
	end
end
local function darker(t: number): (Color3) -> Color3
	return function(c)
		return c:Lerp(BLACK, t)
	end
end
local function fixed(r: number, g: number, b: number): (Color3) -> Color3
	local color = Color3.fromRGB(r, g, b)
	return function()
		return color
	end
end

-- How each role is coloured from the frog/pet/egg/rock colour. Roles not
-- listed (eyes, pupils, mouth) keep the colour they were imported with.
-- Keep the rock roles in step with ROLE_TINTS/FIXED in build_rocks.py.
local TINTS: { [string]: (Color3) -> Color3 } = {
	Body = same,
	Shell = same,
	Belly = function(c: Color3): Color3
		return c:Lerp(Color3.new(1, 1, 0.85), 0.6)
	end,
	Spots = lighter(0.55),
	Foot = darker(0.25),
	Ear = darker(0.3),
	-- Rocks
	Root = same,
	Shade = darker(0.35),
	Crust = darker(0.78),
	Crystal = lighter(0.3),
	-- Dark rocks' glow lightens more, or the Neon would stay dark.
	Glow = function(c: Color3): Color3
		local channels: any = c -- (luau-check has no Color3 type)
		local luminance = 0.299 * channels.R + 0.587 * channels.G + 0.114 * channels.B
		return c:Lerp(WHITE, if luminance < 0.3 then 0.55 else 0.15)
	end,
	Band = lighter(0.45),
	Cap = same,
	Jelly = same,
	Moss = same,
	Ore = same,
	Gem = same,
	Stone = fixed(125, 120, 115),
	Stem = fixed(240, 230, 210),
	Frosting = fixed(255, 235, 245),
	Sprinkles = fixed(255, 90, 170),
	Cherry = fixed(220, 20, 50),
	Stick = fixed(200, 160, 110),
	Shine = fixed(255, 255, 255),
	Gold = fixed(255, 195, 45),
	-- Props (build_props.py)
	Wood = fixed(176, 124, 78),
	Rubber = fixed(42, 42, 48),
	Steel = fixed(188, 194, 204),
	Iron = fixed(70, 72, 82),
	Chalk = fixed(246, 246, 240),
	-- Scenery (build_nature.py); Body/Shade/Gem take the prop's colour.
	Leaf = fixed(85, 180, 70),
	LeafLight = fixed(135, 212, 85),
	Bark = fixed(130, 88, 58),
	BarkDark = fixed(100, 68, 44),
	Coconut = fixed(100, 70, 45),
	Needle = fixed(60, 150, 95),
	Snow = fixed(245, 250, 255),
	Cactus = fixed(95, 170, 85),
	Petal = fixed(255, 120, 170),
	Dots = fixed(255, 252, 245),
	Gills = fixed(235, 215, 190),
	Ice = fixed(190, 230, 255),
	CandyA = fixed(255, 110, 150),
	CandyB = fixed(130, 220, 120),
	CandyC = fixed(255, 210, 80),
	Pumpkin = fixed(245, 140, 35),
	Vine = fixed(95, 120, 50),
	Pollen = fixed(255, 210, 60),
	Berry = fixed(220, 40, 60),
}

-- Surface looks per role (everything else is SmoothPlastic).
local LOOKS: { [string]: Look } = {
	Root = { transparency = 1 },
	Glow = { material = Enum.Material.Neon },
	Crystal = { reflectance = 0.2 },
	Gold = { material = Enum.Material.Metal, reflectance = 0.25 },
	Jelly = { transparency = 0.2, reflectance = 0.1 },
	Shine = { material = Enum.Material.Neon },
	Ore = { material = Enum.Material.Metal, reflectance = 0.15 },
	Gem = { material = Enum.Material.Glass, reflectance = 0.25, transparency = 0.1 },
	Wood = { material = Enum.Material.WoodPlanks },
	Steel = { material = Enum.Material.Metal, reflectance = 0.3 },
	Iron = { material = Enum.Material.Metal },
	Rubber = { material = Enum.Material.Rubber },
	Ice = { material = Enum.Material.Glass, reflectance = 0.2, transparency = 0.15 },
}

return { TINTS = TINTS, LOOKS = LOOKS }
