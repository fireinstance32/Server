-- The reference map look: two-colour checker walls and floors (one base
-- part in the dark colour, a thin light tile on every other cell). Tiles are
-- visual only: no collisions, queries or shadows. (No stud texture: that's
-- added by hand in Studio with a plugin.)

local Parts = require(script.Parent.Parts)

local Style = {}

function Style.quiet(part: BasePart)
	part.CanCollide = false
	part.CanQuery = false
	part.CastShadow = false
end

-- Light checker tiles over a wall face. `face` is the centre of the visible
-- face with its LookVector pointing out of the wall; `size` is (width,
-- height); cells are ~`cell` (width, height) studs, stretched to fit exactly.
-- The dark cells are whatever is behind (the wall itself).
function Style.checkerTiles(face: CFrame, size: Vector2, cell: Vector2, color: Color3, parent: Instance)
	local cols = math.max(1, math.round(size.X / cell.X))
	local rows = math.max(1, math.round(size.Y / cell.Y))
	local w, h = size.X / cols, size.Y / rows
	for row = 0, rows - 1 do
		for col = 0, cols - 1 do
			if (row + col) % 2 == 1 then
				local at = face * CFrame.new(-size.X / 2 + (col + 0.5) * w, -size.Y / 2 + (row + 0.5) * h, -0.05)
				Style.quiet(Parts.block("Tile", Vector3.new(w, h, 0.1), at, color, parent))
			end
		end
	end
end

-- A standalone checker wall: a base part `depth` thick behind `face` in
-- colors[1], with colors[2] tiles on it.
function Style.checkerWall(name: string, face: CFrame, size: Vector2, cell: Vector2, colors: { Color3 }, parent: Instance, depth: number?): Part
	local thick = depth or 1
	local base = Parts.block(name, Vector3.new(size.X, size.Y, thick), face * CFrame.new(0, 0, thick / 2), colors[1], parent)
	Style.checkerTiles(face, size, cell, colors[2], base)
	return base
end

-- Light checker tiles over a floor. `top` is the centre of the floor's top
-- surface; `size` is (x, z); `cell` the tile size in studs.
function Style.checkerFloor(top: CFrame, size: Vector2, cell: number, color: Color3, parent: Instance)
	local cols = math.max(1, math.round(size.X / cell))
	local rows = math.max(1, math.round(size.Y / cell))
	local w, d = size.X / cols, size.Y / rows
	for ix = 0, cols - 1 do
		for iz = 0, rows - 1 do
			if (ix + iz) % 2 == 1 then
				local at = top * CFrame.new(-size.X / 2 + (ix + 0.5) * w, 0.03, -size.Y / 2 + (iz + 0.5) * d)
				Style.quiet(Parts.block("Tile", Vector3.new(w, 0.06, d), at, color, parent))
			end
		end
	end
end

return Style
