-- Living effects on rocks (client only, cosmetic): every held rock — yours
-- and other players' — the podium rocks and the thrown rock glint, and each kind of rock
-- has its own touch (embers off lava, bubbles off toxic ooze, stars round
-- a galaxy…; see Styles). Stronger rocks add comets orbiting them, then a
-- pulsing halo. Effects pause while the held rock is hidden (mid-throw).

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Frogs = require(Shared.Config.Frogs)
local RockLooks = require(Shared.Config.RockLooks)

local Settings = require(script.Parent.Parent.Settings)
local Kit = require(script.Parent.Kit)
local LiftFx = require(script.Parent.Lift)
local Styles = require(script.Styles)

local RockAura = {}

-- The server tags rock models with this (and sets their RockId attribute).
RockAura.Tag = "RockAura"

local WHITE = Color3.new(1, 1, 1)
local T = Kit.Textures

type Orbit = { attachment: Attachment, radius: number, speed: number, tilt: CFrame, phase: number }
type Aura = { model: Model, emitters: { ParticleEmitter }, orbits: { Orbit } }

local auras: { [Model]: Aura } = {}

-- The part whose transparency tells whether the rock is showing (any part
-- but the hidden Root).
local function skin(model: Model): BasePart?
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") and part ~= model.PrimaryPart and part.Transparency < 1 then
			return part
		end
	end
	return nil
end

local function comet(body: BasePart, color: Color3, radius: number, speed: number, tilt: CFrame, phase: number, size: number): Orbit
	local a = Instance.new("Attachment")
	a.Name = "AuraComet"
	a.Parent = body
	-- A stream of shrinking glow left where the comet has been = its tail.
	Kit.emitter(a, {
		Enabled = true,
		Texture = T.Sparkle,
		Color = ColorSequence.new(WHITE, color),
		Size = NumberSequence.new(size, 0),
		Lifetime = NumberRange.new(0.3),
		Rate = 60,
		Speed = NumberRange.new(0),
		LightEmission = 1,
		LockedToPart = false,
	})
	return { attachment = a, radius = radius, speed = speed, tilt = tilt, phase = phase }
end

-- Adds the effects to `model` (a rock built by Models.rock) for rock `rockId`.
function RockAura.attach(model: Model, rockId: string)
	local def = Frogs.ById[rockId]
	local body = model.PrimaryPart
	if not def or not body or auras[model] or not Settings.get("effects") then
		return
	end
	local size = model:GetExtentsSize()
	local radius = math.max(size.X, size.Y, size.Z) / 2
	local power = LiftFx.power(def.perBounce)
	local glow = def.color:Lerp(WHITE, 0.4)
	-- Surface effects spawn on a ball the rock's size; point effects at its centre.
	local holder = Kit.shell(model) :: BasePart
	local centre = Instance.new("Attachment")
	centre.Name = "Aura"
	centre.Parent = body
	local aura: Aura = { model = model, emitters = {}, orbits = {} }

	-- Glints for every rock: tiny stars winking on the surface.
	table.insert(
		aura.emitters,
		Kit.emitter(holder, {
			Texture = T.Sparkle,
			Color = ColorSequence.new(WHITE, glow),
			Shape = Enum.ParticleEmitterShape.Sphere,
			ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface,
			ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward,
			Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, radius * 0.55), NumberSequenceKeypoint.new(1, 0) }),
			Lifetime = NumberRange.new(0.35, 0.5),
			Rate = 1.5 + 5 * power,
			Speed = NumberRange.new(0),
			Rotation = NumberRange.new(0, 90),
			LightEmission = 1,
		})
	)

	-- The rock's own style.
	local style = Styles[RockLooks.shapeFor(def.id)]
	if style then
		table.insert(aura.emitters, style(holder, def.color, radius, power))
	end

	-- Comets orbiting stronger rocks: one from 60/lift, two from 250, three for ultimates.
	local count = if def.ultimate then 3 elseif def.perBounce >= 250 then 2 elseif def.perBounce >= 60 then 1 else 0
	for k = 1, count do
		local tilt = CFrame.Angles(math.rad(25 + 40 * k), math.rad(70 * k), 0)
		table.insert(aura.orbits, comet(body, glow, radius * 1.6, 3.2 + 0.6 * k, tilt, k * 2.1, radius * 0.35))
	end

	-- A slow-pulsing halo behind the very best.
	if def.perBounce >= 250 or def.ultimate then
		table.insert(
			aura.emitters,
			Kit.emitter(centre, {
				Texture = T.Glow,
				Color = ColorSequence.new(glow),
				Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, radius * 2.2), NumberSequenceKeypoint.new(0.5, radius * 3.2), NumberSequenceKeypoint.new(1, radius * 2.2) }),
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.3), NumberSequenceKeypoint.new(1, 1) }),
				Lifetime = NumberRange.new(1.2),
				Rate = 2,
				Speed = NumberRange.new(0),
				LightEmission = 1,
				LockedToPart = true,
				ZOffset = -2,
			})
		)
	end

	auras[model] = aura
	local function refresh()
		local shown = skin(model) ~= nil
		for _, e in aura.emitters do
			e.Enabled = shown
		end
		for _, orbit in aura.orbits do
			(orbit.attachment:FindFirstChildOfClass("ParticleEmitter") :: ParticleEmitter).Enabled = shown
		end
	end
	refresh()
	local watched = skin(model)
	if watched then
		watched:GetPropertyChangedSignal("Transparency"):Connect(refresh)
	end
	model.AncestryChanged:Connect(function()
		if not model:IsDescendantOf(game) then
			auras[model] = nil
		end
	end)
end

RunService.RenderStepped:Connect(function()
	local now = os.clock()
	for _, aura in auras do
		for _, orbit in aura.orbits do
			local a = now * orbit.speed + orbit.phase
			orbit.attachment.Position = (orbit.tilt * CFrame.new(math.cos(a) * orbit.radius, 0, math.sin(a) * orbit.radius)).Position
		end
	end
end)

-- Rocks the server tagged (held rocks, podium displays) with their RockId.
function RockAura.init()
	local function add(instance: Instance)
		local id = instance:GetAttribute("RockId")
		if instance:IsA("Model") and typeof(id) == "string" then
			-- Streamed-in models can arrive before their parts; wait a beat.
			task.defer(RockAura.attach, instance, id)
		end
	end
	CollectionService:GetInstanceAddedSignal(RockAura.Tag):Connect(add)
	for _, instance in CollectionService:GetTagged(RockAura.Tag) do
		add(instance)
	end
end

return RockAura
