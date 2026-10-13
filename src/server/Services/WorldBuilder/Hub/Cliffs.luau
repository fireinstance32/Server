-- Terraced checker-brick cliffs around the hub's north, south and west edges
-- (reference): three grassy, studded steps rising away from the floor, with
-- blocky voxel trees and bushes on top. The east side is the throw lane.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Worlds = require(Shared.Config.Worlds)
local Zones = require(Shared.Config.Zones)

local Parts = require(script.Parent.Parent.Parts)
local Style = require(script.Parent.Parent.Style)
local Props = require(script.Parent.Parent.Props)
local Floor = require(script.Parent.Floor)

local Cliffs = {}

-- Each step: from `inner` to `outer` studs beyond the floor edge, `rise` tall.
local STEPS = {
	{ inner = 0, outer = 18 },
	{ inner = 18, outer = 36 },
	{ inner = 36, outer = 80 },
}
local RISE = 8
local CELL = Vector2.new(6, 4)

local function block(name: string, x0: number, x1: number, z0: number, z1: number, top: number, color: Color3, parent: Instance): Part
	local part = Parts.block(
		name,
		Vector3.new(x1 - x0, top + 4, z1 - z0),
		CFrame.new((x0 + x1) / 2, (top - 4) / 2, (z0 + z1) / 2),
		color,
		parent
	)
	Style.studs(part)
	return part
end

-- Voxel trees and bushes scattered over a step's top.
local function dress(x0: number, x1: number, z0: number, z1: number, top: number, rng: Random, parent: Instance)
	local spacing = 20
	local x = x0 + rng:NextNumber(4, spacing)
	while x < x1 - 4 do
		local z = rng:NextNumber(z0 + 4, math.max(z0 + 4, z1 - 4))
		local kind = if rng:NextNumber() < 0.7 then "voxel" else "bush"
		Props.place(kind, Vector3.new(x, top, z), rng, parent)
		x += rng:NextNumber(spacing * 0.7, spacing * 1.3)
	end
end

function Cliffs.build(world: Model, config: Worlds.World)
	local folder = Instance.new("Folder")
	folder.Name = "Cliffs"
	local props = Instance.new("Folder")
	props.Name = "CliffProps"
	local theme = Worlds.theme(config)
	local colors = (Zones.ByWorld[config.id] or Zones.List)[1].wall
	local rng = Random.new(4321)
	local minX, maxX, half = Floor.MinX, 0, Floor.HalfZ

	for k, step in STEPS do
		local top = Parts.GroundTop + RISE * k
		local base = top - RISE -- the face below this is hidden by the lower step
		local grass = theme.plaza:Lerp(Color3.new(0, 0, 0), 0.04 * (k - 1))
		local i, o = step.inner, step.outer
		local faceMid = (top + base) / 2

		-- North and south steps run the full width, corners included.
		for _, side in { -1, 1 } do
			local zi, zo = side * (half + i), side * (half + o)
			block("Step", minX - o, maxX, math.min(zi, zo), math.max(zi, zo), top, grass, folder)
			local faceWidth = maxX - (minX - i)
			-- (faces sit 0.1 proud of the step so they don't flicker against it)
			local at = Vector3.new((maxX + minX - i) / 2, faceMid, zi - side * 0.1)
			Style.checkerWall("Face", CFrame.lookAt(at, at - Vector3.zAxis * side), Vector2.new(faceWidth, RISE), CELL, colors, folder, 0.6)
			dress(minX - o + 2, maxX - 6, math.min(zi, zo) + 2, math.max(zi, zo) - 2, top, rng, props)
		end
		-- West step between them.
		block("Step", minX - o, minX - i, -(half + i), half + i, top, grass, folder)
		local at = Vector3.new(minX - i + 0.1, faceMid, 0)
		Style.checkerWall("Face", CFrame.lookAt(at, at + Vector3.xAxis), Vector2.new((half + i) * 2, RISE), CELL, colors, folder, 0.6)
		local zx = -(half + i) + 6
		while zx < half + i - 6 do
			Props.place(if rng:NextNumber() < 0.7 then "voxel" else "bush", Vector3.new(rng:NextNumber(minX - o + 4, minX - i - 4), top, zx), rng, props)
			zx += rng:NextNumber(14, 26)
		end
	end
	for _, part in props:GetDescendants() do
		if part:IsA("BasePart") then
			part.CastShadow = false
			part.CanQuery = false
		end
	end
	folder.Parent = world
	props.Parent = world
end

return Cliffs
