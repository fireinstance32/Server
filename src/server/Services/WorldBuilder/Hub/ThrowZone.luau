-- The Throw Zone (reference "THROW ZONE"): an orange-and-yellow checker
-- strip at the water's edge between the lane's walls, the words painted
-- across it (reading toward the water), and a lavender rim along the water.
-- The zone's size and place are Config/Game's Hop Zone.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)
local Lobby = require(Shared.Config.Lobby)

local Parts = require(script.Parent.Parent.Parts)
local Style = require(script.Parent.Parent.Style)

local ThrowZone = {}

local ORANGE = Color3.fromRGB(255, 165, 45)
local YELLOW = Color3.fromRGB(255, 214, 80)
local RIM = Color3.fromRGB(205, 195, 245)
local INK = Color3.fromRGB(40, 36, 50)

local function paint(strip: Part, sizeX: number, sizeZ: number)
	-- A flat part whose Front face points up, with the gui's up toward the
	-- water (+X) and its right along +Z: read by someone walking to the water.
	local top = strip.Position.Y + strip.Size.Y / 2 + 0.06
	local at = Vector3.new(strip.Position.X, top, strip.Position.Z)
	local face = Parts.block("Paint", Vector3.new(sizeZ - 4, sizeX - 3, 0.05), CFrame.fromMatrix(at, -Vector3.zAxis, Vector3.xAxis), Color3.new(1, 1, 1), strip)
	face.Transparency = 1
	Style.quiet(face)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 8 -- (TextScaled stops at 100 px: this lets it fill the strip)
	gui.LightInfluence = 0
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.FredokaOne
	text.Text = "THROW ZONE"
	text.TextScaled = true
	text.TextColor3 = Color3.fromRGB(250, 250, 255)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 4
	stroke.Color = INK
	stroke.Parent = text
	text.Parent = gui
	gui.Parent = face
end

function ThrowZone.build(map: Model)
	local center = Game.hopZoneCenter()
	local sizeX, sizeZ = Game.HopZoneSizeX, Game.HopZoneSizeZ
	local strip = Parts.block("ThrowZone", Vector3.new(sizeX, 0.4, sizeZ), CFrame.new(center.X, Lobby.FloorY + 0.2, center.Z), ORANGE, map)
	Style.checkerFloor(CFrame.new(center.X, Lobby.FloorY + 0.4, center.Z), Vector2.new(sizeX, sizeZ), 4, YELLOW, strip)
	paint(strip, sizeX, sizeZ)
	-- Lavender rim over the water's edge.
	Parts.block("Rim", Vector3.new(2, 1, sizeZ), CFrame.new(center.X + sizeX / 2 + 1, Lobby.FloorY + 0.1, center.Z), RIM, strip)
end

return ThrowZone
