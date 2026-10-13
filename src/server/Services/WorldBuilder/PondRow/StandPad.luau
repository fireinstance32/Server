-- The stand pad at a gym's front (reference): a checker square in the gym's
-- colours with white corner brackets and a chevron pointing the way you
-- face, so it's clear where training locks you in place. The pad part keeps
-- the PondId and its collision.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Ponds = require(Shared.Config.Ponds)

local Parts = require(script.Parent.Parent.Parts)
local Style = require(script.Parent.Parent.Style)

local StandPad = {}

local HEIGHT = 0.25
local CELL = 2
local BRACKET = 2.4 -- arm length
local BAR = 0.5 -- bracket / chevron bar width
local INSET = 0.35

local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.new(0, 0, 0)

local function mark(name: string, size: Vector3, cframe: CFrame, parent: Instance)
	Style.quiet(Parts.block(name, size, cframe, WHITE, parent, Enum.Material.Neon))
end

function StandPad.build(pond: Ponds.Pond, ground: number, model: Model): Part
	local size = Ponds.StandSize
	local stand = Ponds.standPosition(pond)
	local top = ground + HEIGHT
	local pad = Parts.block("StandPad", Vector3.new(size, HEIGHT, size), CFrame.new(stand.X, ground + HEIGHT / 2, stand.Z), pond.color:Lerp(BLACK, 0.12), model)
	pad:SetAttribute("PondId", pond.id)

	local cells = size / CELL
	local light = pond.color:Lerp(WHITE, 0.35)
	for row = 1, cells do
		for col = 1, cells do
			if (row + col) % 2 == 0 then
				local x = stand.X - size / 2 + (col - 0.5) * CELL
				local z = stand.Z - size / 2 + (row - 0.5) * CELL
				Style.quiet(Parts.block("Tile", Vector3.new(CELL, 0.06, CELL), CFrame.new(x, top + 0.03, z), light, pad))
			end
		end
	end

	-- Corner brackets: an L in each corner.
	local edge = size / 2 - INSET - BAR / 2
	local y = top + 0.08
	for _, sx in { -1, 1 } do
		for _, sz in { -1, 1 } do
			local corner = Vector3.new(stand.X + sx * edge, y, stand.Z + sz * edge)
			mark("Bracket", Vector3.new(BRACKET, 0.1, BAR), CFrame.new(corner - Vector3.new(sx * (BRACKET - BAR) / 2, 0, 0)), pad)
			mark("Bracket", Vector3.new(BAR, 0.1, BRACKET), CFrame.new(corner - Vector3.new(0, 0, sz * (BRACKET - BAR) / 2)), pad)
		end
	end

	-- A chevron near the front edge pointing out of the gym (-Z), the way
	-- training turns you.
	local tip = CFrame.new(stand.X, y, stand.Z - size / 2 + 1.4)
	for _, s in { -1, 1 } do
		mark("Chevron", Vector3.new(2.4, 0.1, BAR), tip * CFrame.new(s * 0.9, 0, 0.75) * CFrame.Angles(0, -s * math.rad(40), 0), pad)
	end
	return pad
end

return StandPad
