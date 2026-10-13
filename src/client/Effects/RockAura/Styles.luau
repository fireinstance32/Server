-- Each rock shape's own aura (RockAura adds glints, comets and halos on
-- top). Shape name (Config/RockLooks) → builds one emitter on `holder`
-- (an invisible ball the rock's size, see Kit.shell). `radius` is the rock's size, `power` 0..1 its
-- strength; the emitter is left disabled, RockAura switches it on.

local Kit = require(script.Parent.Parent.Kit)

local T = Kit.Textures
local WHITE = Color3.new(1, 1, 1)

type Style = (holder: BasePart, color: Color3, radius: number, power: number) -> ParticleEmitter

local function grow(size: number): NumberSequence
	return NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.3, size), NumberSequenceKeypoint.new(1, 0) })
end

-- Motes leaving the surface and drifting up.
local function rising(texture: string, tint: (Color3) -> ColorSequence, speed: number, size: number, rate: number, light: number): Style
	return function(holder, color, radius, power)
		return Kit.emitter(holder, {
			Texture = texture,
			Color = tint(color),
			Shape = Enum.ParticleEmitterShape.Sphere,
			ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface,
			EmissionDirection = Enum.NormalId.Top,
			Size = grow(radius * size),
			Lifetime = NumberRange.new(0.7, 1.2),
			Rate = rate * (1 + power),
			Speed = NumberRange.new(radius * speed * 0.6, radius * speed),
			SpreadAngle = Vector2.new(25, 25),
			Rotation = NumberRange.new(0, 360),
			RotSpeed = NumberRange.new(-90, 90),
			LightEmission = light,
			LockedToPart = false,
		})
	end
end

local function hot(c: Color3): ColorSequence
	return ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 240, 160)), ColorSequenceKeypoint.new(0.5, c), ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 20, 10)) })
end
local function light(c: Color3): ColorSequence
	return ColorSequence.new(WHITE, c:Lerp(WHITE, 0.3))
end
local function own(c: Color3): ColorSequence
	return ColorSequence.new(c:Lerp(WHITE, 0.25))
end
local function dark(c: Color3): ColorSequence
	return ColorSequence.new(c:Lerp(Color3.fromRGB(150, 90, 255), 0.4), Color3.fromRGB(20, 10, 30))
end
local function icy(_c: Color3): ColorSequence
	return ColorSequence.new(Color3.fromRGB(230, 250, 255), Color3.fromRGB(150, 210, 255))
end
local function candy(_c: Color3): ColorSequence
	return ColorSequence.new(Color3.fromRGB(255, 150, 220), Color3.fromRGB(150, 230, 255))
end

local embers = rising(T.Sparks, hot, 2.2, 0.35, 12, 1)
local flames = rising(T.Fire, hot, 1.8, 1.4, 18, 1)
local bubbles = rising(T.Glow, own, 1.2, 0.3, 7, 0.6)
local wisps = rising(T.Smoke, dark, 0.9, 1.1, 6, 0)
local frost = rising(T.Smoke, icy, 0.7, 0.9, 6, 0.3)
local spores = rising(T.Sparkle, own, 0.8, 0.22, 6, 0.5)
local sweets = rising(T.Sparkle, candy, 1, 0.3, 8, 0.8)
local shine = rising(T.Sparkle, light, 0.5, 0.35, 6, 1)

-- Gems throw big prism twinkles that hang still.
local function prism(holder: BasePart, color: Color3, radius: number, power: number): ParticleEmitter
	return Kit.emitter(holder, {
		Texture = T.Sparkle,
		Color = ColorSequence.new(WHITE, color:Lerp(WHITE, 0.5)),
		Shape = Enum.ParticleEmitterShape.Sphere,
		ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume,
		Size = grow(radius * 0.7),
		Lifetime = NumberRange.new(0.4, 0.6),
		Rate = 4 + 6 * power,
		Speed = NumberRange.new(0),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-60, 60),
		LightEmission = 1,
	})
end

-- Galaxy: stars swirling round in a disc.
local function stars(holder: BasePart, color: Color3, radius: number, power: number): ParticleEmitter
	return Kit.emitter(holder, {
		Texture = T.Sparkle,
		Color = ColorSequence.new(WHITE, color:Lerp(WHITE, 0.4)),
		Shape = Enum.ParticleEmitterShape.Disc,
		ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume,
		Size = grow(radius * 0.25),
		Lifetime = NumberRange.new(1, 1.6),
		Rate = 10 + 10 * power,
		Speed = NumberRange.new(0),
		RotSpeed = NumberRange.new(-120, 120),
		LightEmission = 1,
		Drag = 2,
	})
end

local Styles: { [string]: Style } = {
	RockLava = embers,
	RockMeteor = frost,
	RockComet = frost,
	RockMoon = shine,
	RockPhoenix = flames,
	RockToxic = bubbles,
	RockRune = wisps,
	RockMossy = spores,
	RockMushroom = spores,
	RockCandy = sweets,
	RockGummy = sweets,
	RockFrosted = sweets,
	RockGalaxy = stars,
	RockNugget = shine,
	RockRoyal = shine,
	RockOreRich = shine,
	RockGemOre = prism,
	RockGemCluster = prism,
}

return Styles
