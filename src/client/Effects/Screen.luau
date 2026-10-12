-- 2D celebration effects over the HUD: confetti rain and a quick colour
-- flash (new zone, new best, level up, hatch).

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Settings = require(script.Parent.Parent.Settings)

local Screen = {}

local COLORS = {
	Color3.fromRGB(255, 90, 90),
	Color3.fromRGB(255, 200, 40),
	Color3.fromRGB(90, 220, 90),
	Color3.fromRGB(80, 170, 255),
	Color3.fromRGB(200, 110, 255),
	Color3.fromRGB(255, 140, 210),
}

local layer: ScreenGui? = nil

local function getLayer(): ScreenGui
	if layer and layer.Parent then
		return layer
	end
	local gui = Instance.new("ScreenGui")
	gui.Name = "Effects"
	gui.DisplayOrder = 30
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	layer = gui
	return gui
end

-- Confetti pieces falling from the top of the screen.
function Screen.confetti(amount: number?)
	if not Settings.get("effects") then
		return
	end
	local gui = getLayer()
	for _ = 1, amount or 60 do
		local piece = Instance.new("Frame")
		piece.BorderSizePixel = 0
		piece.BackgroundColor3 = COLORS[math.random(1, #COLORS)]
		piece.Size = UDim2.fromOffset(math.random(10, 18), math.random(16, 26))
		piece.AnchorPoint = Vector2.new(0.5, 0.5)
		local x = math.random()
		piece.Position = UDim2.new(x, 0, 0, -math.random(20, 300))
		piece.Rotation = math.random(0, 360)
		piece.Parent = gui
		local time = 1.6 + math.random() * 1.2
		TweenService:Create(piece, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(x + (math.random() - 0.5) * 0.15, 0, 1, 40),
			Rotation = piece.Rotation + math.random(-540, 540),
		}):Play()
		Debris:AddItem(piece, time + 0.1)
	end
end

-- A soft full-screen flash of `color`.
function Screen.flash(color: Color3?, strength: number?)
	local flash = Instance.new("Frame")
	flash.BorderSizePixel = 0
	flash.Size = UDim2.fromScale(1, 1)
	flash.BackgroundColor3 = color or Color3.new(1, 1, 1)
	flash.BackgroundTransparency = 1 - (strength or 0.35)
	flash.Parent = getLayer()
	TweenService:Create(flash, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
	Debris:AddItem(flash, 0.6)
end

return Screen
