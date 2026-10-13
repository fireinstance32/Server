-- Small building blocks shared by the 3D effects: invisible emitter anchors,
-- one-shot particle emitters, expanding neon rings and glow flashes. Uses
-- Roblox's built-in particle textures, so nothing needs uploading.

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Kit = {}

Kit.Textures = {
	Sparkle = "rbxasset://textures/particles/sparkles_main.dds",
	Smoke = "rbxasset://textures/particles/smoke_main.dds",
	Fire = "rbxasset://textures/particles/fire_main.dds",
	Sparks = "rbxasset://textures/particles/fire_sparks_main.dds",
	Shockwave = "rbxasset://textures/particles/explosion01_shockwave_main.dds",
	Implosion = "rbxasset://textures/particles/explosion01_implosion_main.dds",
	Core = "rbxasset://textures/particles/explosion01_core_main.dds",
	Glow = "rbxasset://textures/particles/forcefield_glow_main.dds",
}

local function bare(part: BasePart)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
end

-- An invisible anchor part to hold emitters, removed after `life` seconds.
function Kit.anchor(position: Vector3, life: number): Part
	local part = Instance.new("Part")
	bare(part)
	part.Transparency = 1
	part.Size = Vector3.new(0.2, 0.2, 0.2)
	part.CFrame = CFrame.new(position)
	part.Parent = Workspace
	Debris:AddItem(part, life)
	return part
end

-- An invisible ball the size of `model`, welded to its PrimaryPart, for
-- emitters that spawn on/around the model's surface (an emitter on an
-- Attachment ignores its shape and spawns from a single point). Reused.
function Kit.shell(model: Model): BasePart?
	local body = model.PrimaryPart
	if not body then
		return nil
	end
	local existing = model:FindFirstChild("FxShell")
	if existing and existing:IsA("BasePart") then
		return existing
	end
	local size = model:GetExtentsSize()
	local part = Instance.new("Part")
	part.Name = "FxShell"
	part.Shape = Enum.PartType.Ball
	part.Transparency = 1
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Massless = true
	part.Anchored = body.Anchored
	part.Size = Vector3.one * math.max(size.X, size.Y, size.Z) * 0.85
	part.CFrame = body.CFrame
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = body
	weld.Part1 = part
	weld.Parent = part
	part.Parent = model
	return part
end

-- A ParticleEmitter (disabled unless props say otherwise) under `parent`.
function Kit.emitter(parent: Instance, props: { [string]: any }): ParticleEmitter
	local e = Instance.new("ParticleEmitter")
	e.Enabled = false
	e.LightEmission = 0.3
	for key, value in props do
		(e :: any)[key] = value
	end
	e.Parent = parent
	return e
end

-- A flat neon ring at `cframe` (its up axis is the ring's axis) growing from
-- `from` to `to` studs across and fading out over `time` (from `alpha`
-- transparency, default 0.25).
function Kit.ring(cframe: CFrame, color: Color3, from: number, to: number, time: number, thickness: number?, alpha: number?)
	local part = Instance.new("Part")
	bare(part)
	part.Shape = Enum.PartType.Cylinder
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Transparency = alpha or 0.25
	local t = thickness or 0.2
	part.Size = Vector3.new(t, from, from)
	part.CFrame = cframe * CFrame.Angles(0, 0, math.rad(90))
	part.Parent = Workspace
	TweenService:Create(part, TweenInfo.new(time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = Vector3.new(t * 0.3, to, to),
		Transparency = 1,
	}):Play()
	Debris:AddItem(part, time + 0.1)
end

-- A glowing ball that swells from `from` to `to` studs and fades (impact
-- flash), from `alpha` transparency (default 0.1).
function Kit.flash(position: Vector3, color: Color3, from: number, to: number, time: number, alpha: number?)
	local part = Instance.new("Part")
	bare(part)
	part.Shape = Enum.PartType.Ball
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Transparency = alpha or 0.1
	part.Size = Vector3.one * from
	part.CFrame = CFrame.new(position)
	part.Parent = Workspace
	TweenService:Create(part, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.one * to,
		Transparency = 1,
	}):Play()
	Debris:AddItem(part, time + 0.1)
end

-- A light that pops to `brightness` and fades over `time`.
function Kit.light(parent: Instance, color: Color3, brightness: number, range: number, time: number)
	local light = Instance.new("PointLight")
	light.Color = color
	light.Brightness = brightness
	light.Range = range
	light.Shadows = false
	light.Parent = parent
	TweenService:Create(light, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Brightness = 0 }):Play()
	Debris:AddItem(light, time + 0.1)
end

return Kit
