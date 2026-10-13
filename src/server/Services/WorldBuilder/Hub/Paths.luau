-- Lavender walkways across the lobby (reference): spawn → Throw Zone with
-- dark chevrons pointing at the water, and a cross path from the rock shelf
-- to the gyms through the spawn.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Lobby = require(Shared.Config.Lobby)
local Game = require(Shared.Config.Game)
local Ponds = require(Shared.Config.Ponds)

local Parts = require(script.Parent.Parent.Parts)
local Style = require(script.Parent.Parent.Style)

local Paths = {}

local TOP = Color3.fromRGB(205, 195, 245)
local BORDER = Color3.fromRGB(150, 135, 210)
local CHEVRON = Color3.fromRGB(70, 60, 110)

type Segment = { from: Vector2, to: Vector2, width: number, chevrons: boolean? }

local function segments(): { Segment }
	local spawn = Lobby.Spawn
	local zoneStart = Game.hopZoneCenter().X - Game.HopZoneSizeX / 2
	return {
		{ from = Vector2.new(Lobby.egg(3).X + 6, 0), to = Vector2.new(zoneStart, 0), width = 14, chevrons = true },
		{ from = Vector2.new(spawn.X, Lobby.ShelfFrontZ), to = Vector2.new(spawn.X, Ponds.RowZ - Ponds.LengthZ / 2), width = 10 },
	}
end

local function chevrons(from: Vector2, to: Vector2, y: number, parent: Instance)
	local dir = (to - from).Unit
	local length = (to - from).Magnitude
	local yaw = math.atan2(-dir.Y, dir.X) -- rotation that turns +X onto dir
	for d = 22, length - 4, 10 do
		local p = from + dir * d
		local at = CFrame.new(p.X, y, p.Y) * CFrame.Angles(0, yaw, 0)
		for _, s in { -1, 1 } do
			-- Two bars meeting at the tip: a ">" pointing along the path.
			local bar = Parts.block("Chevron", Vector3.new(5, 0.06, 1.3), at * CFrame.new(-1.6, 0, s * 1.8) * CFrame.Angles(0, s * math.rad(40), 0), CHEVRON, parent)
			Style.quiet(bar)
		end
	end
end

function Paths.build(map: Model)
	local folder = Instance.new("Folder")
	folder.Name = "Paths"
	for i, seg in segments() do
		local lift = i * 0.01 -- so crossings don't flicker
		local mid = (seg.from + seg.to) / 2
		local length = (seg.to - seg.from).Magnitude
		local alongX = math.abs(seg.to.X - seg.from.X) > 0
		local function size(w: number, h: number): Vector3
			return if alongX then Vector3.new(length + w - seg.width, h, w) else Vector3.new(w, h, length + w - seg.width)
		end
		Parts.block("Border", size(seg.width + 2.4, 0.3), CFrame.new(mid.X, Lobby.FloorY + 0.15 + lift, mid.Y), BORDER, folder)
		Parts.block("Path", size(seg.width, 0.4), CFrame.new(mid.X, Lobby.FloorY + 0.2 + lift, mid.Y), TOP, folder)
		if seg.chevrons then
			chevrons(seg.from, seg.to, Lobby.FloorY + 0.43 + lift, folder)
		end
	end
	folder.Parent = map
end

return Paths
