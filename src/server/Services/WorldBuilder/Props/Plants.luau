-- Part-built plants (fallbacks until the Blender nature models are
-- imported): each builder places one plant standing on ground point `p`.

local Shapes = require(script.Parent.Shapes)

local ball, cylinder, block, vary = Shapes.ball, Shapes.cylinder, Shapes.block, Shapes.vary

local BROWN = Color3.fromRGB(120, 80, 50)
local LEAF = Color3.fromRGB(80, 185, 70)
local rgb = Color3.fromRGB

export type Builder = (Vector3, Random, Instance) -> ()

local Plants: { [string]: Builder } = {}

function Plants.tree(p, rng, parent)
	local h = rng:NextNumber(8, 13)
	cylinder("Trunk", h, 1.6, CFrame.new(p + Vector3.new(0, h / 2, 0)), BROWN, parent)
	local s = rng:NextNumber(7, 10)
	ball("Leaves", Vector3.one * s, CFrame.new(p + Vector3.new(0, h + s * 0.25, 0)), vary(LEAF, rng), parent)
	ball("Leaves", Vector3.one * s * 0.7, CFrame.new(p + Vector3.new(s * 0.35, h - 0.5, s * 0.1)), vary(LEAF, rng), parent)
end

-- Blocky "voxel" tree (reference hub): square trunk and stacked leaf cubes.
function Plants.voxel(p, rng, parent)
	local h = rng:NextNumber(6, 10)
	block("Trunk", Vector3.new(2, h, 2), CFrame.new(p + Vector3.new(0, h / 2, 0)), rgb(130, 85, 55), parent)
	local s = rng:NextNumber(7, 9)
	local leaf = vary(rgb(95, 200, 70), rng, 0.08)
	block("Leaves", Vector3.new(s, s * 0.8, s), CFrame.new(p + Vector3.new(0, h + s * 0.3, 0)), leaf, parent)
	block("Leaves", Vector3.new(s * 0.7, s * 0.55, s * 0.7), CFrame.new(p + Vector3.new(0, h + s * 0.95, 0)), leaf:Lerp(Color3.new(1, 1, 1), 0.12), parent)
	for i = 1, rng:NextInteger(1, 3) do
		local a = rng:NextNumber(0, math.pi * 2)
		local off = Vector3.new(math.cos(a) * s * 0.5, h + rng:NextNumber(-0.5, 1.5), math.sin(a) * s * 0.5)
		block("Leaves", Vector3.one * s * 0.45, CFrame.new(p + off), leaf:Lerp(Color3.new(0, 0, 0), 0.1), parent)
	end
end

function Plants.bush(p, rng, parent)
	local s = rng:NextNumber(3, 5)
	local leaf = vary(LEAF, rng, 0.1)
	block("Bush", Vector3.new(s, s * 0.75, s), CFrame.new(p + Vector3.new(0, s * 0.37, 0)) * CFrame.Angles(0, rng:NextNumber(0, 6), 0), leaf, parent)
	block("Bush", Vector3.new(s * 0.65, s * 0.6, s * 0.65), CFrame.new(p + Vector3.new(s * 0.45, s * 0.3, 0)), leaf:Lerp(Color3.new(1, 1, 1), 0.1), parent)
end

function Plants.palm(p, rng, parent)
	local h = rng:NextNumber(12, 16)
	local lean = rng:NextNumber(-0.25, 0.25)
	local top = p + Vector3.new(lean * h, h, 0)
	-- Ringed trunk: alternating segments.
	local segments = 6
	for i = 0, segments - 1 do
		local t = (i + 0.5) / segments
		local at = p:Lerp(top, t)
		local color = if i % 2 == 0 then rgb(175, 130, 80) else rgb(150, 105, 65)
		cylinder("Trunk", h / segments + 0.05, 1.3 - t * 0.35, CFrame.lookAt(at, at + (top - p)) * CFrame.Angles(math.rad(90), 0, 0), color, parent)
	end
	for i = 1, 7 do
		local angle = i / 7 * math.pi * 2 + rng:NextNumber(-0.2, 0.2)
		local leaf = block(
			"Frond",
			Vector3.new(7.5, 0.35, 2.2),
			CFrame.new(top) * CFrame.Angles(0, angle, math.rad(-28)) * CFrame.new(3.4, 0, 0),
			vary(rgb(70, 190, 80), rng, 0.1),
			parent
		)
		leaf.CanCollide = false
	end
	ball("Coconut", Vector3.one * 1, CFrame.new(top + Vector3.new(0.5, -0.6, 0.3)), rgb(110, 75, 45), parent)
	ball("Coconut", Vector3.one * 1, CFrame.new(top + Vector3.new(-0.4, -0.7, -0.3)), rgb(110, 75, 45), parent)
end

function Plants.willow(p, rng, parent)
	local h = rng:NextNumber(9, 12)
	cylinder("Trunk", h, 1.8, CFrame.new(p + Vector3.new(0, h / 2, 0)), BROWN, parent)
	ball("Canopy", Vector3.new(11, 9, 11), CFrame.new(p + Vector3.new(0, h, 0)), rgb(110, 180, 100), parent)
	ball("Drape", Vector3.new(12, 6, 12), CFrame.new(p + Vector3.new(0, h - 3, 0)), rgb(95, 165, 90), parent)
end

-- Low-poly autumn tree: chunky leaf blocks in orange/red/yellow.
function Plants.autumn(p, rng, parent)
	local h = rng:NextNumber(7, 11)
	cylinder("Trunk", h, 1.4, CFrame.new(p + Vector3.new(0, h / 2, 0)), rgb(115, 75, 50), parent)
	local palette = { rgb(240, 140, 40), rgb(225, 80, 45), rgb(250, 195, 60) }
	local leaf = palette[rng:NextInteger(1, #palette)]
	local s = rng:NextNumber(6, 8)
	ball("Leaves", Vector3.new(s, s * 0.85, s), CFrame.new(p + Vector3.new(0, h + s * 0.2, 0)), leaf, parent)
	ball("Leaves", Vector3.new(s, s, s) * 0.6, CFrame.new(p + Vector3.new(s * 0.4, h - 0.3, -s * 0.2)), leaf:Lerp(rgb(255, 230, 120), 0.25), parent)
end

-- Snowy voxel pine: shrinking square tiers, each capped with snow.
function Plants.pine(p, rng, parent)
	local trunk = 2.5
	block("Trunk", Vector3.new(1.4, trunk, 1.4), CFrame.new(p + Vector3.new(0, trunk / 2, 0)), rgb(110, 75, 50), parent)
	local y = trunk
	local w = rng:NextNumber(6.5, 8)
	local green = vary(rgb(45, 120, 85), rng, 0.08)
	local turn = CFrame.Angles(0, rng:NextNumber(0, 6), 0)
	for _ = 1, 4 do
		local h = w * 0.42
		block("Needles", Vector3.new(w, h, w), CFrame.new(p + Vector3.new(0, y + h / 2, 0)) * turn, green, parent)
		block("Snow", Vector3.new(w * 0.92, 0.5, w * 0.92), CFrame.new(p + Vector3.new(0, y + h + 0.2, 0)) * turn, rgb(245, 250, 255), parent)
		y += h * 0.8
		w *= 0.68
	end
end

function Plants.cactus(p, rng, parent)
	local h = rng:NextNumber(6, 11)
	local green = vary(rgb(95, 170, 85), rng, 0.08)
	cylinder("Body", h, 2.2, CFrame.new(p + Vector3.new(0, h / 2, 0)), green, parent)
	ball("Top", Vector3.one * 2.2, CFrame.new(p + Vector3.new(0, h, 0)), green, parent)
	for _, side in { -1, 1 } do
		if rng:NextNumber() < 0.75 then
			local y = h * rng:NextNumber(0.35, 0.6)
			local reach = rng:NextNumber(1.8, 2.6)
			local up = rng:NextNumber(2, 3.5)
			block("Arm", Vector3.new(reach, 1.4, 1.4), CFrame.new(p + Vector3.new(side * reach / 2, y, 0)), green, parent)
			cylinder("Arm", up, 1.5, CFrame.new(p + Vector3.new(side * reach, y + up / 2, 0)), green, parent)
			ball("ArmTop", Vector3.one * 1.5, CFrame.new(p + Vector3.new(side * reach, y + up, 0)), green, parent)
		end
	end
	if rng:NextNumber() < 0.4 then
		ball("Flower", Vector3.one * 0.9, CFrame.new(p + Vector3.new(0, h + 1, 0)), rgb(255, 110, 160), parent)
	end
end

function Plants.reed(p, rng, parent)
	for _ = 1, 3 do
		local h = rng:NextNumber(3, 6)
		local offset = Vector3.new(rng:NextNumber(-1, 1), h / 2, rng:NextNumber(-1, 1))
		cylinder("Reed", h, 0.35, CFrame.new(p + offset), rgb(90, 160, 60), parent).CanCollide = false
		cylinder("Head", 1, 0.6, CFrame.new(p + offset + Vector3.new(0, h / 2 + 0.3, 0)), rgb(120, 80, 50), parent).CanCollide = false
	end
end

function Plants.flower(p, rng, parent)
	local colors = { rgb(255, 90, 120), rgb(255, 220, 60), rgb(160, 110, 255), rgb(255, 255, 255) }
	for _ = 1, rng:NextInteger(1, 3) do
		local at = p + Vector3.new(rng:NextNumber(-1.2, 1.2), 0, rng:NextNumber(-1.2, 1.2))
		cylinder("Stem", 1.6, 0.25, CFrame.new(at + Vector3.new(0, 0.8, 0)), rgb(70, 150, 60), parent).CanCollide = false
		ball("Bloom", Vector3.one * 1.1, CFrame.new(at + Vector3.new(0, 1.8, 0)), colors[rng:NextInteger(1, #colors)], parent).CanCollide = false
	end
end

function Plants.mushroom(p, rng, parent)
	local h = rng:NextNumber(2.5, 5)
	cylinder("Stem", h, 1.1, CFrame.new(p + Vector3.new(0, h / 2, 0)), rgb(240, 235, 220), parent)
	local caps = { rgb(220, 60, 60), rgb(170, 90, 220), rgb(240, 150, 60) }
	local cap = caps[rng:NextInteger(1, #caps)]
	local w = h * 0.9 + 1.5
	ball("Cap", Vector3.new(w, w * 0.5, w), CFrame.new(p + Vector3.new(0, h, 0)), cap, parent)
	for i = 1, 3 do
		local a = i * 2.1
		ball("Spot", Vector3.one * 0.6, CFrame.new(p + Vector3.new(math.cos(a) * w * 0.28, h + w * 0.2, math.sin(a) * w * 0.28)), rgb(255, 250, 240), parent)
	end
end

return Plants
