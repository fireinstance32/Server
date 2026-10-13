-- The rock shelf (reference): lavender bleacher steps along the lobby's -Z
-- wall, one step per row of the world's rocks (FrogPodiums stands them on
-- it), each step a little higher than the one in front.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Lobby = require(Shared.Config.Lobby)
local Frogs = require(Shared.Config.Frogs)
local Worlds = require(Shared.Config.Worlds)

local Parts = require(script.Parent.Parent.Parts)
local Style = require(script.Parent.Parent.Style)

local Shelf = {}

local TOP = Color3.fromRGB(205, 195, 245)
local SIDE = Color3.fromRGB(150, 135, 210)
local PAD = Color3.fromRGB(185, 172, 238)
local BACK = -Lobby.HalfZ - 10 -- steps run on into the wall

function Shelf.build(map: Model, config: Worlds.World)
	local folder = Instance.new("Folder")
	folder.Name = "Shelf"
	local stepX, stepZ = Lobby.ShelfStepX, Lobby.ShelfStepZ
	local x0 = Lobby.ShelfStartX - stepX / 2
	local x1 = Lobby.ShelfStartX + (Lobby.ShelfColumns - 0.5) * stepX
	-- As many steps as the world has rows of rocks.
	local rows = math.clamp(math.ceil(#Frogs.forWorld(config.id) / Lobby.ShelfColumns), 1, Lobby.ShelfRows)
	for row = 0, rows - 1 do
		local front = Lobby.ShelfFrontZ - row * stepZ
		local top = Lobby.shelfTop(row)
		local depth = front - BACK
		-- The riser in the darker lavender, the tread on top.
		Parts.block("Step", Vector3.new(x1 - x0, top - 0.4, depth), CFrame.new((x0 + x1) / 2, (top - 0.4) / 2, (front + BACK) / 2), SIDE, folder)
		Parts.block("Tread", Vector3.new(x1 - x0, 0.4, depth), CFrame.new((x0 + x1) / 2, top - 0.2, (front + BACK) / 2), TOP, folder)
		-- A square pad under each podium.
		for col = 0, Lobby.ShelfColumns - 1 do
			local at = Lobby.shelf(row * Lobby.ShelfColumns + col + 1)
			Style.quiet(Parts.block("Pad", Vector3.new(stepX - 2, 0.06, stepZ - 2), CFrame.new(at.X, top + 0.03, at.Z), PAD, folder))
		end
	end
	folder.Parent = map
end

return Shelf
