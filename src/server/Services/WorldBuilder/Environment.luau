-- Lighting, sky and the water's look (reference: warm sunset, a huge sun
-- low over the far end of the throw lane, pink-orange clouds, clear bright
-- water). Controllers/WorldLighting fades the per-world parts of this.

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Worlds = require(ReplicatedStorage:WaitForChild("Shared").Config.Worlds)

local Environment = {}

local function child(className: string, parent: Instance): any
	local existing = parent:FindFirstChildOfClass(className)
	if existing then
		return existing
	end
	local made = Instance.new(className)
	made.Parent = parent
	return made
end

function Environment.buildLighting()
	local look = Worlds.Themes[Worlds.Default].lighting
	Lighting.ClockTime = look.ClockTime
	Lighting.Brightness = look.Brightness
	Lighting.OutdoorAmbient = look.OutdoorAmbient
	Lighting.Ambient = Color3.fromRGB(90, 80, 90)
	Lighting.GlobalShadows = true
	Lighting.EnvironmentDiffuseScale = 0.4
	Lighting.EnvironmentSpecularScale = 0.4

	local atmosphere = child("Atmosphere", Lighting)
	atmosphere.Density = look.density
	atmosphere.Offset = 0.1
	atmosphere.Haze = 1.4
	atmosphere.Glare = 0.6
	atmosphere.Color = look.atmosphere
	atmosphere.Decay = Color3.fromRGB(150, 110, 170)

	-- A big low sun (it rises over the far end of the lane: +X).
	local sky = child("Sky", Lighting)
	sky.SunAngularSize = 32
	sky.MoonAngularSize = 14
	sky.CelestialBodiesShown = true

	local bloom = child("BloomEffect", Lighting)
	bloom.Intensity = 0.6
	bloom.Size = 30
	bloom.Threshold = 1.6
	local rays = child("SunRaysEffect", Lighting)
	rays.Intensity = 0.06
	rays.Spread = 0.6

	local clouds = child("Clouds", workspace.Terrain)
	clouds.Cover = 0.62
	clouds.Density = 0.55
	clouds.Color = Color3.fromRGB(255, 205, 215)

	-- Clear, bright water: each zone's riverbed colour shows through it.
	local terrain = workspace.Terrain
	terrain.WaterColor = Color3.fromRGB(110, 205, 235)
	terrain.WaterTransparency = 0.82
	terrain.WaterReflectance = 0.35
	terrain.WaterWaveSize = 0.08
	terrain.WaterWaveSpeed = 8
end

return Environment
