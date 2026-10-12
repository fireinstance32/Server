-- Fades the lighting to the world the player is standing in (Config/Worlds
-- Themes): time of day, brightness, ambient, haze colour and a colour tint.
-- Lighting is local, so each player sees their own world's mood.

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Worlds = require(ReplicatedStorage:WaitForChild("Shared").Config.Worlds)

local WorldLighting = {}

local FADE = TweenInfo.new(1.5, Enum.EasingStyle.Sine)

local function apply(world: Worlds.World)
	local look = Worlds.theme(world).lighting
	TweenService:Create(Lighting, FADE, {
		ClockTime = look.ClockTime,
		Brightness = look.Brightness,
		OutdoorAmbient = look.OutdoorAmbient,
	}):Play()
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere then
		TweenService:Create(atmosphere, FADE, { Color = look.atmosphere, Density = look.density }):Play()
	end
	local tint = Lighting:FindFirstChild("WorldTint") :: ColorCorrectionEffect?
	if not tint then
		local effect = Instance.new("ColorCorrectionEffect")
		effect.Name = "WorldTint"
		effect.Parent = Lighting
		tint = effect
	end
	TweenService:Create(tint :: ColorCorrectionEffect, FADE, { TintColor = look.tint }):Play()
end

function WorldLighting.init()
	local current: string? = nil
	task.spawn(function()
		while true do
			local character = Players.LocalPlayer.Character
			local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
			if root then
				local world = Worlds.toLocal(root.Position)
				if world and world.id ~= current then
					current = world.id
					apply(world)
				end
			end
			task.wait(0.5)
		end
	end)
end

return WorldLighting
