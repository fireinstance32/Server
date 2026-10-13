-- Lighting and sky (reference: clear bright midday, crisp shadows, punchy
-- colours, white clouds). Controllers/WorldLighting fades the per-world
-- parts of this.

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
	Lighting.Ambient = Color3.fromRGB(90, 90, 105)
	Lighting.GlobalShadows = true
	-- Sharp sun shadows and glowing parts lighting their surroundings (the
	-- reference look); "Soft" is flatter.
	Lighting.LightingStyle = Enum.LightingStyle.Realistic
	Lighting.PrioritizeLightingQuality = true
	Lighting.ShadowSoftness = 0.15
	Lighting.EnvironmentDiffuseScale = 1
	Lighting.EnvironmentSpecularScale = 0.25
	Lighting.ColorShift_Top = Color3.fromRGB(255, 245, 225)
	Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
	Lighting.GeographicLatitude = 35

	local atmosphere = child("Atmosphere", Lighting)
	atmosphere.Density = look.density
	atmosphere.Offset = 0
	atmosphere.Haze = 0.3
	atmosphere.Glare = 0
	atmosphere.Color = look.atmosphere
	atmosphere.Decay = Color3.fromRGB(110, 150, 210)

	local sky = child("Sky", Lighting)
	sky.SunAngularSize = 12
	sky.MoonAngularSize = 9
	sky.CelestialBodiesShown = true

	local bloom = child("BloomEffect", Lighting)
	bloom.Intensity = 0.15
	bloom.Size = 20
	bloom.Threshold = 2
	local rays = child("SunRaysEffect", Lighting)
	rays.Intensity = 0.02
	rays.Spread = 0.4
	-- Punchy toy colours (reference).
	local grade = Lighting:FindFirstChild("Grade") or Instance.new("ColorCorrectionEffect")
	grade.Name = "Grade"
	grade.Saturation = 0.08
	grade.Contrast = 0.1
	grade.Brightness = -0.02
	grade.Parent = Lighting

	local clouds = child("Clouds", workspace.Terrain)
	clouds.Cover = 0.5
	clouds.Density = 0.45
	clouds.Color = Color3.fromRGB(255, 255, 255)

	-- The terrain water under the lane is only there to swim in: the water
	-- you see is WorldBuilder/Water's surface, so it's invisible from above.
	local terrain = workspace.Terrain
	terrain.WaterColor = Color3.fromRGB(22, 150, 232)
	terrain.WaterTransparency = 1
	terrain.WaterReflectance = 0
	terrain.WaterWaveSize = 0
	terrain.WaterWaveSpeed = 0
end

return Environment
