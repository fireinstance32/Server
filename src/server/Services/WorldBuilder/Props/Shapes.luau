-- Small part helpers shared by the prop builders.

local Parts = require(script.Parent.Parent.Parts)

local Shapes = {}

Shapes.block = Parts.block

function Shapes.ball(name: string, size: Vector3, cf: CFrame, color: Color3, parent: Instance, material: Enum.Material?): Part
	local part = Parts.block(name, size, cf, color, parent, material)
	part.Shape = Enum.PartType.Ball
	return part
end

-- A cylinder standing up (Roblox cylinders run along X) centred on `cf`.
function Shapes.cylinder(name: string, length: number, width: number, cf: CFrame, color: Color3, parent: Instance): Part
	local part = Parts.block(name, Vector3.new(length, width, width), cf * CFrame.Angles(0, 0, math.rad(90)), color, parent)
	part.Shape = Enum.PartType.Cylinder
	return part
end

-- A disc lying flat (in the XZ plane of `cf`).
function Shapes.disc(name: string, diameter: number, thickness: number, cf: CFrame, color: Color3, parent: Instance): Part
	local part = Parts.block(name, Vector3.new(thickness, diameter, diameter), cf * CFrame.Angles(0, 0, math.rad(90)), color, parent)
	part.Shape = Enum.PartType.Cylinder
	return part
end

-- A four-sided spike from `base` up `height` studs: two stacked blocks
-- turned 45°, the top one narrower.
function Shapes.spike(name: string, base: CFrame, width: number, height: number, color: Color3, parent: Instance, material: Enum.Material?)
	Parts.block(name, Vector3.new(width, height * 0.6, width), base * CFrame.new(0, height * 0.3, 0) * CFrame.Angles(0, math.rad(45), 0), color, parent, material)
	Parts.block(name, Vector3.new(width * 0.55, height * 0.4, width * 0.55), base * CFrame.new(0, height * 0.8, 0) * CFrame.Angles(0, math.rad(45), 0), color, parent, material)
end

-- Random shade of `color` (lighter/darker by up to `amount`).
function Shapes.vary(color: Color3, rng: Random, amount: number?): Color3
	local t = rng:NextNumber(-1, 1) * (amount or 0.12)
	return if t > 0 then color:Lerp(Color3.new(1, 1, 1), t) else color:Lerp(Color3.new(0, 0, 0), -t)
end

return Shapes
