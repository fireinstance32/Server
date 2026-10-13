-- One zone's stretch of the throw lane (reference): raised grassy banks with
-- the stud texture, checker brick walls down to the water, a lighter grass
-- lip along the top edge, the zone's riverbed tint, and its props.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)
local Zones = require(Shared.Config.Zones)

local Parts = require(script.Parent.Parent.Parts)
local Style = require(script.Parent.Parent.Style)
local Props = require(script.Parent.Parent.Props)

local Banks = {}

Banks.Width = 170 -- how far each bank reaches out from the water (meets the hub cliffs)
local FLOOR = -8 -- bottom of the banks and walls (under the riverbed)
local LIP = 1.4 -- the grass lip's height
local CELL = Vector2.new(6, 3) -- checker cell (width, height)

-- Builds zone `zone` from lane X `startX` to `endX` into `folder`; props go
-- into `props`. `rng` is the world's fixed-seed random.
function Banks.build(zone: Zones.Zone, startX: number, endX: number, folder: Instance, props: Instance, rng: Random)
	local half = Game.RiverWidth / 2
	local len = endX - startX
	local midX = startX + len / 2
	local top = Parts.BankTop
	local lipColor = zone.bank:Lerp(Color3.new(1, 1, 1), 0.18)

	local model = Instance.new("Model")
	model.Name = "Zone" .. zone.index
	for _, side in { -1, 1 } do
		local bank = Parts.block(
			"Bank",
			Vector3.new(len, top - FLOOR, Banks.Width),
			CFrame.new(midX, (top + FLOOR) / 2, side * (half + 1 + Banks.Width / 2)), -- behind the wall
			zone.bank,
			model
		)
		Style.studs(bank)

		-- Checker wall facing the water from the waterline up to the lip
		-- (two rows, as in the reference), plain below the water.
		local wallTop = top - LIP
		local face = CFrame.lookAt(Vector3.new(midX, wallTop / 2, side * half), Vector3.new(midX, wallTop / 2, 0))
		Style.checkerWall("Wall", face, Vector2.new(len, wallTop), CELL, zone.wall, model)
		Parts.block("WallBase", Vector3.new(len, -FLOOR, 1), CFrame.new(midX, FLOOR / 2, side * (half + 0.5)), zone.wall[1], model)

		-- The first zone's banks rise out of the hub floor: checker that end too.
		if startX <= Game.RiverOrigin.X then
			local endTop = wallTop + LIP
			local at = Vector3.new(startX - 0.1, (endTop + Parts.GroundTop) / 2, side * (half + 1 + Banks.Width / 2))
			Style.checkerWall("HubFace", CFrame.lookAt(at, at - Vector3.xAxis), Vector2.new(Banks.Width, endTop - Parts.GroundTop), CELL, zone.wall, model, 0.6)
		end

		local lip = Parts.block(
			"Lip",
			Vector3.new(len, LIP + 0.2, 3),
			CFrame.new(midX, top - LIP / 2 + 0.1, side * (half + 1.2)),
			lipColor,
			model
		)
		Style.studs(lip)
	end

	-- Riverbed in the zone's water colour (seen through the clear water).
	local bed = Parts.block(
		"Riverbed",
		Vector3.new(len, 2, Game.RiverWidth),
		CFrame.new(midX, -6, 0),
		zone.water,
		model
	)
	Style.studs(bed, nil, 0.3)
	model.Parent = folder

	-- Props on both banks, thinning out away from the water.
	for _, side in { -1, 1 } do
		local x = startX + rng:NextNumber(4, 16)
		while x < endX - 4 do
			local z = side * (half + 7 + rng:NextNumber(0, 46) ^ 1.15)
			local kind = zone.props[rng:NextInteger(1, #zone.props)]
			Props.place(kind, Vector3.new(x, top, z), rng, props)
			x += rng:NextNumber(14, 26)
		end
	end
end

return Banks
