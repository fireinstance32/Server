-- 3D effects in the world (client only, cosmetic): water splashes on lily
-- pads, the landing burst, sparkles around a character. Built-in Roblox
-- particle textures, so nothing needs uploading.

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Settings = require(script.Parent.Parent.Settings)

local World = {}

local SPARKLE = "rbxasset://textures/particles/sparkles_main.dds"
local SMOKE = "rbxasset://textures/particles/smoke_main.dds"

-- An invisible anchor part holding emitters, cleaned up after `life`.
local function anchor(position: Vector3, life: number): Part
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = Vector3.new(0.2, 0.2, 0.2)
	part.CFrame = CFrame.new(position)
	part.Parent = Workspace
	Debris:AddItem(part, life)
	return part
end

local function emitter(parent: Instance, props: { [string]: any }): ParticleEmitter
	local e = Instance.new("ParticleEmitter")
	e.Enabled = false
	e.LightEmission = 0.3
	for key, value in props do
		(e :: any)[key] = value
	end
	e.Parent = parent
	return e
end

local function ring(position: Vector3, color: Color3, from: number, to: number, time: number)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Shape = Enum.PartType.Cylinder
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Transparency = 0.3
	part.Size = Vector3.new(0.2, from, from)
	part.CFrame = CFrame.new(position + Vector3.new(0, 0.3, 0)) * CFrame.Angles(0, 0, math.rad(90))
	part.Parent = Workspace
	TweenService:Create(part, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.2, to, to),
		Transparency = 1,
	}):Play()
	Debris:AddItem(part, time + 0.1)
end

-- A frog landing on a pad: ripple + a little crown of droplets.
function World.splash(position: Vector3, size: number?)
	local s = size or 1
	ring(position, Color3.fromRGB(200, 240, 255), 2 * s, 9 * s, 0.4)
	if not Settings.get("effects") then
		return
	end
	local holder = anchor(position + Vector3.new(0, 0.4, 0), 1.2)
	local drops = emitter(holder, {
		Texture = SPARKLE,
		Color = ColorSequence.new(Color3.fromRGB(170, 225, 255)),
		Size = NumberSequence.new(0.5 * s, 0.1),
		Lifetime = NumberRange.new(0.4, 0.7),
		Speed = NumberRange.new(10 * s, 16 * s),
		SpreadAngle = Vector2.new(35, 35),
		Acceleration = Vector3.new(0, -60, 0),
		EmissionDirection = Enum.NormalId.Top,
		Transparency = NumberSequence.new(0, 1),
	})
	drops:Emit(math.floor(10 * s))
end

-- The end of a river hop: big ripple, golden sparkle fountain, soft mist.
function World.landingBurst(position: Vector3, color: Color3?)
	local tint = color or Color3.fromRGB(255, 210, 60)
	ring(position, tint, 3, 26, 0.7)
	ring(position, Color3.fromRGB(220, 245, 255), 2, 16, 0.5)
	if not Settings.get("effects") then
		return
	end
	local holder = anchor(position + Vector3.new(0, 1, 0), 2.5)
	emitter(holder, {
		Texture = SPARKLE,
		Color = ColorSequence.new(tint, Color3.new(1, 1, 1)),
		Size = NumberSequence.new(1.6, 0),
		Lifetime = NumberRange.new(0.8, 1.4),
		Speed = NumberRange.new(18, 30),
		SpreadAngle = Vector2.new(60, 60),
		Acceleration = Vector3.new(0, -35, 0),
		EmissionDirection = Enum.NormalId.Top,
		LightEmission = 1,
	}):Emit(40)
	emitter(holder, {
		Texture = SMOKE,
		Color = ColorSequence.new(Color3.fromRGB(230, 245, 255)),
		Size = NumberSequence.new(3, 8),
		Lifetime = NumberRange.new(0.8, 1.2),
		Speed = NumberRange.new(4, 8),
		SpreadAngle = Vector2.new(180, 20),
		Transparency = NumberSequence.new(0.4, 1),
	}):Emit(12)
end

-- Sparkles swirling up around a character (level up, rebirth).
function World.sparkleAround(character: Model?, color: Color3?)
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root or not Settings.get("effects") then
		return
	end
	local holder = anchor(root.Position, 2.5)
	emitter(holder, {
		Texture = SPARKLE,
		Color = ColorSequence.new(color or Color3.fromRGB(255, 220, 90)),
		Size = NumberSequence.new(1.2, 0),
		Lifetime = NumberRange.new(1, 1.6),
		Speed = NumberRange.new(6, 12),
		SpreadAngle = Vector2.new(180, 180),
		Acceleration = Vector3.new(0, 10, 0),
		LightEmission = 1,
	}):Emit(45)
end

return World
