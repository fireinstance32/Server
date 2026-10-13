-- 3D effects in the world (client only, cosmetic): splashes where the rock
-- bounces, the landing burst, sparkles around a character.

local Settings = require(script.Parent.Parent.Settings)
local Kit = require(script.Parent.Kit)

local World = {}

local SPARKLE = Kit.Textures.Sparkle
local SMOKE = Kit.Textures.Smoke
local anchor, emitter = Kit.anchor, Kit.emitter

local function ring(position: Vector3, color: Color3, from: number, to: number, time: number)
	Kit.ring(CFrame.new(position + Vector3.new(0, 0.3, 0)), color, from, to, time)
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
