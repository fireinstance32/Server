--!strict
-- Merges the cells of a grid that pass `keep` into rectangles (greedy:
-- widest run, then as many rows as match), each { col, row, cols, rows },
-- so a shape on a grid is a few parts instead of one per cell. Pure.

local function rects(cols: number, rows: number, keep: (number, number) -> boolean): { { number } }
	local used = {}
	local out = {}
	local function free(col: number, row: number): boolean
		return col >= 1 and row >= 1 and col <= cols and row <= rows and keep(col, row) and not used[(row - 1) * cols + col]
	end
	for row = 1, rows do
		local col = 1
		while col <= cols do
			if free(col, row) then
				local width = 1
				while free(col + width, row) do
					width += 1
				end
				local height = 1
				while true do
					local ok = true
					for c = col, col + width - 1 do
						if not free(c, row + height) then
							ok = false
							break
						end
					end
					if not ok then
						break
					end
					height += 1
				end
				for r = row, row + height - 1 do
					for c = col, col + width - 1 do
						used[(r - 1) * cols + c] = true
					end
				end
				table.insert(out, { col, row, width, height })
				col += width
			else
				col += 1
			end
		end
	end
	return out
end

return rects
