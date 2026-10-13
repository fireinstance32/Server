-- Dresses a gym with its theme's decor (Themes): Blender models through
-- Props.place, sized for the gym, on the cells of Util/GymGrid. Purely
-- visual; the same gym always gets the same layout.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Ponds = require(Shared.Config.Ponds)
local GymGrid = require(Shared.Util.GymGrid)

local Props = require(script.Parent.Parent.Props)
local Themes = require(script.Parent.Themes)

local Decor = {}

-- Width (studs) of each kind inside a gym; the lane uses bigger ones.
local WIDTH: { [string]: NumberRange } = {
	reed = NumberRange.new(1.6, 2.2),
	flower = NumberRange.new(1.4, 2),
	grass = NumberRange.new(1.2, 1.8),
	lilypad = NumberRange.new(2, 2.6),
	lotus = NumberRange.new(1.8, 2.4),
	candle = NumberRange.new(1.2, 1.8),
	jackolantern = NumberRange.new(1.8, 2.2),
	lantern = NumberRange.new(1.3, 1.6),
	stonelantern = NumberRange.new(1.8, 2.2),
	bamboo = NumberRange.new(2.6, 3.2),
	cherry = NumberRange.new(6.5, 7.5),
	voxel = NumberRange.new(5.5, 6.5),
	crystal = NumberRange.new(1.8, 2.6),
	mushroom = NumberRange.new(1.6, 2.4),
	bush = NumberRange.new(2.8, 3.4),
	torii = NumberRange.new(12, 12),
}

local SHORE_COUNT = 5
local WATER_COUNT = 3
local SCATTER_COUNT = 3

local function key(col: number, row: number): number
	return row * 100 + col
end

function Decor.build(pond: Ponds.Pond, theme: Themes.Theme, levels: { ground: number, water: number }, model: Model)
	local folder = Instance.new("Folder")
	folder.Name = "Decor"
	local rng = Random.new(pond.index * 97 + 13)
	local center = Ponds.center(pond)
	local cols, rows = GymGrid.Cols, GymGrid.Rows

	local function put(kind: string?, x: number, z: number, y: number?, turn: number?)
		if not kind then
			return
		end
		local width = WIDTH[kind]
		local at = Vector3.new(center.X + x, y or levels.ground, center.Z + z)
		Props.place(kind, at, rng, folder, { width = if width then rng:NextNumber(width.Min, width.Max) else nil, turn = turn })
	end
	local function pick(list: { string }): string?
		return if #list > 0 then list[rng:NextInteger(1, #list)] else nil
	end

	-- Cells already dressed (and the ones round the big pieces).
	local used = {}
	local function take(col: number, row: number)
		used[key(col, row)] = true
	end

	-- Either side of the stand pad (the strips beside it).
	local padRows = Ponds.StandSize / GymGrid.Cell
	local _, padZ = GymGrid.offset(1, (padRows + 1) / 2)
	local side = GymGrid.Cols * GymGrid.Cell / 2 - GymGrid.Cell / 2
	put(theme.guard, -side, padZ, nil, 0)
	put(theme.guard, side, padZ, nil, 0)

	-- The back corners: a 2×2 block of cells each.
	for _, c in { 1, cols - 1 } do
		local x, z = GymGrid.offset(c + 0.5, rows - 0.5)
		put(theme.corner, x, z)
		for dc = 0, 1 do
			for dr = 0, 1 do
				take(c + dc, rows - 1 + dr)
			end
		end
	end

	-- A gate across the pool near its far end, its feet on the side cells.
	if theme.gate then
		local gateRow = rows - 3
		local _, z = GymGrid.offset(1, gateRow)
		put(theme.gate, 0, z, nil, 0)
		take(1, gateRow)
		take(cols, gateRow)
	end

	local function scatter(cells: { { number } }, kinds: { string }, count: number, y: number?)
		local placed = 0
		local tries = 0
		while placed < count and tries < count * 6 and #cells > 0 do
			tries += 1
			local cell = cells[rng:NextInteger(1, #cells)]
			local col, row = cell[1], cell[2]
			if not used[key(col, row)] then
				take(col, row)
				local x, z = GymGrid.offset(col, row)
				local jitter = GymGrid.Cell * 0.2
				put(pick(kinds), x + rng:NextNumber(-jitter, jitter), z + rng:NextNumber(-jitter, jitter), y)
				placed += 1
			end
		end
	end
	scatter(GymGrid.shore(), theme.shore, SHORE_COUNT)
	scatter(GymGrid.cells("pool"), theme.water, WATER_COUNT, levels.water)
	local back = {}
	for _, cell in GymGrid.cells("ground") do
		if cell[2] > padRows then
			table.insert(back, cell)
		end
	end
	scatter(back, theme.scatter, SCATTER_COUNT)
	folder.Parent = model
end

return Decor
