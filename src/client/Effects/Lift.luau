-- The lift rep's effects (client only, cosmetic), timed by LiftAnimation:
--   charge  the squat: dust puffs at the feet, energy sucked into the rock
--   peak    the lockout: impact flash, shockwave rings, sparks and stars in
--           the rock's colour, a light pop, a camera punch
-- Stronger rocks (more Strength per lift) give bigger, brighter effects.

local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Settings = require(script.Parent.Parent.Settings)
local Kit = require(script.Parent.Kit)
local Screen = require(script.Parent.Screen)

local Lift = {}

local WHITE = Color3.new(1, 1, 1)
local T = Kit.Textures

-- 0 (Pebble) .. 1 (1000+ per lift).
function Lift.power(perBounce: number): number
	return math.clamp(math.log10(math.max(perBounce, 1)) / 3, 0, 1)
end

local function heldRock(character: Model): (Model?, BasePart?)
	local rock = character:FindFirstChild("HeldFrog")
	if rock and rock:IsA("Model") and rock.PrimaryPart then
		return rock, rock.PrimaryPart
	end
	return nil, nil
end

-- Emitters that live on the held rock (reused every rep).
local function rockEmitters(rock: Model, body: BasePart, color: Color3): { [string]: ParticleEmitter }
	local holder = body:FindFirstChild("LiftFx") :: Attachment?
	if not holder then
		local a = Instance.new("Attachment")
		a.Name = "LiftFx"
		a.Parent = body
		holder = a
		-- Charge: a shell of motes rushing in toward the rock (spawned round
		-- the rock's surface, so it lives on the shell part).
		Kit.emitter(Kit.shell(rock) or a, {
			Name = "Charge",
			Texture = T.Sparkle,
			Shape = Enum.ParticleEmitterShape.Sphere,
			ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface,
			ShapeInOut = Enum.ParticleEmitterShapeInOut.Inward,
			Speed = NumberRange.new(9, 13),
			Lifetime = NumberRange.new(0.22, 0.28),
			Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(0.6, 0.5), NumberSequenceKeypoint.new(1, 0) }),
			Transparency = NumberSequence.new(0.2, 0),
			LightEmission = 1,
		})
		-- Peak: sparks flung out of the rock.
		Kit.emitter(a, {
			Name = "Sparks",
			Texture = T.Sparks,
			Speed = NumberRange.new(16, 28),
			SpreadAngle = Vector2.new(180, 180),
			Lifetime = NumberRange.new(0.3, 0.55),
			Drag = 6,
			Acceleration = Vector3.new(0, -25, 0),
			Size = NumberSequence.new(0.7, 0),
			LightEmission = 1,
		})
		-- Peak: big soft twinkles that hang in the air.
		Kit.emitter(a, {
			Name = "Stars",
			Texture = T.Sparkle,
			Speed = NumberRange.new(5, 11),
			SpreadAngle = Vector2.new(180, 180),
			Lifetime = NumberRange.new(0.5, 0.9),
			Drag = 4,
			Rotation = NumberRange.new(0, 360),
			RotSpeed = NumberRange.new(-200, 200),
			Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.15, 1.3), NumberSequenceKeypoint.new(1, 0) }),
			LightEmission = 1,
		})
		-- Peak: one hot core blast behind everything.
		Kit.emitter(a, {
			Name = "Core",
			Texture = T.Core,
			Speed = NumberRange.new(0),
			Lifetime = NumberRange.new(0.25),
			Size = NumberSequence.new(1, 3.5),
			Transparency = NumberSequence.new(0.45, 1),
			LightEmission = 1,
			ZOffset = -1,
		})
	end
	local found = {}
	local shell = rock:FindFirstChild("FxShell")
	for _, parent in { holder :: Instance, shell } do
		for _, e in parent:GetChildren() do
			if e:IsA("ParticleEmitter") then
				found[e.Name] = e
			end
		end
	end
	local glow = color:Lerp(WHITE, 0.35)
	found.Charge.Color = ColorSequence.new(WHITE, glow)
	found.Sparks.Color = ColorSequence.new(WHITE, color)
	found.Stars.Color = ColorSequence.new(glow)
	found.Core.Color = ColorSequence.new(glow)
	return found
end

-- The squat: dust at the feet and the rock drawing energy in.
function Lift.charge(character: Model, color: Color3, power: number)
	if not Settings.get("effects") then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local rock, body = heldRock(character)
	if rock and body then
		rockEmitters(rock, body, color).Charge:Emit(math.floor(10 + 14 * power))
	end
	if root then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local feet = root.Position - Vector3.new(0, root.Size.Y / 2 + (if humanoid then humanoid.HipHeight else 2), 0)
		local holder = Kit.anchor(feet + Vector3.new(0, 0.3, 0), 1)
		Kit.emitter(holder, {
			Texture = T.Smoke,
			Color = ColorSequence.new(Color3.fromRGB(225, 215, 195)),
			Shape = Enum.ParticleEmitterShape.Disc,
			ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface,
			EmissionDirection = Enum.NormalId.Top,
			Speed = NumberRange.new(3, 6),
			SpreadAngle = Vector2.new(70, 70),
			Lifetime = NumberRange.new(0.4, 0.6),
			Drag = 5,
			Size = NumberSequence.new(1, 2.4),
			Transparency = NumberSequence.new(0.55, 1),
			LightEmission = 0,
		}):Emit(6)
	end
end

local fovBase: number? = nil
local function punch(amount: number)
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	-- Remember the resting FOV so overlapping punches never ratchet it.
	local base = fovBase or camera.FieldOfView
	fovBase = base
	camera.FieldOfView = base + amount
	local tween = TweenService:Create(camera, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = base })
	tween.Completed:Connect(function(state)
		if state == Enum.PlaybackState.Completed then
			fovBase = nil
		end
	end)
	tween:Play()
end

-- The lockout: the rock is overhead.
function Lift.peak(character: Model, color: Color3, power: number)
	local rock, body = heldRock(character)
	local root = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local at = if body then body.Position elseif root then root.Position + Vector3.new(0, 4, 0) else nil
	if not at then
		return
	end
	local glow = color:Lerp(WHITE, 0.4)
	punch(1.5 + 2.5 * power)
	Screen.shake(0.06 + 0.12 * power, 0.12)
	if not Settings.get("effects") then
		return
	end
	-- Flash + rings around the rock.
	Kit.flash(at, glow, 0.5, 1.8 + 1.4 * power, 0.18, 0.35)
	local flat = CFrame.new(at)
	Kit.ring(flat, glow, 1, 5 + 4 * power, 0.3, 0.12, 0.35)
	if power > 0.6 then
		Kit.ring(flat * CFrame.Angles(math.rad(90), math.rad(math.random(0, 180)), 0), WHITE, 0.8, 4 + 3 * power, 0.25, 0.08, 0.45)
	end
	if rock and body then
		local fx = rockEmitters(rock, body, color)
		fx.Sparks:Emit(math.floor(10 + 18 * power))
		fx.Stars:Emit(math.floor(4 + 8 * power))
		fx.Core:Emit(1)
		Kit.light(body, glow, 2 + 3 * power, 8 + 6 * power, 0.3)
	end
	-- Shockwave along the ground.
	if root then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local feet = root.Position - Vector3.new(0, root.Size.Y / 2 + (if humanoid then humanoid.HipHeight else 2) - 0.15, 0)
		Kit.ring(CFrame.new(feet), color, 2, 7 + 6 * power, 0.4, 0.08, 0.5)
	end
end

return Lift
