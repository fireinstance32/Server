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
