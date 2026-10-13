-- The reference map look: the stud texture on every walkable surface, and
-- two-colour checker walls and floors (one base part in the dark colour, a
-- thin light tile on every other cell). Tiles are visual only: no
-- collisions, queries or shadows.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UiImages = require(ReplicatedStorage:WaitForChild("Shared").Config.UiImages)

local Parts = require(script.Parent.Parts)

local Style = {}

Style.StudTile = 4 -- studs per texture tile (one tile = one stud outline)

local function quiet(part: BasePart)
	part.CanCollide = false
	part.CanQuery = false
	part.CastShadow = false
end

-- Lays the stud texture over `face` (Top by default) of `part`.
function Style.studs(part: BasePart, face: Enum.NormalId?, transparency: number?)
	local studs = UiImages.content("studs")
	if not studs then
		return
	end
	local texture = Instance.new("Texture")
	texture.Name = "Studs"
	texture.Texture = studs
	texture.Face = face or Enum.NormalId.Top
	texture.StudsPerTileU = Style.StudTile
	texture.StudsPerTileV = Style.StudTile
	texture.Transparency = transparency or 0.45
	texture.Parent = part
end

-- A checker wall face. `face` is the centre of the visible face with its
-- LookVector pointing out of the wall; `size` is (width, height). The base
-- part is `depth` thick behind the face (so it can also be the solid wall);
-- cells are ~`cell` (width, height) studs, stretched to fit exactly.
function Style.checkerWall(
	name: string,
	face: CFrame,
	size: Vector2,
	cell: Vector2,
	colors: { Color3 },
	parent: Instance,
	depth: number?
): Part
	local thick = depth or 1
	local base = Parts.block(name, Vector3.new(size.X, size.Y, thick), face * CFrame.new(0, 0, thick / 2), colors[1], parent)
	local cols = math.max(1, math.round(size.X / cell.X))
	local rows = math.max(1, math.round(size.Y / cell.Y))
	local w, h = size.X / cols, size.Y / rows
	for row = 0, rows - 1 do
		for col = 0, cols - 1 do
			if (row + col) % 2 == 1 then
				local at = face * CFrame.new(-size.X / 2 + (col + 0.5) * w, -size.Y / 2 + (row + 0.5) * h, -0.05)
				local tile = Parts.block("Tile", Vector3.new(w, h, 0.1), at, colors[2], base)
				quiet(tile)
			end
		end
	end
	return base
end

-- Light checker tiles (with studs) over a floor. `top` is the centre of the
-- floor's top surface; `size` is (x, z); `cell` the tile size in studs.
function Style.checkerFloor(top: CFrame, size: Vector2, cell: number, color: Color3, parent: Instance)
	local cols = math.max(1, math.round(size.X / cell))
	local rows = math.max(1, math.round(size.Y / cell))
	local w, d = size.X / cols, size.Y / rows
	for ix = 0, cols - 1 do
		for iz = 0, rows - 1 do
			if (ix + iz) % 2 == 1 then
				local at = top * CFrame.new(-size.X / 2 + (ix + 0.5) * w, 0.03, -size.Y / 2 + (iz + 0.5) * d)
				local tile = Parts.block("Tile", Vector3.new(w, 0.06, d), at, color, parent)
				quiet(tile)
				Style.studs(tile)
			end
		end
	end
end

return Style
