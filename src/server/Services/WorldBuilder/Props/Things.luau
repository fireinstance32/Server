-- Part-built non-plant props (fallbacks until the Blender nature models are
-- imported): rocks, ice, crystals, candy and pumpkins.

local Shapes = require(script.Parent.Shapes)

local ball, cylinder, block, disc, spike, vary = Shapes.ball, Shapes.cylinder, Shapes.block, Shapes.disc, Shapes.spike, Shapes.vary

local rgb = Color3.fromRGB

local Things: { [string]: (Vector3, Random, Instance) -> () } = {}

function Things.rock(p, rng, parent)
	local s = rng:NextNumber(2.5, 6)
	local grey = vary(rgb(150, 145, 140), rng, 0.1)
	block("Rock", Vector3.new(s * 1.3, s * 0.8, s), CFrame.new(p + Vector3.new(0, s * 0.3, 0)) * CFrame.Angles(rng:NextNumber(-0.2, 0.2), rng:NextNumber(0, 6), rng:NextNumber(-0.2, 0.2)), grey, parent)
	if rng:NextNumber() < 0.6 then
		block("Rock", Vector3.one * s * 0.55, CFrame.new(p + Vector3.new(s * 0.7, s * 0.2, s * 0.3)) * CFrame.Angles(0.3, rng:NextNumber(0, 6), 0.2), grey:Lerp(Color3.new(1, 1, 1), 0.1), parent)
	end
end

function Things.ice(p, rng, parent)
	for _ = 1, rng:NextInteger(2, 4) do
		local h = rng:NextNumber(3, 8)
		local base = CFrame.new(p + Vector3.new(rng:NextNumber(-1.5, 1.5), 0, rng:NextNumber(-1.5, 1.5)))
			* CFrame.Angles(rng:NextNumber(-0.25, 0.25), 0, rng:NextNumber(-0.25, 0.25))
		spike("Ice", base, rng:NextNumber(1.2, 2), h, vary(rgb(185, 225, 255), rng, 0.08), parent, Enum.Material.Ice)
	end
end

function Things.crystal(p, rng, parent)
	local palette = { rgb(170, 120, 255), rgb(110, 200, 255), rgb(255, 120, 220) }
	local color = palette[rng:NextInteger(1, #palette)]
	for i = 1, rng:NextInteger(3, 5) do
		local h = if i == 1 then rng:NextNumber(6, 10) else rng:NextNumber(2.5, 6)
		local base = CFrame.new(p + Vector3.new(rng:NextNumber(-1.6, 1.6), -0.3, rng:NextNumber(-1.6, 1.6)))
			* CFrame.Angles(rng:NextNumber(-0.4, 0.4), 0, rng:NextNumber(-0.4, 0.4))
		spike("Crystal", base, rng:NextNumber(1, 1.8), h, vary(color, rng, 0.1), parent, Enum.Material.Glass)
	end
	block("Base", Vector3.new(3.5, 1, 3.5), CFrame.new(p + Vector3.new(0, 0.3, 0)) * CFrame.Angles(0, rng:NextNumber(0, 6), 0), rgb(90, 80, 110), parent)
end

function Things.lollipop(p, rng, parent)
	local h = rng:NextNumber(5, 9)
	cylinder("Stick", h, 0.5, CFrame.new(p + Vector3.new(0, h / 2, 0)), rgb(250, 248, 240), parent)
	local palette = { rgb(255, 90, 160), rgb(120, 200, 255), rgb(255, 200, 60), rgb(160, 110, 255) }
	local color = palette[rng:NextInteger(1, #palette)]
	local face = CFrame.new(p + Vector3.new(0, h + 1.6, 0)) * CFrame.Angles(0, rng:NextNumber(0, 6), 0) * CFrame.Angles(math.rad(90), 0, 0)
	local d = rng:NextNumber(3.5, 4.5)
	disc("Candy", d, 0.8, face, color, parent)
	disc("Swirl", d * 0.66, 0.9, face, rgb(255, 255, 255), parent)
	disc("Swirl", d * 0.36, 1, face, color, parent)
end

-- Gumdrops: a cluster of half-buried sugar domes.
function Things.candy(p, rng, parent)
	local palette = { rgb(255, 110, 150), rgb(130, 220, 120), rgb(255, 210, 80), rgb(150, 140, 255) }
	for _ = 1, rng:NextInteger(2, 4) do
		local s = rng:NextNumber(1.8, 3.4)
		local at = p + Vector3.new(rng:NextNumber(-2, 2), 0, rng:NextNumber(-2, 2))
		ball("Gumdrop", Vector3.new(s, s * 1.1, s), CFrame.new(at + Vector3.new(0, s * 0.2, 0)), palette[rng:NextInteger(1, #palette)], parent)
	end
end

function Things.pumpkin(p, rng, parent)
	local s = rng:NextNumber(2.2, 3.6)
	local orange = vary(rgb(245, 140, 35), rng, 0.08)
	for i = 0, 3 do
		ball("Pumpkin", Vector3.new(s * 0.75, s * 0.8, s * 1.15), CFrame.new(p + Vector3.new(0, s * 0.4, 0)) * CFrame.Angles(0, i * math.pi / 4, 0), orange, parent)
	end
	cylinder("Stem", s * 0.35, s * 0.18, CFrame.new(p + Vector3.new(0, s * 0.85, 0)), rgb(90, 120, 50), parent)
end

return Things
