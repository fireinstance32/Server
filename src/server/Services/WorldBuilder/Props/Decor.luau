-- Part-built gym decor (fallbacks until the Blender decor models are
-- imported, assets/models/Decor): grass, lily pads, lotus, candles, lanterns,
-- bamboo, a cherry tree and a torii gate. Gym-sized.

local Shapes = require(script.Parent.Shapes)

local ball, cylinder, block, disc, vary = Shapes.ball, Shapes.cylinder, Shapes.block, Shapes.disc, Shapes.vary

local rgb = Color3.fromRGB
local up = Vector3.yAxis

local FLAME = rgb(255, 190, 90)
local LEAF = rgb(70, 170, 70)

local Decor: { [string]: (Vector3, Random, Instance) -> () } = {}

function Decor.grass(p, rng, parent)
	local green = vary(rgb(90, 190, 70), rng, 0.1)
	for i = 1, 3 do
		local h = rng:NextNumber(0.8, 1.4)
		block("Blade", Vector3.new(0.25, h, 0.25), CFrame.new(p + up * h / 2) * CFrame.Angles(rng:NextNumber(-0.3, 0.3), i * 2, rng:NextNumber(-0.3, 0.3)), green, parent)
	end
end

function Decor.lilypad(p, rng, parent)
	disc("Pad", rng:NextNumber(1.8, 2.4), 0.1, CFrame.new(p + up * 0.05), vary(rgb(60, 170, 70), rng, 0.08), parent)
end

function Decor.lotus(p, rng, parent)
	disc("Pad", 2, 0.1, CFrame.new(p + up * 0.05), rgb(60, 170, 70), parent)
	ball("Flower", Vector3.new(1, 0.7, 1), CFrame.new(p + up * 0.4), rgb(255, 150, 200), parent)
end

function Decor.candle(p, rng, parent)
	local h = rng:NextNumber(0.8, 1.4)
	cylinder("Wax", h, 0.45, CFrame.new(p + up * h / 2), rgb(245, 235, 215), parent)
	ball("Flame", Vector3.new(0.3, 0.45, 0.3), CFrame.new(p + up * (h + 0.25)), FLAME, parent, Enum.Material.Neon)
end

function Decor.jackolantern(p, rng, parent)
	ball("Pumpkin", Vector3.new(1.8, 1.4, 1.8), CFrame.new(p + up * 0.7), rgb(240, 130, 30), parent)
	block("Glow", Vector3.new(0.9, 0.35, 0.2), CFrame.new(p + Vector3.new(0, 0.7, -0.85)), FLAME, parent, Enum.Material.Neon)
end

function Decor.lantern(p, rng, parent)
	cylinder("Post", 2.4, 0.2, CFrame.new(p + up * 1.2), rgb(70, 50, 40), parent)
	block("Lantern", Vector3.new(0.9, 1.1, 0.9), CFrame.new(p + up * 2.8), rgb(230, 60, 50), parent, Enum.Material.Neon)
end

function Decor.stonelantern(p, rng, parent)
	local stone = rgb(165, 165, 160)
	block("Base", Vector3.new(1.2, 0.4, 1.2), CFrame.new(p + up * 0.2), stone, parent)
	block("Post", Vector3.new(0.5, 1.2, 0.5), CFrame.new(p + up * 1), stone, parent)
	block("Light", Vector3.new(0.9, 0.7, 0.9), CFrame.new(p + up * 1.95), FLAME, parent, Enum.Material.Neon)
	block("Roof", Vector3.new(1.6, 0.35, 1.6), CFrame.new(p + up * 2.45), stone:Lerp(Color3.new(0, 0, 0), 0.15), parent)
end

function Decor.bamboo(p, rng, parent)
	for i = 1, 3 do
		local h = rng:NextNumber(4, 6.5)
		local at = p + Vector3.new(rng:NextNumber(-0.6, 0.6), 0, rng:NextNumber(-0.6, 0.6))
		cylinder("Cane", h, 0.35, CFrame.new(at + up * h / 2), vary(rgb(120, 190, 80), rng, 0.1), parent)
		block("Leaf", Vector3.new(1.2, 0.08, 0.35), CFrame.new(at + up * h * 0.8) * CFrame.Angles(0, i, 0.3), LEAF, parent)
	end
end

function Decor.cherry(p, rng, parent)
	local h = rng:NextNumber(4, 5)
	block("Trunk", Vector3.new(1, h, 1), CFrame.new(p + up * h / 2), rgb(110, 70, 60), parent)
	local pink = rgb(255, 170, 210)
	block("Blossom", Vector3.new(5, 3, 5), CFrame.new(p + up * (h + 1)), pink, parent)
	block("Blossom", Vector3.new(3.2, 2, 3.2), CFrame.new(p + up * (h + 3)), pink:Lerp(Color3.new(1, 1, 1), 0.3), parent)
	for i = 1, 3 do
		local a = rng:NextNumber(0, math.pi * 2)
		block("Blossom", Vector3.one * 1.6, CFrame.new(p + Vector3.new(math.cos(a) * 2.6, h + rng:NextNumber(0, 1.5), math.sin(a) * 2.6)), pink:Lerp(Color3.new(0, 0, 0), 0.06), parent)
	end
end

-- Spans 12 studs along X.
function Decor.torii(p, rng, parent)
	local red, black = rgb(220, 50, 40), rgb(40, 35, 40)
	for _, s in { -1, 1 } do
		cylinder("Pillar", 8, 0.9, CFrame.new(p + Vector3.new(s * 4.8, 4, 0)), red, parent)
		block("Foot", Vector3.new(1.3, 0.6, 1.3), CFrame.new(p + Vector3.new(s * 4.8, 0.3, 0)), black, parent)
	end
	block("Tie", Vector3.new(11, 0.6, 0.6), CFrame.new(p + up * 6.5), red, parent)
	block("Lintel", Vector3.new(13, 0.8, 1.2), CFrame.new(p + up * 8.2), red, parent)
	block("Cap", Vector3.new(14, 0.4, 1.4), CFrame.new(p + up * 8.8), black, parent)
end

return Decor
