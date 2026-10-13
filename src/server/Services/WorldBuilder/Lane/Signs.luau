-- Big floating zone names over the throw lane, facing the thrower
-- (reference: "🌴 Palm Beach 🌴" hanging over the water, the next zones'
-- names visible further down). Only the front is drawn.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)
local Zones = require(Shared.Config.Zones)
local Format = require(Shared.Util.Format)

local Parts = require(script.Parent.Parent.Parts)
local Terraces = require(script.Parent.Parent.Terraces)

local Signs = {}

local INK = Color3.fromRGB(30, 26, 40)

local function label(gui: SurfaceGui, text: string, color: Color3, y: number, height: number, stroke: number)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.fromScale(1, height)
	l.Position = UDim2.fromScale(0, y)
	l.BackgroundTransparency = 1
	l.Font = Enum.Font.FredokaOne
	l.TextScaled = true
	l.TextColor3 = color
	l.Text = text
	local s = Instance.new("UIStroke")
	s.Thickness = stroke
	s.Color = INK
	s.Parent = l
	l.Parent = gui
end

-- The sign for `zone` at lane distance `x`, centred over the water.
function Signs.build(zone: Zones.Zone, x: number, parent: Instance)
	local width = Game.RiverWidth + 24
	local at = Vector3.new(x, Terraces.Tiers[2].top + 8, 0)
	local board = Parts.block("Sign" .. zone.index, Vector3.new(width, 14, 0.2), CFrame.lookAt(at, at - Vector3.xAxis), Color3.new(1, 1, 1), parent)
	board.Transparency = 1
	board.CanCollide = false
	board.CanQuery = false
	board.CastShadow = false

	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 24
	gui.LightInfluence = 0
	gui.MaxDistance = 2500
	label(gui, `{zone.icon} {zone.name} {zone.icon}`, zone.color, 0, 0.66, 10)
	label(gui, `{Format.abbreviate(zone.wins)} Wins`, Color3.fromRGB(255, 235, 120), 0.64, 0.34, 7)
	gui.Parent = board
end

return Signs
