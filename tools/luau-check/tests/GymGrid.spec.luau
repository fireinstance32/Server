-- The inside of a gym: the stand pad at the front, a pool behind it that
-- never touches the pad, ground round both.
Color3 = { fromRGB = function(r, g, b)
	return { r, g, b }
end }

local Ponds = require("@shared/Config/Ponds")
local GymGrid = require("@shared/Util/GymGrid")
local t = require("@test")

t.test("the grid fills the gym inside its rim", function()
	t.equal(GymGrid.Cols * GymGrid.Cell, Ponds.WidthX - 2 * Ponds.Rim)
	t.equal(GymGrid.Rows * GymGrid.Cell, Ponds.LengthZ - 2 * Ponds.Rim)
end)

t.test("the pad cells are the stand pad", function()
	local pads = GymGrid.cells("pad")
	t.equal(#pads, (Ponds.StandSize / GymGrid.Cell) ^ 2)
	local sx, sz = 0, 0
	for _, cell in pads do
		local x, z = GymGrid.offset(cell[1], cell[2])
		sx += x / #pads
		sz += z / #pads
	end
	-- Their centre is where standPosition puts the player (relative to the gym's centre).
	t.equal(sx, 0)
	t.equal(sz, -(Ponds.LengthZ / 2 - Ponds.Rim - Ponds.StandSize / 2))
end)

t.test("the pool never touches the pad", function()
	for _, cell in GymGrid.cells("pool") do
		for dc = -1, 1 do
			for dr = -1, 1 do
				local col, row = cell[1] + dc, cell[2] + dr
				if col >= 1 and row >= 1 and col <= GymGrid.Cols and row <= GymGrid.Rows then
					t.equal(GymGrid.kind(col, row) ~= "pad", true)
				end
			end
		end
	end
end)

t.test("rects cover each kind exactly", function()
	for _, kind in { "pad", "pool", "ground" } do
		local count = 0
		for _, rect in GymGrid.rects(kind) do
			count += rect[3] * rect[4]
		end
		t.equal(count, #GymGrid.cells(kind))
	end
	t.equal(#GymGrid.shore() > 0, true)
end)
