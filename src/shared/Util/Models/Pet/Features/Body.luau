-- Body features: tails, wings, shells, spikes and the special bodies
-- (slime, wool, ghost). The back of the pet is at z = +0.5.

local Builder = require(script.Parent.Parent.Builder)

local rad = math.rad
local WHITE = Color3.fromRGB(250, 250, 250)
local CREAM = Color3.fromRGB(250, 235, 200)

local Body = {}

function Body.tail(b: Builder.Builder)
	b:add("Tail", Vector3.new(0.1, 0.1, 0.36), CFrame.new(0, -0.05, 0.64) * CFrame.Angles(rad(30), 0, 0), b.dark)
end

function Body.thinTail(b: Builder.Builder)
	b:add("Tail", Vector3.new(0.05, 0.05, 0.5), CFrame.new(0, -0.3, 0.72) * CFrame.Angles(rad(15), 0, 0), Builder.Pink)
end

function Body.bushyTail(b: Builder.Builder)
	local tilt = CFrame.Angles(rad(35), 0, 0)
	b:add("Tail", Vector3.new(0.24, 0.24, 0.42), CFrame.new(0, 0, 0.66) * tilt, b.color)
	b:add("TailTip", Vector3.new(0.25, 0.25, 0.12), CFrame.new(0, 0.13, 0.84) * tilt, WHITE)
end

function Body.puffTail(b: Builder.Builder)
	b:add("Tail", Vector3.new(0.28, 0.28, 0.28), CFrame.new(0, -0.15, 0.55), WHITE, { Shape = Enum.PartType.Ball })
end

function Body.flatTail(b: Builder.Builder)
	b:add("Tail", Vector3.new(0.3, 0.06, 0.45), CFrame.new(0, -0.42, 0.66), b.dark)
end

function Body.wings(b: Builder.Builder)
	for _, side in { -1, 1 } do
		b:add("Wing", Vector3.new(0.08, 0.42, 0.4), CFrame.new(side * 0.54, 0, 0.06) * CFrame.Angles(0, 0, rad(-12 * side)), b.dark)
	end
end

-- A fan of rainbow feathers on each side (Starter Pack pet).
local RAINBOW = {
	Color3.fromRGB(255, 70, 90),
	Color3.fromRGB(255, 150, 50),
	Color3.fromRGB(255, 225, 60),
	Color3.fromRGB(90, 220, 110),
	Color3.fromRGB(70, 170, 255),
	Color3.fromRGB(170, 100, 255),
}

function Body.rainbowWings(b: Builder.Builder)
	for _, side in { -1, 1 } do
		for i, color in RAINBOW do
			local tilt = rad((15 + (i - 1) * 17) * side)
			b:add(
				"Wing",
				Vector3.new(0.06, 0.78 - i * 0.05, 0.2),
				CFrame.new(side * 0.5, 0.1, 0.05) * CFrame.Angles(0, 0, -tilt) * CFrame.new(0, 0.36, 0),
				color,
				{ Material = Enum.Material.Neon }
			)
		end
	end
end

function Body.batWings(b: Builder.Builder)
	for _, side in { -1, 1 } do
		b:add("Wing", Vector3.new(0.5, 0.32, 0.05), CFrame.new(side * 0.66, 0.12, 0.1) * CFrame.Angles(0, 0, rad(25 * side)), b.dark)
	end
end

function Body.mothWings(b: Builder.Builder)
	for _, side in { -1, 1 } do
		b:add(
			"Wing",
			Vector3.new(0.62, 0.52, 0.04),
			CFrame.new(side * 0.5, 0.15, 0.32) * CFrame.Angles(0, rad(25 * side), 0),
			b.light,
			{ Transparency = 0.15, Material = Enum.Material.Neon }
		)
	end
end

function Body.spikes(b: Builder.Builder)
	for i, z in { -0.1, 0.15, 0.4 } do
		local size = 0.2 - i * 0.03
		b:add("Spike", Vector3.new(0.06, size, size), CFrame.new(0, 0.5, z) * CFrame.Angles(rad(45), 0, 0), b.light)
	end
end

function Body.shell(b: Builder.Builder)
	b:add("Shell", Vector3.new(1.1, 0.5, 1.0), CFrame.new(0, 0.24, 0.12), b.dark)
	b:add("ShellTop", Vector3.new(0.6, 0.06, 0.55), CFrame.new(0, 0.5, 0.12), b.light)
end

function Body.slime(b: Builder.Builder)
	b.body.Transparency = 0.2
	b.body.Reflectance = 0.15
	b:add("Puddle", Vector3.new(1.16, 0.14, 1.16), CFrame.new(0, -0.48, 0), b.color, { Transparency = 0.2 })
	b:add("Drop", Vector3.new(0.14, 0.2, 0.14), CFrame.new(0.28, 0.6, 0.1), b.light, { Shape = Enum.PartType.Ball, Transparency = 0.2 })
end

function Body.wool(b: Builder.Builder)
	for _, at in { Vector3.new(-0.3, 0.45, 0.2), Vector3.new(0.3, 0.45, 0.2), Vector3.new(0, 0.52, -0.05), Vector3.new(-0.45, 0.1, 0.25), Vector3.new(0.45, 0.1, 0.25), Vector3.new(0, 0.3, 0.45) } do
		b:add("Wool", Vector3.new(0.4, 0.4, 0.4), CFrame.new(at), b.light)
	end
end

function Body.ghost(b: Builder.Builder)
	b.body.Transparency = 0.25
	b.body.Material = Enum.Material.Neon
	for i, x in { -0.33, 0, 0.33 } do
		b:add("Wisp", Vector3.new(0.3, if i == 2 then 0.14 else 0.24, 1), CFrame.new(x, -0.56, 0), b.color, { Transparency = 0.25, Material = Enum.Material.Neon })
	end
end

-- Collar band round the bottom of the body with a gold tag at the front.
function Body.collar(b: Builder.Builder)
	b:add("Collar", Vector3.new(1.04, 0.09, 1.04), CFrame.new(0, -0.4, 0), Color3.fromRGB(80, 210, 230))
	b:add("Tag", Vector3.new(0.12, 0.12, 0.04), CFrame.new(0, -0.47, -0.53) * CFrame.Angles(0, 0, rad(45)), Color3.fromRGB(255, 205, 60), { Material = Enum.Material.Metal })
end

function Body.claws(b: Builder.Builder)
	for _, side in { -1, 1 } do
		for i = -1, 1 do
			b:add("Claw", Vector3.new(0.04, 0.04, 0.08), CFrame.new(side * 0.28 + i * 0.06, -0.6, -0.42), CREAM)
		end
	end
end

return Body
