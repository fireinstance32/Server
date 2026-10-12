-- Front-of-head features. Units are body sizes; the face is at z = -0.5.

local Builder = require(script.Parent.Parent.Builder)
local PetFaces = require(script.Parent.Parent.Parent.Parent.Parent.Config.PetFaces)

local BLACK = Color3.fromRGB(25, 25, 30)
local WHITE = Color3.fromRGB(250, 250, 250)
local rad = math.rad

local Face = {}

function Face.eyes(b: Builder.Builder, scale: number)
	for _, side in { -1, 1 } do
		b:add("Eye", Vector3.new(0.16 * scale, 0.2 * scale, 0.04), CFrame.new(side * 0.22, 0.08, -0.51), BLACK)
		b:add("Shine", Vector3.new(0.06 * scale, 0.06 * scale, 0.02), CFrame.new(side * 0.22 + 0.035 * scale, 0.13, -0.535), WHITE)
	end
end

function Face.blush(b: Builder.Builder)
	for _, side in { -1, 1 } do
		b:add("Blush", Vector3.new(0.13, 0.06, 0.02), CFrame.new(side * 0.36, -0.07, -0.51), Builder.Pink, { Transparency = 0.25 })
	end
end

function Face.feet(b: Builder.Builder)
	for _, side in { -1, 1 } do
		for _, z in { -0.28, 0.28 } do
			b:add("Foot", Vector3.new(0.22, 0.14, 0.22), CFrame.new(side * 0.28, -0.55, z), b.dark)
		end
	end
end

local function snout(b: Builder.Builder, color: Color3)
	b:add("Snout", Vector3.new(0.36, 0.22, 0.12), CFrame.new(0, -0.14, -0.55), color)
	b:add("Nose", Vector3.new(0.12, 0.08, 0.04), CFrame.new(0, -0.06, -0.62), BLACK)
end

function Face.snout(b: Builder.Builder)
	snout(b, b.light)
end

function Face.whiteSnout(b: Builder.Builder)
	snout(b, WHITE)
end

function Face.pinkNose(b: Builder.Builder)
	b:add("Nose", Vector3.new(0.18, 0.13, 0.08), CFrame.new(0, -0.1, -0.54), Builder.Pink)
end

function Face.beak(b: Builder.Builder)
	b:add("Beak", Vector3.new(0.14, 0.14, 0.14), CFrame.new(0, -0.07, -0.52) * CFrame.Angles(0, 0, rad(45)), Color3.fromRGB(255, 180, 40))
end

function Face.wideMouth(b: Builder.Builder)
	b:add("Mouth", Vector3.new(0.46, 0.04, 0.02), CFrame.new(0, -0.17, -0.51), BLACK)
end

function Face.teeth(b: Builder.Builder)
	b:add("Teeth", Vector3.new(0.14, 0.1, 0.02), CFrame.new(0, -0.2, -0.51), WHITE)
end

function Face.fangs(b: Builder.Builder)
	for _, side in { -1, 1 } do
		b:add("Fang", Vector3.new(0.05, 0.08, 0.02), CFrame.new(side * 0.08, -0.2, -0.51), WHITE)
	end
end

function Face.whiskers(b: Builder.Builder)
	for _, side in { -1, 1 } do
		for i, tilt in { -12, 0, 12 } do
			b:add(
				"Whisker",
				Vector3.new(0.24, 0.015, 0.015),
				CFrame.new(side * 0.5, -0.1 - (i - 2) * 0.04, -0.52) * CFrame.Angles(0, 0, rad(tilt * side)),
				BLACK
			)
		end
	end
end

function Face.eyePatches(b: Builder.Builder)
	for _, side in { -1, 1 } do
		b:add("Patch", Vector3.new(0.27, 0.3, 0.02), CFrame.new(side * 0.22, 0.07, -0.502) * CFrame.Angles(0, 0, rad(-15 * side)), BLACK)
	end
	-- Black eyes vanish on black patches: brighten the shine.
	for _, part in b.model:GetChildren() do
		if part.Name == "Eye" and part:IsA("BasePart") then
			part.Color = Color3.fromRGB(60, 60, 70)
		end
	end
end

function Face.topEyes(b: Builder.Builder)
	local eyeImage = PetFaces.content("eye")
	for _, side in { -1, 1 } do
		local eye = b:add("Eye", Vector3.new(0.3, 0.3, 0.3), CFrame.new(side * 0.24, 0.58, -0.22), WHITE)
		if eyeImage then
			b:decal(eye, "Front", eyeImage, "eye")
		else
			b:add("Pupil", Vector3.new(0.14, 0.16, 0.03), CFrame.new(side * 0.24, 0.58, -0.38), BLACK)
		end
	end
end

function Face.darkFace(b: Builder.Builder)
	b:add("Face", Vector3.new(0.66, 0.56, 0.02), CFrame.new(0, -0.03, -0.505), b.color:Lerp(Color3.new(0, 0, 0), 0.45))
	for _, part in b.model:GetChildren() do
		if part.Name == "Eye" and part:IsA("BasePart") then
			part.Color = WHITE
		elseif part.Name == "Shine" and part:IsA("BasePart") then
			part.Color = BLACK
		end
	end
end

-- Glitter around rare pets (Rainbow pets also glow).
function Face.sparkle(b: Builder.Builder, rainbow: boolean)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Rate = 6
	emitter.Lifetime = NumberRange.new(0.6, 1.2)
	emitter.Speed = NumberRange.new(0.5, 1.5)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Size = NumberSequence.new(0.25 * b.s, 0)
	emitter.LightEmission = 1
	emitter.Color = if rainbow
		then ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 90, 90)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(90, 255, 140)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(110, 140, 255)),
		})
		else ColorSequence.new(Color3.fromRGB(255, 220, 90))
	emitter.Parent = b.body
	if rainbow then
		local light = Instance.new("PointLight")
		light.Color = b.light
		light.Range = 6 * b.s
		light.Brightness = 1
		light.Parent = b.body
	end
end

return Face
