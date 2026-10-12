-- Ultimate hop for top frogs (Config/Frogs `ultimate`): cut-in, fire aura on
-- the player, a beam from the sky and an explosion as the frog is thrown.
-- Purely cosmetic and plays over the start of the hop, so server timing is
-- unchanged.

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local CutIn = require(script.CutIn)
local WorldFx = require(script.Parent.World)

local Ultimate = {}

local FIRE = "rbxasset://textures/particles/fire_main.dds"

local function aura(character: Model, color: Color3)
	local root = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then
		return
	end
	local attachment = Instance.new("Attachment")
	attachment.Parent = root
	local flames = Instance.new("ParticleEmitter")
	flames.Texture = FIRE
	flames.Color = ColorSequence.new(color, Color3.new(0.05, 0.05, 0.05))
	flames.LightEmission = 0.8
	flames.Size = NumberSequence.new(3, 0.5)
	flames.Lifetime = NumberRange.new(0.4, 0.7)
	flames.Rate = 90
	flames.Speed = NumberRange.new(4, 8)
	flames.SpreadAngle = Vector2.new(30, 30)
	flames.Acceleration = Vector3.new(0, 12, 0)
	flames.Parent = attachment
	task.delay(1.6, function()
		flames.Enabled = false
	end)
	Debris:AddItem(attachment, 2.4)
end

local function beam(position: Vector3, color: Color3)
	local pillar = Instance.new("Part")
	pillar.Anchored = true
	pillar.CanCollide = false
	pillar.CanQuery = false
	pillar.CanTouch = false
	pillar.Material = Enum.Material.Neon
	pillar.Color = color
	pillar.Shape = Enum.PartType.Cylinder
	pillar.Size = Vector3.new(300, 2, 2)
	pillar.CFrame = CFrame.new(position + Vector3.new(0, 150, 0)) * CFrame.Angles(0, 0, math.rad(90))
	pillar.Transparency = 0.1
	pillar.Parent = Workspace
	TweenService:Create(pillar, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(300, 16, 16),
	}):Play()
	task.delay(0.5, function()
		TweenService:Create(pillar, TweenInfo.new(0.4), { Transparency = 1, Size = Vector3.new(300, 24, 24) }):Play()
	end)
	Debris:AddItem(pillar, 1)
end

-- `frog` is a Config/Frogs entry; `releasePoint` is where the frog leaves the hand.
function Ultimate.play(character: Model?, frog: { id: string, color: Color3 }, releasePoint: Vector3)
	CutIn.play(frog.id, frog.color)
	if character then
		aura(character, frog.color)
	end
	task.delay(0.55, function()
		beam(releasePoint, frog.color)
		WorldFx.landingBurst(releasePoint - Vector3.new(0, 2, 0), frog.color)
	end)
end

return Ultimate
