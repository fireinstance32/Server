-- Studded lavender walkways across the hub (reference): spawn → Throw Zone
-- (with chevrons pointing at the water), and walks past the gyms, the rock
-- podiums, the portals and the eggs.

local Parts = require(script.Parent.Parent.Parts)
local Style = require(script.Parent.Parent.Style)

local Paths = {}

local WIDTH = 10
local TOP = Color3.fromRGB(205, 195, 245)
local BORDER = Color3.fromRGB(150, 135, 210)
local CHEVRON = Color3.fromRGB(70, 60, 110)

-- { from, to, chevrons } in hub-local X/Z. Axis-aligned.
local SEGMENTS: { { from: Vector2, to: Vector2, chevrons: boolean? } } = {
	{ from = Vector2.new(-100, 0), to = Vector2.new(-27, 0), chevrons = true }, -- spawn → Throw Zone
	{ from = Vector2.new(-100, -104), to = Vector2.new(-100, 72) }, -- north–south spine
	{ from = Vector2.new(-244, 72), to = Vector2.new(-10, 72) }, -- in front of the gyms
	{ from = Vector2.new(-244, -104), to = Vector2.new(-40, -104) }, -- past the rock podiums
	{ from = Vector2.new(-238, 14), to = Vector2.new(-100, 14) }, -- to the portals
	{ from = Vector2.new(-100, -36), to = Vector2.new(-8, -36) }, -- to the eggs
}

local function chevrons(from: Vector2, to: Vector2, y: number, parent: Instance)
	local dir = (to - from).Unit
	local length = (to - from).Magnitude
	local yaw = math.atan2(-dir.Y, dir.X) -- rotation that turns +X onto dir
	for d = 10, length - 6, 12 do
		local p = from + dir * d
		local at = CFrame.new(p.X, y, p.Y) * CFrame.Angles(0, yaw, 0)
		for _, s in { -1, 1 } do
			-- Two bars meeting at the tip: a ">" pointing along the path.
			local bar = Parts.block(
				"Chevron",
				Vector3.new(4.2, 0.06, 1.1),
				at * CFrame.new(-1.3, 0, s * 1.5) * CFrame.Angles(0, s * math.rad(40), 0),
				CHEVRON,
				parent
			)
			bar.CanCollide = false
			bar.CanQuery = false
			bar.CastShadow = false
		end
	end
end

function Paths.build(world: Model)
	local folder = Instance.new("Folder")
	folder.Name = "Paths"
	for i, seg in SEGMENTS do
		local lift = i * 0.01 -- so crossings don't flicker
		local mid = (seg.from + seg.to) / 2
		local length = (seg.to - seg.from).Magnitude
		local alongX = math.abs(seg.to.X - seg.from.X) > 0
		local function size(w: number, h: number): Vector3
			return if alongX then Vector3.new(length + w - WIDTH, h, w) else Vector3.new(w, h, length + w - WIDTH)
		end
		local border = Parts.block("Border", size(WIDTH + 2.4, 0.3), CFrame.new(mid.X, Parts.GroundTop + 0.15 + lift, mid.Y), BORDER, folder)
		Style.studs(border)
		local top = Parts.block("Path", size(WIDTH, 0.4), CFrame.new(mid.X, Parts.GroundTop + 0.2 + lift, mid.Y), TOP, folder)
		Style.studs(top)
		if seg.chevrons then
			chevrons(seg.from, seg.to, Parts.GroundTop + 0.43 + lift, folder)
		end
	end
	folder.Parent = world
end

return Paths
