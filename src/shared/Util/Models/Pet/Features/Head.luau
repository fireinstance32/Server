-- Top-of-head features: ears, horns, tufts, antennae, gills, mane.
-- A box turned 45° and half sunk into the head reads as a pointy ear.

local Builder = require(script.Parent.Parent.Builder)

local rad = math.rad
local DIAMOND = CFrame.Angles(0, 0, rad(45))
local CREAM = Color3.fromRGB(250, 235, 200)

local Head = {}

local function pointy(b: Builder.Builder, size: number, x: number)
	for _, side in { -1, 1 } do
		b:add("Ear", Vector3.new(size, size, 0.1), CFrame.new(side * x, 0.5, 0.05) * DIAMOND, b.dark)
		b:add("EarInner", Vector3.new(size * 0.55, size * 0.55, 0.02), CFrame.new(side * x, 0.53, -0.01) * DIAMOND, Builder.Pink)
	end
end

function Head.pointyEars(b: Builder.Builder)
	pointy(b, 0.26, 0.3)
end

function Head.bigPointyEars(b: Builder.Builder)
	pointy(b, 0.34, 0.3)
end

function Head.batEars(b: Builder.Builder)
	pointy(b, 0.38, 0.32)
end

function Head.floppyEars(b: Builder.Builder)
	for _, side in { -1, 1 } do
		b:add("Ear", Vector3.new(0.1, 0.44, 0.26), CFrame.new(side * 0.54, 0.16, 0) * CFrame.Angles(0, 0, rad(12 * side)), b.dark)
	end
end

function Head.longEars(b: Builder.Builder)
	for _, side in { -1, 1 } do
		local tilt = CFrame.Angles(0, 0, rad(-8 * side))
		b:add("Ear", Vector3.new(0.16, 0.56, 0.08), CFrame.new(side * 0.2, 0.74, 0.05) * tilt, b.color)
		b:add("EarInner", Vector3.new(0.08, 0.4, 0.02), CFrame.new(side * 0.2, 0.74, 0.0) * tilt, Builder.Pink)
	end
end

local function round(b: Builder.Builder, size: number, color: Color3)
	for _, side in { -1, 1 } do
		b:add(
			"Ear",
			Vector3.new(0.1, size, size),
			CFrame.new(side * 0.32, 0.5 + size * 0.15, 0.05) * CFrame.Angles(0, rad(90), 0),
			color,
			{ Shape = Enum.PartType.Cylinder }
		)
	end
end

function Head.roundEars(b: Builder.Builder)
	round(b, 0.26, b.dark)
end

function Head.bigRoundEars(b: Builder.Builder)
	round(b, 0.42, b.dark)
end

function Head.darkRoundEars(b: Builder.Builder)
	round(b, 0.28, Color3.fromRGB(25, 25, 30))
end

function Head.tufts(b: Builder.Builder)
	for _, side in { -1, 1 } do
		b:add("Tuft", Vector3.new(0.16, 0.16, 0.1), CFrame.new(side * 0.4, 0.52, 0) * DIAMOND, b.dark)
	end
end

function Head.horns(b: Builder.Builder)
	for _, side in { -1, 1 } do
		b:add("Horn", Vector3.new(0.08, 0.26, 0.08), CFrame.new(side * 0.26, 0.62, 0.12) * CFrame.Angles(0, 0, rad(-18 * side)), CREAM)
	end
end

function Head.horn(b: Builder.Builder)
	b:add("Horn", Vector3.new(0.08, 0.34, 0.08), CFrame.new(0, 0.66, -0.3) * CFrame.Angles(rad(-20), 0, 0), Color3.fromRGB(255, 210, 70))
end

function Head.mane(b: Builder.Builder)
	local colors = { Color3.fromRGB(255, 120, 200), Color3.fromRGB(170, 120, 255), Color3.fromRGB(120, 210, 255) }
	for i, color in colors do
		b:add("Mane", Vector3.new(0.14, 0.16, 0.22), CFrame.new(0, 0.56 - i * 0.04, -0.1 + i * 0.2), color)
	end
end

function Head.antennae(b: Builder.Builder)
	for _, side in { -1, 1 } do
		local tilt = CFrame.Angles(0, 0, rad(-20 * side))
		b:add("Antenna", Vector3.new(0.03, 0.36, 0.03), CFrame.new(side * 0.16, 0.66, -0.2) * tilt, b.dark)
		b:add("AntennaTip", Vector3.new(0.09, 0.09, 0.09), CFrame.new(side * 0.22, 0.84, -0.2), b.light, { Shape = Enum.PartType.Ball })
	end
end

function Head.crown(b: Builder.Builder)
	local gold = Color3.fromRGB(255, 200, 40)
	-- Sits behind frog top-eyes, so it shows above them.
	b:add("Crown", Vector3.new(0.7, 0.18, 0.6), CFrame.new(0, 0.62, 0.18), gold, { Material = Enum.Material.Metal })
	for i, x in { -0.25, 0, 0.25 } do
		b:add("CrownSpike", Vector3.new(0.18, 0.18, 0.05), CFrame.new(x, 0.78 + (if i == 2 then 0.05 else 0), -0.1) * DIAMOND, gold, { Material = Enum.Material.Metal })
	end
	b:add("Gem", Vector3.new(0.1, 0.1, 0.04), CFrame.new(0, 0.64, -0.13) * DIAMOND, Color3.fromRGB(240, 50, 80))
end

function Head.headband(b: Builder.Builder)
	local cloth = Color3.fromRGB(40, 40, 50)
	b:add("Headband", Vector3.new(1.04, 0.14, 1.04), CFrame.new(0, 0.28, 0), cloth)
	for i, tilt in { -20, 15 } do
		b:add("Tail", Vector3.new(0.08, 0.06, 0.4), CFrame.new(0.15 + i * 0.08, 0.26, 0.68) * CFrame.Angles(rad(tilt), rad(20 * i), 0), cloth)
	end
end

function Head.shiny(b: Builder.Builder)
	b.body.Material = Enum.Material.Metal
	b.body.Reflectance = 0.15
end

function Head.mushroomCap(b: Builder.Builder)
	-- A stepped (cube-style) toadstool hat resting on top.
	local red = Color3.fromRGB(230, 60, 60)
	b:add("Cap", Vector3.new(1.3, 0.2, 1.3), CFrame.new(0, 0.84, 0.05), red)
	b:add("CapTop", Vector3.new(0.85, 0.2, 0.85), CFrame.new(0, 1.02, 0.05), red)
	for _, at in { Vector3.new(-0.42, 0.95, -0.4), Vector3.new(0.4, 0.95, 0.3), Vector3.new(0.12, 1.13, -0.15) } do
		b:add("Spot", Vector3.new(0.18, 0.04, 0.18), CFrame.new(at), Color3.fromRGB(255, 250, 240))
	end
end

function Head.helmet(b: Builder.Builder)
	b:add("Helmet", Vector3.new(1.5, 1.5, 1.5), CFrame.new(0, 0.12, 0), Color3.fromRGB(200, 235, 255), { Shape = Enum.PartType.Ball, Transparency = 0.7 })
end

function Head.gills(b: Builder.Builder)
	for _, side in { -1, 1 } do
		for i, tilt in { 35, 0, -35 } do
			b:add(
				"Gill",
				Vector3.new(0.22, 0.06, 0.06),
				CFrame.new(side * 0.56, 0.32 - (i - 2) * 0.1, 0) * CFrame.Angles(0, 0, rad(tilt * side)),
				Color3.fromRGB(235, 80, 150)
			)
		end
	end
end

return Head
